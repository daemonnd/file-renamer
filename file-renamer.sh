#!/bin/bash

# strict mode
set -Eeuo pipefail

# Cleanup function
function cleanup {
    echo "Script interupted or failed. Cleaning up..."

    # remove tmp files

    # exit the script, preserving the exit code
    exit "$?"
}

# trap errors
trap 'echo "Error on line $LINENO: command \"$BASH_COMMAND\" exited with status $?" >&2' ERR
# trap signals
trap 'cleanup' INT TERM 

function check_args {
    echo 
}
function file_exists {
    echo "${@@Q}"
    if [[ ! -e "$1" ]]; then 
        echo "File ${1@Q} does not exist!"
        return 1
    else
        return 0
    fi
}
function rename {
    echo "${@@Q}"
    # renames the file/dirname given by the first arg
    local raw_filename="${1##*/}"
    local dest_path="${1%/*}/${raw_filename// /_}"
    echo "how the final mv path would look like: $1 and then $dest_path"
    if [[ ! "$1" == "$dest_path" ]]; then
        mv "$1" "$dest_path"
    else
        echo "$1 and $dest_path are the same. $1 seems to have a non-problematic name already."
    fi
    #mv "$1" "$dest_path"
}

function main {
    for file in "$@"; do
        if file_exists "$file"; then
            rename "$file"
        else
            echo "file ${file@Q} does not exist!"
        fi
    done
}

# call main with all args, as given
main "$@"

