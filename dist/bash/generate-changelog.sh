#!/bin/bash

PROJECT_NAME=$1
IS_DEV=$2
PR_TAG=$3
REPO_URL=$4
FILTERED_TAG=$5
OUT_DIR=$6

remove_first_line() {
    local filename="$1" 

    if [ -f "$filename" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' '1d' "$filename"
        else
            # Linux system
            sed -i '1d' "$filename"
        fi
        echo "First line removed from $filename."
    else
        echo "File does not exist."
    fi
}

INFO_FILE="$OUT_DIR/releaset-info.json"

mkdir -p "$OUT_DIR"

if $IS_DEV; then
    OUTPUT_FILE="$OUT_DIR/CHANGELOG_PR.md"
    LAST_UPDATED_KEY="last_pr_update_tag"
    LAST_UPDATED_DT_KEY="last_pr_update_tag_dt"
    FILTER_FLAG=""
else
    OUTPUT_FILE="$OUT_DIR/CHANGELOG.md"
    LAST_UPDATED_KEY="last_update_tag"
    LAST_UPDATED_DT_KEY="last_update_tag_dt"
    FILTER_FLAG="-v "
fi

# Read the last processed tag from info.json
if [[ -f "$INFO_FILE" ]]; then
    last_tag=$(jq -r ".$LAST_UPDATED_KEY // empty" "$INFO_FILE")
    last_tag_dt=$(jq -r ".$LAST_UPDATED_DT_KEY // empty" "$INFO_FILE")
fi

# Fetch tags, considering the last processed tag to filter out older tags
if [[ -z "$last_tag_dt" ]]; then
    echo "# $PROJECT_NAME" > $OUTPUT_FILE
    
    if [[ -z "$PR_TAG" ]]; then
        if [[ -z "$FILTERED_TAG" ]]; then
            tags=$(git tag --list --sort=-creatordate)
        else
            tags=$(git tag --list --sort=-creatordate | grep $FILTERED_TAG)
        fi    
    else
        if [[ -z "$FILTERED_TAG" ]]; then
            tags=$(git tag --list --sort=-creatordate | grep $FILTER_FLAG$PR_TAG)
        else
            tags=$(git tag --list --sort=-creatordate | grep $FILTER_FLAG$PR_TAG | grep $FILTERED_TAG)
        fi
    fi
    
else
    log_existed=true
    ORIGINAL_FILE=$OUTPUT_FILE
    OUTPUT_FILE="$OUT_DIR/CHANGELOG_TEMP.md"
    NEW_OUTPUT_FILE="$OUT_DIR/CHANGELOG_NEW.md"
    echo "# $PROJECT_NAME" > $OUTPUT_FILE

    if [[ -z "$PR_TAG" ]]; then
        if [[ -z "$FILTERED_TAG" ]]; then
            tags=$(git for-each-ref --format='%(refname:short) %(creatordate:iso8601)' refs/tags | sort -rk2 | awk -v date=$last_tag_dt '$2 > date { print $1 }')
        else
            tags=$(git for-each-ref --format='%(refname:short) %(creatordate:iso8601)' refs/tags | grep $FILTERED_TAG | sort -rk2 | awk -v date=$last_tag_dt '$2 > date { print $1 }')
        vi
    else
        if [[ -z "$FILTERED_TAG" ]]; then
            tags=$(git for-each-ref --format='%(refname:short) %(creatordate:iso8601)' refs/tags | grep $FILTER_FLAG$PR_TAG | sort -rk2 | awk -v date=$last_tag_dt '$2 > date { print $1 }')
        else
            tags=$(git for-each-ref --format='%(refname:short) %(creatordate:iso8601)' refs/tags | grep $FILTERED_TAG | grep $FILTER_FLAG$PR_TAG | sort -rk2 | awk -v date=$last_tag_dt '$2 > date { print $1 }')
        vi
    fi

fi

counter=0 

latest_tag=""
latest_tag_date=""

echo $tags

for tag in $tags; do
    # First iteration
    if [ $counter -eq 0 ]; then
        latest_tag=$tag  # Set latest_tag on the first iteration
        latest_tag_date=$(git log -1 --format=%cI $tag)  # Get the commit date in ISO format
    fi
    
    # Check if there is a previous tag to set the range
    prev_tag=$(git describe --tags --abbrev=0 $tag^ 2>/dev/null)
    
    if [ -z "$prev_tag" ]; then
        # If there's no previous tag, list everything up to the current tag
        range="$tag"
    else
        # Otherwise list everything from the previous tag to the current tag
        range="$prev_tag..$tag"
    fi
    
    # Print the tag and date
    tag_date=$(git log -1 --format=%ai $tag)
    echo "## \`$tag\` - $tag_date" >> $OUTPUT_FILE
    echo "" >> $OUTPUT_FILE
    
    # List commits
    git log $range --no-merges --format="* [%h]($REPO_URL/commits/%H) - %s - %an (%aI)" >> $OUTPUT_FILE
    echo "" >> $OUTPUT_FILE
    
    counter=$((counter + 1))
    
done

if [ ! -z "$latest_tag" ]; then
    
    if [[ ! -f "$INFO_FILE" ]]; then
      echo "{}" > "$INFO_FILE"
    fi

    jq --arg latest_tag "$latest_tag" --arg latest_tag_date "$latest_tag_date" \
       --arg update_key "$LAST_UPDATED_KEY" --arg date_key "$LAST_UPDATED_DT_KEY" \
       '.[$update_key] = $latest_tag | .[$date_key] = $latest_tag_date' \
       "$INFO_FILE" > "$INFO_FILE.tmp" && mv "$INFO_FILE.tmp" "$INFO_FILE"
fi

if [[ $log_existed = true ]]; then
    remove_first_line "$ORIGINAL_FILE"
    cat $OUTPUT_FILE $ORIGINAL_FILE >> $NEW_OUTPUT_FILE
    mv -f "$NEW_OUTPUT_FILE" "$ORIGINAL_FILE"
    rm $OUTPUT_FILE $NEW_OUTPUT_FILE 2> /dev/null
fi

echo "Changelog generation complete. See $OUTPUT_FILE"