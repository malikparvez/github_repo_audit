require 'octokit'
require 'set'
require 'terminal-table'

# Set up Octokit client
client = Octokit::Client.new(access_token: "")

# List of repositories to check
repos = ["owner/repo1", "owner/repo2"]

# String to find
find_string = 'pull_request_target'

# Array to store branches where 'pull_request_target' is found in code
branches_with_pull_request_target = Set.new
files_with_pull_request_target = []
repos.each do |repo|
  puts "Checking branches for #{repo}..."
  branches = client.branches(repo)

  branches.each do |branch|
    branch_name = branch.name
    puts "Checking branch #{branch_name} in #{repo}..."

    begin
      # Get the contents of the .github/workflows directory
      contents = client.contents(repo, path: '.github/workflows', ref: branch_name)
      contents.each do |content|
        next unless content.type == 'file'

        # Fetch the file content
        file_content = Base64.decode64(client.contents(repo, path: content.path, ref: branch_name).content)
        
        if file_content.include?(find_string)
          branches_with_pull_request_target.add({ repo: repo, branch: branch_name })
          files_with_pull_request_target << { repo: repo, branch: branch_name, file: content.path }
          #break # No need to check other files if found in one
        end
      end
    rescue Octokit::NotFound
      puts "No .github/workflows directory found in #{repo} for branch #{branch_name}"
      next
    end
  end
end

# Prepare table for branches with 'pull_request_target'
branch_rows = branches_with_pull_request_target.map do |branch_info|
    [branch_info[:repo], branch_info[:branch]]
  end
  
  branch_table = Terminal::Table.new(
    title: "Branches with 'pull_request_target' in .github/workflows",
    headings: ['Repository', 'Branch'],
    rows: branch_rows
  )
  
  # Prepare table for files with 'pull_request_target'
  file_rows = files_with_pull_request_target.map do |file_info|
    [file_info[:repo], file_info[:branch], file_info[:file]]
  end
  
  file_table = Terminal::Table.new(
    title: "Files with 'pull_request_target' in .github/workflows",
    headings: ['Repository', 'Branch', 'File'],
    rows: file_rows
  )
  
  # Print the tables
  puts branch_table
  puts file_table
