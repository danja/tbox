#!/bin/sh
cd /home/projects || exit

echo "Starting repository setup..."

# Clone each repository
clone_repo() {
    repo=$1
    dirname=$(basename "$repo")
    if [ -d "$dirname" ]; then
        echo "Repository $dirname already exists. Updating..."
        cd "$dirname" || exit
        git pull
        if [ -f "package.json" ]; then
            npm install
        fi
        cd .. || exit
    else
        echo "Cloning $repo into $dirname..."
        git clone "https://github.com/$repo" "$dirname"
    fi
}

# Process each repository
clone_repo "danja/hyperdata"
clone_repo "danja/semem"
clone_repo "danja/transmissions"
clone_repo "danja/tia"
clone_repo "danja/farelo"
clone_repo "danja/squirt"
clone_repo "danja/wstore"
clone_repo "danja/atuin"
clone_repo "danja/trellis"

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
echo "Repository setup complete"