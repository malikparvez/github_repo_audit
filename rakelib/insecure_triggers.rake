
desc('Check branches and files in .github/workflows for pull_request_target')
task(:insecure_triggers) do
  require 'set'

  branches_with_pull_request_target = Set.new
  files_with_pull_request_target = []

  # Exclude given repos
  exclude_repos = ['puppetlabs/cvelist', 'puppetlabs/gcp-magic-modules']

  github_client.repos(@org).map do |repo|
    next if exclude_repos.include?(repo.full_name)
    next if repo.private

    puts "Checking branches for #{repo.full_name}..."
    branches = github_client.branches(repo.full_name)

    branches.each do |branch|
      branch_name = branch.name
      puts "Checking branch #{branch_name} in #{repo.full_name}..."

      begin
        contents = github_client.contents(repo.full_name, path: '.github/workflows', ref: branch_name)
        # The GitHub API now only allows 30 searches in a minute
        sleep(2)

        next if contents.empty? || contents.nil?

        contents.each do |content|
          # Ensure content is a file by checking its type attribute
          next unless content.type == 'file' && !content.is_a?(Octokit::Response)

          # Fetch the file content
          file_content = Base64.decode64(github_client.contents(repo.full_name, path: content.path, ref: branch_name).content)

          if file_content.include?('pull_request_target')
            branches_with_pull_request_target.add(repo: repo.full_name, branch: branch_name)
            puts branches_with_pull_request_target
            files_with_pull_request_target << { repo: repo.full_name, branch: branch_name, file: content.path }
            puts files_with_pull_request_target
          end
           # The GitHub API now only allows 30 searches in a minute
          sleep(2)
        end
      rescue Octokit::NotFound
        # If no .github/workflows directory is found, move on to the next repository
        break
      rescue Octokit::ConnectionFailed => e
        puts "Connection failed: #{e.message}"
        next
      rescue Net::OpenTimeout => e
        puts "OpenTimeout: #{e.message}"
        retry_count ||= 0
        retry_count += 1
        sleep(5)
        retry if retry_count < 3 # Retry a maximum of 3 times    
      end
    end
  end

  puts "Found #{branches_with_pull_request_target.size} branches with pull_request_target"
  puts "Found #{files_with_pull_request_target.size} files with pull_request_target"
  
  outfile = ENV["OUTPUT"] || "dashboards/insecure_triggers.md"
  template = File.read("templates/insecure_triggers.erb")

  content = ERB.new(template, trim_mode: "-").result(binding)
  File.write(outfile, content)
end
