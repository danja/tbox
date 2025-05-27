#!/bin/bash

echo "[SETUP] Configuring repositories..."

# Set the projects directory
PROJECTS_DIR="/home/projects"
mkdir -p "$PROJECTS_DIR"
cd "$PROJECTS_DIR" || { echo "[ERROR] Failed to change to $PROJECTS_DIR"; exit 1; }

# Add all existing cloned directories as safe directories to git config
find "$PROJECTS_DIR" -maxdepth 1 -mindepth 1 -type d -print0 | xargs -0 -I {} git config --global --add safe.directory {}

# Clone or update a repository
clone_repo() {
    local repo=$1
    local dirname="${repo##*/}"  # Get the last part of the repo path
    local repo_url="https://github.com/$repo"
    
    if [ -d "$dirname" ]; then
        echo "[INFO] Repository $dirname exists, updating..."
        cd "$dirname" || return 1
        
        # Reset any local changes
        git reset --hard HEAD
        
        # Fetch and reset to origin/main
        git fetch origin
        git checkout main
        git reset --hard origin/main
        
        # Clean up any untracked files
        git clean -fd
        
        # Update submodules if any
        if [ -f ".gitmodules" ]; then
            git submodule update --init --recursive
        fi
        
        # Install npm dependencies if package.json exists
        if [ -f "package.json" ]; then
            echo "[INFO] Installing npm dependencies for $dirname..."
            npm ci --no-audit --prefer-offline
        fi
        
        cd .. || return 1
    else
        echo "[INFO] Cloning $repo into $dirname..."
        if ! git clone --depth 1 --branch main "$repo_url" "$dirname"; then
            echo "[ERROR] Failed to clone $repo"
            return 1
        fi
        
        # Initialize submodules if they exist
        if [ -f "$dirname/.gitmodules" ]; then
            echo "[INFO] Initializing submodules for $dirname..."
            (cd "$dirname" && git submodule update --init --recursive)
        fi
        
        # Install npm dependencies if package.json exists
        if [ -f "$dirname/package.json" ]; then
            echo "[INFO] Installing npm dependencies for $dirname..."
            (cd "$dirname" && npm ci --no-audit --prefer-offline)
        fi
    fi
    
    echo "[SUCCESS] $repo is ready"
    return 0
}

# Process each repository
repos=(
    "danja/hyperdata"
    "danja/semem"
    "danja/transmissions"
    "danja/tia"
    # "danja/farelo"
    "danja/squirt"
    "danja/wstore"
    "danja/atuin"
    "danja/trellis"
)

# Process each repository
for repo in "${repos[@]}"; do
    if [[ "$repo" == "#"* ]]; then
        continue  # Skip commented out repositories
    fi
    clone_repo "$repo"
done

echo "[SUCCESS] All repositories have been processed"

# Install npm packages for subdirectories with package.json
find_and_install_npm() {
    dir=$1
    find "$dir" -name "package.json" -not -path "*/node_modules/*" | while read -r package_file; do
        package_dir=$(dirname "$package_file")
        echo "Installing npm packages in $package_dir..."
        cd "$package_dir" || continue
        npm install
        cd - > /dev/null || exit
    done
}

# Run npm install for all subdirectories with package.json files
find_and_install_npm "/home/projects"

# Set permissions
chown -R semem:semem /home/projects/*

# Add all cloned directories as safe directories to git config
find /home/projects -maxdepth 1 -mindepth 1 -type d -print0 | xargs -0 -I {} git config --global --add safe.directory {}

echo "Repository setup complete"

# Ensure the script runs from the correct directory
cd /home/projects || exit
