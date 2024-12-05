#!/bin/bash

read_file_by_key() {
    local key="$1"
    local filename="$2"

    grep "^$key=" "$filename" | cut -d'=' -f2
}

write_file_by_key_value() {
    local key="$1"
    local value="$2"
    local filename="$3"

    touch "$filename"

    if grep -q "^$key=" "$filename"; then
        sed -i.bak "/^$key=/d" "$filename"
        echo "$key=$value" >> "$filename"
    else
        echo "$key=$value" >> "$filename"
    fi
}

read_json_key() {
    local key="$1"
    local file="$2"

    awk -F '"' "/$key/ {print \$4}" "$file"
}

update_json_key() {
    local key="$1"
    local value="$2"
    local filename="$3"

    SED_INPLACE=""

    if [[ "$OSTYPE" == "darwin"* ]]; then
        SED_INPLACE="-i ''"  # macOS requires an empty extension for in-place editing
    else
        SED_INPLACE="-i"     # Linux
    fi

    # Ensure the file exists and is a valid JSON object
    if [ ! -s "$filename" ] || ! grep -q "{" "$filename"; then
        echo "{}" > "$filename"
    fi

    # Check if the key exists
    if grep -q "\"$key\": " "$filename"; then
        # Key exists, update it
        # This regex ensures we don't capture more than we need by being specific with our patterns
        sed $SED_INPLACE "s/\"$key\": \"[^\"]*\"/\"$key\": \"$value\"/" "$filename"
    else
        # Key does not exist, add it
        if grep -q "^{}$" "$filename"; then
            # File has only empty JSON, directly add key without comma
            sed $SED_INPLACE "s/{}/{\"$key\": \"$value\"}/" "$filename"
        else
            # File is non-empty, append key before the last closing brace
            # This ensures that we correctly find the last closing brace even when it's not at the very end
            sed $SED_INPLACE "s/\(.*\)}$/\1, \"$key\": \"$value\"}/" "$filename"
        fi
    fi
}