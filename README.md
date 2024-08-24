
---

# github_repo_audit

`insecure_triggers` is a tool designed to scan GitHub repositories for potentially insecure workflow configurations, specifically looking for occurrences of the `pull_request_target` trigger in GitHub Actions workflows. This trigger can be misused in certain configurations, leading to security vulnerabilities.

## Features

- Scans all branches of specified repositories.
- Checks for the presence of `pull_request_target` in `.github/workflows` directory.
- Generates a report detailing repositories and branches containing potentially insecure configurations.

## Installation

1. **Clone the Repository:**

   ```sh
   git clone https://github.com/malikparvez/github_repo_audit.git
   cd github_repo_audit
   ```

2. **Install Dependencies:**

   ```sh
   bundle install
   ```

3. **Set Up GitHub Access:**

   Ensure you have a GitHub personal access token with the necessary permissions. Set it up in your environment:

   ```sh
   export GITHUB_ACCESS_TOKEN=your_token_here
   ```

## Usage

Run the Rake task to scan the repositories:

```sh
bundle exec rake insecure_triggers
```

This will scan the repositories and generate a report based on the findings.

## Output

The output of the scan will be saved to `dashboards/insecure_triggers.md` in the root directory. This report will list all repositories and branches where the `pull_request_target` trigger was found in the workflows.

You can also view the [insecure_triggers Dashboard](dashboards/insecure_triggers.md) for a more comprehensive overview.

## Contributing

We welcome contributions! Please open issues for any bugs or feature requests, and feel free to submit pull requests.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Disclaimer

Please note that finding the `pull_request_target` trigger in workflows does not necessarily indicate a security issue. It's essential to review each case to determine if it poses a risk.

---

Feel free to customize the content according to your project's specific details and requirements.
