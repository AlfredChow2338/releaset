FILTER_OUT_TAG=""
IS_DEV="false"
PR_TAG="pr"

if [ -n "$FILTER_OUT_TAG" ]; then
    echo "have filter out tag"
else
    echo "no filter out tag" # result
fi

FILTER_PR_FLAG=""

if $IS_DEV; then
    FILTER_PR_FLAG=""
else
    FILTER_PR_FLAG="-v "
fi

tags=$(git tag --sort=-creatordate 2>/dev/null)
echo $tags
if [ -n "$PR_TAG" ]; then
  echo "$FILTER_PR_FLAG$PR_TAG"
    tags=$(echo "$tags" | tr ' ' '\n' | grep $FILTER_PR_FLAG$PR_TAG | tr '\n' ' ')
fi
echo $tags