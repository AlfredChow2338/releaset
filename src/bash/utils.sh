#!/bin/bash

remove_first_line() {
    local filename="$1" 
    if [ -f "$filename" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' '1d' "$filename"
        else
            # Linux system
            sed -i '1d' "$filename"
        fi
    fi
}

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

    if [[ ! -f "$filename" ]]; then
      echo "{}" > "$filename"
    fi

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

    if [ -e "$filename''" ]; then
        rm -f "$filename''"
    fi

    if [[ -e "$filename" ]] && [[ $(wc -l < "$filename") -gt 1 ]]; then
        raw_json=$(sed -e ':a' -e 'N' -e '$!ba' -e 's/\n//g' -e 's/": \?"/": "/g' -e 's/, \?"/,"/g' "$filename")
        rm -f $filename
        echo "$raw_json" > "$filename"
    fi

    formatted_json=$(awk 'BEGIN {
        FS=",";
        print "{"
    }
    {
        gsub(/[{}]/, "");
        n = split($0, a, ",");
        for (i = 1; i <= n; i++) {
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", a[i]);
            print "  " a[i] (i < n ? "," : "");
        }
    }
    END {
        print "}"
    }' "$filename")

    rm -f $filename
    echo "$formatted_json" > "$filename"
}

update_publish_note() {
    local ver="$1"
    local note="$2"
    local json_file="$3"

    if [[ ! -f "$json_file" ]]; then
        echo "Error: $json_file not found."
        return 1
    fi

    # Read the last two lines of the JSON file
    last_line=$(tail -n 1 "$json_file")
    second_last_line=$(tail -n 2 "$json_file" | head -n 1)

    # Prepare the new line to append
    new_line="$ver: $note"

    if [[ -z "$second_last_line" ]]; then
    # If the second last line is empty, append the new line directly
    sed -i '$s/$/'"$new_line"'/' "$json_file"
    else
    # If the second last line is not empty, append a comma and the new line
    sed -i '$s/$/,/' "$json_file"
    echo "$new_line" >> "$json_file"
    fi
}