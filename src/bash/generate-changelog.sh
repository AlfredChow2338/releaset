#!/bin/bash

PROJECT_URL=$1
TITLE=$2
IS_DEV=$3
PR_TAG=$4
FILTERED_TAG=$5
OUT_DIR=$6
FILTER_COMMIT=$7

# import files
source "$(dirname "$0")/utils.sh"

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

INFO_FILE=".releaset/info.json"
PUBLISH_NOTE_FILE=".releaset/publish_note.json"

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
    last_tag=$(read_json_key "$LAST_UPDATED_KEY" "$INFO_FILE" )    
    last_tag=$(read_json_key "$LAST_UPDATED_DT_KEY" "$INFO_FILE" )
fi

# Fetch tags, considering the last processed tag to filter out older tags
if [[ -z "$last_tag_dt" ]]; then
    if [[ -z "$TITLE" ]]; then
        echo "" > $OUTPUT_FILE
    else
        echo "# $TITLE" > $OUTPUT_FILE
    fi
    
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
    
    if [[ -z "$TITLE" ]]; then
        echo "" > $OUTPUT_FILE
    else
        echo "# $TITLE" > $OUTPUT_FILE
    fi

    if [[ -z "$PR_TAG" ]]; then
        if [[ -z "$FILTERED_TAG" ]]; then
            tags=$(git for-each-ref --format='%(refname:short) %(creatordate:iso8601)' refs/tags | sort -rk2 | awk -v date=$last_tag_dt '$2 > date { print $1 }')
        else
            tags=$(git for-each-ref --format='%(refname:short) %(creatordate:iso8601)' refs/tags | grep $FILTERED_TAG | sort -rk2 | awk -v date=$last_tag_dt '$2 > date { print $1 }')
        fi
    else
        if [[ -z "$FILTERED_TAG" ]]; then
            tags=$(git for-each-ref --format='%(refname:short) %(creatordate:iso8601)' refs/tags | grep $FILTER_FLAG$PR_TAG | sort -rk2 | awk -v date=$last_tag_dt '$2 > date { print $1 }')
        else
            tags=$(git for-each-ref --format='%(refname:short) %(creatordate:iso8601)' refs/tags | grep $FILTERED_TAG | grep $FILTER_FLAG$PR_TAG | sort -rk2 | awk -v date=$last_tag_dt '$2 > date { print $1 }')
        fi
    fi

fi

counter=0 

latest_tag=""
latest_tag_date=""

for tag in $tags; do
    # First iteration
    if [ $counter -eq 0 ]; then
        latest_tag=$tag  # Set latest_tag on the first iteration
        latest_tag_date=$(git log -1 --format=%cI $tag)  # Get the commit date in ISO format
    fi
    
    prev_tag=$(git describe --tags --abbrev=0 $tag^ 2>/dev/null)
    publish_note=$(awk -F '[:}]' -v tag="$tag" '
        $1 ~ tag {
            gsub(/"|,/, "", $2);
            print $2;
        }
    ' "$PUBLISH_NOTE_FILE")
    
    if [ -z "$prev_tag" ]; then
        # If there's no previous tag, list everything up to the current tag
        range="$tag"
    else
        # Otherwise list everything from the previous tag to the current tag
        range="$prev_tag..$tag"
    fi
    
    tag_date=$(git log -1 --format=%ai $tag)
    echo "## $tag - $tag_date" >> $OUTPUT_FILE
    echo "" >> $OUTPUT_FILE

    if [ -n "$publish_note" ]; then
        echo "### $publish_note" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi

    commit_hashes=$(git log $range --no-merges --format="%h")

    for commit_hash in $commit_hashes; do
        commit_message=$(git log -1 --format="%s" "$commit_hash")

        if echo "$commit_message" | grep "$FILTER_COMMIT" > /dev/null; then
            continue
        else
            git log -1 --no-merges --format="* [%h]($PROJECT_URL/commits/%H) - %s - %an (%aI)" "$commit_hash" >> $OUTPUT_FILE
        fi
    done

    echo "" >> $OUTPUT_FILE
    
    counter=$((counter + 1))
    
done

if [ ! -z "$latest_tag" ]; then
    
    if [[ ! -f "$INFO_FILE" ]]; then
      echo "{}" > "$INFO_FILE"
    fi

    update_json_key "$LAST_UPDATED_KEY" "$latest_tag" "$INFO_FILE"
    update_json_key "$LAST_UPDATED_DT_KEY" "$latest_tag_date" "$INFO_FILE"

    if [ -e "$INFO_FILE''" ]; then
        rm -rf "$INFO_FILE''"
        echo "Removed the file: $INFO_FILE''"
    fi

    if [[ -e "$INFO_FILE" ]] && [[ $(wc -l < "$INFO_FILE") -gt 1 ]]; then
        raw_json=$(sed -e ':a' -e 'N' -e '$!ba' -e 's/\n//g' -e 's/": \?"/": "/g' -e 's/, \?"/,"/g' "$INFO_FILE")
        rm -f $INFO_FILE
        echo "$raw_json" > "$INFO_FILE"
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
    }' "$INFO_FILE")

    rm -f $INFO_FILE
    echo "$formatted_json" > "$INFO_FILE"
fi

if [[ $log_existed = true ]]; then
    remove_first_line "$ORIGINAL_FILE"
    cat $OUTPUT_FILE $ORIGINAL_FILE >> $NEW_OUTPUT_FILE
    mv -f "$NEW_OUTPUT_FILE" "$ORIGINAL_FILE"
    rm $OUTPUT_FILE $NEW_OUTPUT_FILE 2> /dev/null
fi

if [[ $log_existed = true ]]; then
    echo "Changelog generation complete. See $ORIGINAL_FILE"
else
    echo "Changelog generation complete. See $OUTPUT_FILE"
fi