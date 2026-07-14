# Scripts

## validate-proof-artifact.sh

Dependency-free Bash script that validates a proof-artifact Markdown file
contains all required sections with non-empty content.

### Usage

```bash
scripts/validate-proof-artifact.sh <path-to-markdown>
```

### Required sections

The script checks that the file contains each of these `##` headings **and**
that each heading is followed by at least one non-blank line of content:

| Section | Heading |
|---------|---------|
| Trigger | `## Trigger` |
| Work performed | `## Work performed` |
| Verification | `## Verification` |
| Result | `## Result` |

### Exit codes

| Code | Meaning |
|------|---------|
| `0` | All sections present and non-empty. |
| `1` | One or more sections missing or empty (details on stderr). |
| `2` | File not found, not readable, or bad arguments. |

### Examples

```bash
# Validate a proof artifact (passes)
scripts/validate-proof-artifact.sh testdata/valid-proof-artifact.md

# Validate a proof artifact (fails — empty Verification section)
scripts/validate-proof-artifact.sh testdata/invalid-proof-artifact.md
echo $?   # 1

# Missing file
scripts/validate-proof-artifact.sh no-such-file.md
echo $?   # 2
```
