#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Replace with the relative path to your Xcode project and target names
PROJECT_RELATIVE_PATH="../Projects/App/Ugglan.xcodeproj"
TARGET_NAME="Ugglan"

# Construct the full path to the project file
#PROJECT_PATH="$SCRIPT_DIR/$PROJECT_RELATIVE_PATH"
PROJECT_PATH="$( cd "$SCRIPT_DIR/$(dirname "$PROJECT_RELATIVE_PATH")" && pwd )/$(basename "$PROJECT_RELATIVE_PATH")"


# Locate and update the setting only where the name is "Embed App Extensions"
sed -i '' -E "/name = \"Embed App Extensions\";/,/\};/ s/(runOnlyForDeploymentPostprocessing = )0;/\11;/g" "$PROJECT_PATH/project.pbxproj"

echo "Setting updated successfully!"
