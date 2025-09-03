# GitHub Actions Collection

A collection of reusable GitHub Actions for common workflow tasks.

## Available Actions

| Action | Description |
|--------|-------------|
| [notify](./notify/) | Send notifications to Slack or Discord |
| [pr-screenshot](./pr-screenshot/) | Capture screenshots of UI changes in pull requests |

## Usage

Reference these actions in your workflows using:

```yaml
- uses: your-username/actions/action-name@tag
```

For detailed usage instructions, see each action's README.

## Versioning

Actions in this repository use prefix-based tagging:

- `action-name-v1.0.0`: Specific version of an action
- `action-name-v1`: Latest release in the v1 line

This allows independent versioning of each action.

## Development

### Structure

Each action should include:
- `action.yml`: Action metadata
- `README.md`: Documentation
- Any additional required files

### Guidelines

- Follow semantic versioning
- Pin external action dependencies
- Provide clear documentation
- Include usage examples

## License

MIT