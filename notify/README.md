# Slack/Discord Notification Action

This GitHub Action sends notifications to Slack or Discord via webhooks.

## Features

- Works with both Slack and Discord
- Customizable messages
- Color-coded based on job status
- Includes repository, branch, commit, and actor information
- Easy to integrate into any workflow

## Usage

### Basic Example

```yaml
- name: Send Slack notification
  uses: your-username/actions/notify@v1
  if: always()
  with:
    webhook-url: "${{ secrets.SLACK_WEBHOOK_URL }}"
    message: "Deployment completed"
```

### Full Example

```yaml
- name: Send notification
  uses: your-username/actions/notify@v1
  if: always()
  with:
    webhook-url: "${{ secrets.SLACK_WEBHOOK_URL }}"
    status: "${{ job.status }}"
    platform: slack
    message: "Deployment to production completed"
    job-name: "Deploy"
```

### Discord Example

```yaml
- name: Send Discord notification
  uses: your-username/actions/notify@v1
  if: always()
  with:
    webhook-url: "${{ secrets.DISCORD_WEBHOOK_URL }}"
    platform: discord
    status: "${{ job.status }}"
    message: "Build status update"
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| webhook-url | Webhook URL for Slack or Discord | Yes | N/A |
| status | Status of the job (success, failure, cancelled) | No | success |
| platform | Platform to send notification to (slack or discord) | No | slack |
| message | Custom message to send | No | GitHub Action completed |
| job-name | Name of the job | No | github.workflow |
| repo | Repository name | No | github.repository |
| ref | Git reference (branch/tag) | No | github.ref_name |
| commit | Commit SHA | No | github.sha |
| actor | GitHub actor who triggered the workflow | No | github.actor |

## Setting Up Webhooks

### Slack

1. Go to your Slack workspace
2. Create a new app (or use an existing one)
3. Enable "Incoming Webhooks"
4. Create a new webhook URL for your workspace
5. Store the webhook URL as a secret in your GitHub repository

### Discord

1. Go to your Discord server settings
2. Select "Integrations" > "Webhooks"
3. Create a new webhook
4. Copy the webhook URL
5. Store the webhook URL as a secret in your GitHub repository

## Best Practices

- Use `if: always()` to ensure notifications are sent even if previous steps fail
- Place the notification step at the end of your workflow to capture the status of all previous steps

```yaml
steps:
  - name: Checkout code
    uses: actions/checkout@v5
    
  - name: Build and test
    run: |
      npm install
      npm test
      
  - name: Send notification
    uses: your-username/actions/notify@v1
    if: always()  # This ensures the notification is sent regardless of previous step status
    with:
      webhook-url: "${{ secrets.SLACK_WEBHOOK_URL }}"
      status: "${{ job.status }}"
      message: "Build and test workflow completed"
```

## Security Notes

- Always store webhook URLs as secrets in your GitHub repository
- Never hardcode webhook URLs in your workflow files
- Use pinned versions of actions to prevent supply chain attacks

## License

MIT