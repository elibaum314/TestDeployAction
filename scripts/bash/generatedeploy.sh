#!/bin/bash

# Function to add paths to XML
add_paths_to_xml() {
    local type=$1
    shift
    local paths=("$@")
    echo "    <$type>"
    for path in "${paths[@]}"; do
        echo "        <path>$path</path>"
    done
    echo "    </$type>"
}

# Arrays to hold files and objects
files=()
objects=()

# Execute git command and process output
while IFS= read -r line; do
    if [[ "$line" == src/FileCabinet/* ]]; then
        files+=("$line")
    elif [[ "$line" == src/Objects/* ]]; then
        objects+=("$line")
    fi
done < <(git diff --name-only $(git merge-base remotes/origin/main HEAD) HEAD | grep -e "^src/FileCabinet/SuiteScripts*" -e "^src/Objects")

# Check if files and objects are found
if [ ${#files[@]} -eq 0 ] && [ ${#objects[@]} -eq 0 ]; then
    echo "No files or objects found to deploy."
    exit 1
fi

# Main script
{
    echo "<deploy>"

    # Files
    if [ ${#files[@]} -ne 0 ]; then
        add_paths_to_xml "files" "${files[@]}"
    fi

    # Objects
    if [ ${#objects[@]} -ne 0 ]; then
        add_paths_to_xml "objects" "${objects[@]}"
    fi

    echo "</deploy>"
} > output.xml

echo "XML file generated: output.xml"
