# PR Screenshot Action

This GitHub Action automatically captures screenshots of UI changes in pull requests.

## Features

- Captures screenshots of web pages
- Customizable viewport size
- Wait for specific elements to load
- Option for full-page screenshots
- Automatically comments on PR with the screenshot
- Customizable output path

## Usage

### Basic Example

```yaml
- name: Capture Screenshot
  uses: your-username/actions/pr-screenshot@v1
  with:
    url: "https://example.com"
    auth-token: ${{ secrets.GITHUB_TOKEN }}
```

### Full Example

```yaml
- name: Capture Screenshot
  uses: your-username/actions/pr-screenshot@v1
  with:
    url: "https://example.com/my-feature"
    wait-for-selector: ".my-component"
    viewport-width: "1920"
    viewport-height: "1080"
    output-path: "./screenshots/feature.png"
    auth-token: ${{ secrets.GITHUB_TOKEN }}
    comment-on-pr: "true"
    full-page: "true"
```

## Workflow Example

```yaml
name: UI Screenshot

on:
  pull_request:
    types: [opened, synchronize]
    paths:
      - 'src/components/**'
      - 'src/styles/**'

jobs:
  screenshot:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup and build app
        run: |
          npm install
          npm run build
          npm run start:preview &
          sleep 10
      
      - name: Capture Screenshot
        uses: your-username/actions/pr-screenshot@v1
        with:
          url: "http://localhost:3000"
          wait-for-selector: "#app-root"
          auth-token: ${{ secrets.GITHUB_TOKEN }}
          comment-on-pr: "true"
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| url | URL to capture screenshot of | Yes | N/A |
| wait-for-selector | CSS selector to wait for before taking screenshot | No | body |
| viewport-width | Width of viewport for screenshot | No | 1280 |
| viewport-height | Height of viewport for screenshot | No | 800 |
| output-path | Path to save screenshot to | No | ./screenshot.png |
| auth-token | GitHub token for PR comments | Yes | ${{ github.token }} |
| comment-on-pr | Whether to comment on PR with screenshot | No | true |
| full-page | Whether to capture full page screenshot | No | false |

## Outputs

| Output | Description |
|--------|-------------|
| screenshot-path | Path to the saved screenshot |

## Requirements

- This action runs on Node.js 20
- For local development, you'll need Puppeteer and its dependencies

## Tips

- For authenticated pages, consider setting up cookies or using a headless browser with authentication flow
- For dynamic content, adjust the `wait-for-selector` to ensure the page is fully loaded
- When using in a workflow, make sure your app is running before taking the screenshot
- For comparing screenshots, consider using additional tools like reg-suit or percy

## License

MIT
