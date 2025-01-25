#!/bin/sh
cd /home/projects || exit

echo "Starting repository setup..."

# Clone each repository
clone_repo() {
    repo=$1
    dirname=$(basename "$repo")
    if [ ! -d "$dirname" ]; then
        echo "Cloning $repo..."
        git clone "https://github.com/$repo" "$dirname"
        if [ -f "$dirname/package.json" ]; then
            cd "$dirname" || exit
            npm install
            cd .. || exit
        fi
    fi
}

# Process each repository
clone_repo "danja/hyperdata"
clone_repo "danja/semem"
clone_repo "danja/transmissions"

# Set permissions
chown -R semem:semem /home/projects/*
echo "Repository setup complete"