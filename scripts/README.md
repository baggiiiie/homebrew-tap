# Homebrew Formula Update Scripts

## update-formula.rb

Automatically generates or updates Homebrew formula files by fetching release assets from GitHub and calculating SHA256 checksums.

### Features

- Dynamically detects available binaries for a release
- Supports any combination of platforms: darwin/linux with arm64/amd64
- Preserves existing formula metadata (description, homepage, license)
- Calculates SHA256 checksums automatically
- Uses GitHub API for reliable asset discovery

### Usage

```bash
./scripts/update-formula.rb <formula-name> <version> <repo>
```

**Parameters:**
- `formula-name`: Name of the formula (e.g., `configlock`)
- `version`: Version number without 'v' prefix (e.g., `0.0.2`)
- `repo`: GitHub repository in `owner/repo` format (e.g., `baggiiiie/configlock`)

**Example:**

```bash
./scripts/update-formula.rb configlock 0.0.2 baggiiiie/configlock
```

### Environment Variables

- `GITHUB_TOKEN`: Optional GitHub token for higher API rate limits

### Binary Naming Convention

The script expects release assets to follow this naming pattern:
```
{formula-name}-{platform}-{arch}
```

Supported combinations:
- `darwin-arm64` (macOS Apple Silicon)
- `darwin-amd64` (macOS Intel)
- `linux-arm64` (Linux ARM)
- `linux-amd64` (Linux x86_64)

### GitHub Actions Integration

This script is automatically run by the `update-formula.yml` workflow when triggered manually with:
- Release version (e.g., `v0.0.2`)
- Formula name
- Source repository

The workflow will automatically commit and push the updated formula.
