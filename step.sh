#!/bin/bash
set -ex

#
# --- Export Environment Variables for other Steps:
# You can export Environment Variables for other Steps with
#  envman, which is automatically installed by `bitrise setup`.
# A very simple example:
# envman add --key EXAMPLE_STEP_OUTPUT --value 'the value you want to share'
# Envman can handle piped inputs, which is useful if the text you want to
# share is complex and you don't want to deal with proper bash escaping:
#  cat file_with_complex_input | envman add --KEY EXAMPLE_STEP_OUTPUT
# You can find more usage examples on envman's GitHub page
#  at: https://github.com/bitrise-io/envman

#
# --- Exit codes:
# The exit code of your Step is very important. If you return
#  with a 0 exit code `bitrise` will register your Step as "successful".
# Any non zero exit code will be registered as "failed" by `bitrise`.

LF=$(printf '\n_');LF=${LF%_}

URL="${redmine_url}/projects/${redmine_project}/wiki/${redmine_wiki}.json?key=${personal_access_token}"

JSON=`curl "$URL"`
VERSION=`echo "$JSON" | jq -r '.wiki_page.version'`
# TEXT=`echo "$JSON" | jq '.wiki_page.text' | sed -E "s/^\"//" | sed -E "s/\"$//"`
TEXT=`echo "$JSON" | jq -r '.wiki_page.text'`
NEWTEXT=`echo "$TEXT\n\n${text}" | sed -e :loop -e 'N; $!b loop' -e 's/\n/\\\\n/g'`

BODY=$(cat << EOS
{
    "wiki_page": {
        "text": "${NEWTEXT}",
        "version": $VERSION
    }
}
EOS
)

curl "$URL" -X PUT -d "$BODY" -H "Content-Type: application/json"

exit 0
