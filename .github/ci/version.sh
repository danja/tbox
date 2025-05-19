#!/bin/bash
# version.sh - Determines semantic version for TBox based on git history

set -e

# Check if we're in a git repository
if [ ! -d .git ]; then
  echo "Error: Not in a git repository" >&2
  exit 1
fi

# If we're on a tag, use that as the version
if git describe --exact-match --tags HEAD >/dev/null 2>&1; then
  VERSION=$(git describe --exact-match --tags HEAD | sed 's/^v//')
  echo "$VERSION"
  exit 0
fi

# Get the most recent tag
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
LATEST_TAG=${LATEST_TAG#v} # Remove the 'v' prefix

# Parse the version
MAJOR=$(echo "$LATEST_TAG" | cut -d. -f1)
MINOR=$(echo "$LATEST_TAG" | cut -d. -f2)
PATCH=$(echo "$LATEST_TAG" | cut -d. -f3)

# Count commits since the latest tag
COMMITS_SINCE_TAG=$(git rev-list --count ${LATEST_TAG}..HEAD)

# Analyze commit messages since the latest tag
COMMITS=$(git log ${LATEST_TAG}..HEAD --pretty=format:"%s")

# Check for breaking changes or features
if echo "$COMMITS" | grep -qiE '(BREAKING CHANGE:|feat:)'; then
  if echo "$COMMITS" | grep -qi 'BREAKING CHANGE:'; then
    # Breaking change - increment major version
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
  else
    # New feature - increment minor version
    MINOR=$((MINOR + 1))
    PATCH=0
  fi
else
  # Regular changes - increment patch version
  PATCH=$((PATCH + 1))
fi

# Add git SHA and dev suffix for development versions
if [ $COMMITS_SINCE_TAG -gt 0 ]; then
  GIT_SHA=$(git rev-parse --short HEAD)
  DEV_VERSION="${MAJOR}.${MINOR}.${PATCH}-dev.${COMMITS_SINCE_TAG}+${GIT_SHA}"
  echo "$DEV_VERSION"
else
  # This should rarely happen - we'd typically be on a tag
  echo "${MAJOR}.${MINOR}.${PATCH}"
fi