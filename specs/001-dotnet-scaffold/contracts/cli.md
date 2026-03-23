# Contract: Scaffold CLI Interface

## Overview

The scaffold bootstrap script exposes a command-line interface for generating new .NET solutions.

## Usage

```
./scaffold.sh [OPTIONS]

Options:
  -n, --name <NAME>          Solution name (required)
  -o, --output <PATH>        Output directory (required)
  -s, --sdk <VERSION>        .NET SDK version (default: 8.0)
  -f, --force               Overwrite existing files
  -v, --verbose             Enable verbose output
  -h, --help                Show help message
```

## Examples

```bash
# Basic usage
./scaffold.sh --name MyProject --output ./myproject

# With specific SDK version
./scaffold.sh -n MyProject -o ./myproject -s 8.0

# Force overwrite
./scaffold.sh -n MyProject -o ./myproject --force
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Invalid arguments |
| 3 | SDK not found |
| 4 | Target directory not empty |
| 5 | Permission denied |

## Environment Variables

| Variable | Purpose | Default |
|----------|---------|---------|
| `DOTNET_SCAFFOLD_SDK_VERSION` | Default SDK version | 8.0 |
| `DOTNET_SCAFFOLD_VERBOSE` | Enable verbose mode | false |
