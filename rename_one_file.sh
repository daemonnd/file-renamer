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
    echo "listfile:"
    echo "${1:?ERROR: An absolute filepath has to be gives as the first argument.}"
    echo
}
function file_exists {
    # check wether $1 exists or not, return 1 if not, return 0 if yes
    if [[ ! -e "$1" ]]; then 
        echo "File ${1@Q} does not exist!"
        return 1
    else
        return 0
    fi
}
function clean_name {
    # clean_names the file given by the first arg
    local raw_filename="${1##*/}"
    local improved_filename="$raw_filename"
    echo "$improved_filename raw filename"

    blacklist_characters=(':' '.' '#' '+' '\*' '~' '(' ')' '[' ']' '{' '}')

    for char in "${blacklist_characters[@]}"; do
        echo "$char"
        local improved_filename="${improved_filename//$char}"
        echo "imporved filename: $improved_filename"
    done
    local dest_path="${1%/*}/${improved_filename// /_}"
    echo "how the final mv path would look like: $1 and then $dest_path"
    if [[ ! "$1" == "$dest_path" ]]; then
        #mv "$1" "$dest_path"
        echo # TODO
    else
        echo "$1 and $dest_path are the same. $1 seems to have a non-problematic name already."
    fi
    #mv "$1" "$dest_path"
}
function init {
    # initialize the script by checking if the dirs in the list file exist, and saving all the paths in an array

    # check if the list file exists
    if ! file_exists "$1"; then
        echo "ERROR: The list file does not exist!"
        exit 1
    fi

    # save all the dir paths in an array
}

function main {
    init "$1"
    clean_name "$1"
}

# check if a filename has been gives as the first argument
check_args "$@"
# call main with all args, as given
main "$@"

