# find_in_github
Find some string in a repository in all the branches

## How to Use

### Step 1:Install required gems
```
  gem install octokit
  gem install terminal-table 
```

### 2. Add token and list of repositories
```
client = Octokit::Client.new(access_token: "")

# List of repositories to check
repos = ["owner/repo1", "owner/repo2"]

# String to find
find_string = 'test'

```
