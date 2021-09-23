#!/usr/bin/env bash

#
# Searches packages.ubuntu.com
# Author: Brad Frank
# Date: June 2021
# Tested: GNU bash, version 5.0.18(1)-release (x86_64-apple-darwin19.6.0)
# Requires: tidy, jq
#

main() {
    local blue='\033[0;34m' green='\033[0;32m' reset='\033[0m' output pkg desc
    output=$(mktemp)

    curl -s https://packages.ubuntu.com/search\?keywords="$1"\&searchon=names\&suite="${2:-hirsute}"\&section=all \
            | sed -n  '/<ul>/,/<\/ul>/p' \
            | grep -Ev "(^((\s*|\t*))*$|.*<br>.*)" \
            | tidy -asxml 2>/dev/null \
            | xq -cr '.html.body.ul[].li |
                "\(.a | if type == "object" then ."@href" else .[]."@href" end | split("/")[2]): \(."#text" | gsub("\n"; " ") | gsub(":"; ""))"' \
            | tr -d '[]' \
    > "$output"

    while read -r line; do
        pkg=$(awk -F: '{print $1}' <<< "$line")
        desc=$(awk -F: '{print $2}' <<< "$line")
        printf "${green}=>${reset} ${blue}%s:${reset}%s\n" "$pkg" "$desc"
    done < "$output"

    rm "$output"
}

[[ -z "$1" ]] && echo "Usage: aptsearch <package>" >&2
main "$1" "$2"
