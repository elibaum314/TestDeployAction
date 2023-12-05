 #!/bin/bash

# if [ $# -ne 2 ]; then
#     echo "Usage: $0 <hash1> <hash2>"
#     exit 1
# fi

hash1=$1
hash2=$2

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

files=()
objects=()

while IFS= read -r line; do


    if [[ "$line" == src/FileCabinet/* ]]; then
        # replace src/ with ~/
        line=${line/src\//\~\/}
        files+=("$line")
    elif [[ "$line" == src/Objects/* ]]; then
        line=${line/src\//\~\/}
        objects+=("$line")
    fi
done < <(git diff --name-only $hash1 $hash2 | grep -e "^src/FileCabinet/SuiteScripts*" -e "^src/Objects")

if [ ${#files[@]} -eq 0 ] && [ ${#objects[@]} -eq 0 ]; then
    echo "No files or objects found to deploy."
    exit 1
fi

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
} > deploy.xml

echo "XML file generated: deploy.xml"
