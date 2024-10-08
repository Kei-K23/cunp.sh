#!/bin/bash

# Check if package.json exists
if [ ! -f "package.json" ]; then
  echo "Error: package.json not found!"
  exit 1
fi

# Install jq if not already installed (used to parse JSON in the script)
if ! command -v jq &> /dev/null; then
  echo "jq is required for this script to run. Installing jq..."
  if command -v apt-get &> /dev/null; then
    sudo apt-get install jq -y
  elif command -v brew &> /dev/null; then
    brew install jq
  else
    echo "Please install jq manually and rerun the script."
    exit 1
  fi
fi

# Extract dependencies from package.json
dependencies=$(jq -r '.dependencies | keys[]' package.json)

# Initialize an array to store unused packages
unused_packages=()

# Loop through each dependency and check if it's used in the source code
for package in $dependencies; do
  echo "Checking for usage of package: $package"
  
  # Use grep to search for any occurrence of the package name in the src/ directory
  usage_count=$(grep -r --include="*.js" --include="*.ts" "$package" src/ | wc -l)
  
  # If the package is not found in the source code, add it to the unused_packages array
  if [ "$usage_count" -eq 0 ]; then
    unused_packages+=("$package")
  fi
done

# Output the list of unused packages
if [ ${#unused_packages[@]} -eq 0 ]; then
  echo "No unused packages found!"
else
  echo ""
  echo "Unused packages detected:"
  for pkg in "${unused_packages[@]}"; do
    echo "$pkg"
  done
fi
