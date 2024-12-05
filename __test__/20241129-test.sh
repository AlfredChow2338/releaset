INFO_FILE="./test.json"
LAST_UPDATED_KEY="last_update_pr_tag"
LAST_UPDATED_DT_KEY="last_update_pr_tag_dt"

# Check if the file exists and is a regular file
if [[ -f "$INFO_FILE" ]]; then
    # Extract the 'update' key's value
    last_tag=$(awk -F'[":,]+' '/'"$LAST_UPDATED_KEY"'/ {print $4}' "$INFO_FILE")
    # Extract the 'update_dt' key's value
    last_tag_dt=$(awk -F'[":,]+' '/'"$LAST_UPDATED_DT_KEY"'/ {print $4}' "$INFO_FILE")
fi

echo "last tag: $last_tag"
echo "last tag dt: $last_tag_dt"

latest_tag="v2.2"
latest_tag_date="2023-12-11"

# Function to update or add a key
update_or_add_key() {
    local key="$1"
    local value="$2"

    SED_INPLACE=""

    if [[ "$OSTYPE" == "darwin"* ]]; then
        SED_INPLACE="-i ''"  # macOS requires an empty extension for in-place editing
    else
        SED_INPLACE="-i"     # Linux
    fi

    # Ensure the file exists and is a valid JSON object
    if [ ! -s "$INFO_FILE" ] || ! grep -q "{" "$INFO_FILE"; then
        echo "{}" > "$INFO_FILE"
    fi

    # Check if the key exists
    if grep -q "\"$key\": " "$INFO_FILE"; then
        # Key exists, update it
        # This regex ensures we don't capture more than we need by being specific with our patterns
        sed $SED_INPLACE "s/\"$key\": \"[^\"]*\"/\"$key\": \"$value\"/" "$INFO_FILE"
    else
        # Key does not exist, add it
        if grep -q "^{}$" "$INFO_FILE"; then
            # File has only empty JSON, directly add key without comma
            sed $SED_INPLACE "s/{}/{\"$key\": \"$value\"}/" "$INFO_FILE"
        else
            # File is non-empty, append key before the last closing brace
            # This ensures that we correctly find the last closing brace even when it's not at the very end
            sed $SED_INPLACE "s/\(.*\)}$/\1, \"$key\": \"$value\"}/" "$INFO_FILE"
        fi
    fi
}

# Usage of the function
update_or_add_key "$LAST_UPDATED_KEY" "$latest_tag"
update_or_add_key "$LAST_UPDATED_DT_KEY" "$latest_tag_date"

if [ -e "$INFO_FILE''" ]; then
    rm -f "$INFO_FILE''"
fi

# raw_json=(cat $INFO_FILE | sed ':a;N;$!ba;s/\n//g' | sed 's/ //g')

echo "1:"
cat $INFO_FILE

if [[ -e "$INFO_FILE" ]] && [[ $(wc -l < "$INFO_FILE") -gt 1 ]]; then
    raw_json=$(sed -e ':a' -e 'N' -e '$!ba' -e 's/\n//g' -e 's/": \?"/": "/g' -e 's/, \?"/,"/g' "$INFO_FILE")
    rm -f $INFO_FILE
    echo "$raw_json" > "$INFO_FILE"
fi

echo "2:"
cat $INFO_FILE

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
}' "$INFO_FILE")

rm -f $INFO_FILE
echo "$formatted_json" > "$INFO_FILE"

echo "3:"
cat $INFO_FILE