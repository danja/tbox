#!/bin/sh
cd /repositories

# Define repos to clone
REPOS=(
  "user/repo1"
  "user/repo2"
)

# Clone and install each repo
for repo in "${REPOS[@]}"; do
  dirname=$(basename $repo)
  if [ ! -d "$dirname" ]; then
    git clone "https://github.com/$repo" "$dirname"
    cd "$dirname"
    npm install
    cd ..
  fi
done