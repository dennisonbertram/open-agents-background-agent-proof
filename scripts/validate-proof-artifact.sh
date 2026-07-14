#!/usr/bin/env bash
# validate-proof-artifact.sh — Validate a proof-artifact Markdown file.
#
# Usage:  scripts/validate-proof-artifact.sh <path-to-markdown>
#
# Exit codes:
#   0  All required sections present and non-empty.
#   1  Validation failure (missing/empty section or bad arguments).
#   2  File not found or not readable.
#
# No external dependencies beyond coreutils + bash.

set -euo pipefail

# --- helpers ---------------------------------------------------------------

warn() {
  echo "FAIL:  $*" >&2
}

# --- argument check --------------------------------------------------------

if [ $# -ne 1 ]; then
  echo "ERROR: Usage: validate-proof-artifact.sh <markdown-path>" >&2
  exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
  echo "ERROR: File not found: $FILE" >&2
  exit 2
fi

if [ ! -r "$FILE" ]; then
  echo "ERROR: File not readable: $FILE" >&2
  exit 2
fi

# --- required sections -----------------------------------------------------

REQUIRED_SECTIONS="Trigger
Work performed
Verification
Result"

errors=0

while IFS= read -r section; do
  # Find the line number of the heading (## Section)
  heading_line=$(grep -n "^## ${section}[[:space:]]*$" "$FILE" | head -1 | cut -d: -f1)

  if [ -z "$heading_line" ]; then
    warn "Missing required section: ## ${section}"
    errors=$((errors + 1))
    continue
  fi

  # Extract body text between this heading and the next heading (or EOF).
  total_lines=$(wc -l < "$FILE")
  body_start=$((heading_line + 1))

  if [ "$body_start" -gt "$total_lines" ]; then
    warn "Section '## ${section}' exists but has no content (at end of file)"
    errors=$((errors + 1))
    continue
  fi

  # Use tail + sed to grab lines until the next ## heading
  body=$(tail -n +"$body_start" "$FILE" | sed '/^## /,$d')

  # Check if there is any non-blank content
  has_content=false
  while IFS= read -r line; do
    case "$line" in
      *[!\ \	]*)
        has_content=true
        break
        ;;
    esac
  done <<EOF
$body
EOF

  if [ "$has_content" != true ]; then
    warn "Section '## ${section}' is empty (no non-blank content)"
    errors=$((errors + 1))
  fi
done <<SECTIONS
$REQUIRED_SECTIONS
SECTIONS

# --- summary ---------------------------------------------------------------

if [ "$errors" -gt 0 ]; then
  echo "Validation failed with ${errors} error(s)." >&2
  exit 1
fi

echo "OK: $FILE passes all proof-artifact checks." >&2
exit 0
