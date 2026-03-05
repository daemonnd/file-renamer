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
trap 'echo "Error on line $LINENO in rename_one_file.sh: command \"$BASH_COMMAND\" exited with status $?" >&2' ERR
# trap signals
trap 'cleanup' INT TERM 

function check_args {
    echo "${1:?ERROR: An absolute filepath has to be gives as the first argument.}"
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

    improved_filename="${improved_filename//[[:space:]]/_}"
    blacklist_characters=(':' '´' '&' '#' '+' '\*' '~' '\(' '\)' '\[' '\]' '{' '}' ',' '\?')

    # apply removing probelmatic characters
    for char in "${blacklist_characters[@]}"; do
        improved_filename="${improved_filename//$char}"
    done

    # add file creation date to the beginning if it does not exist
    if [[ ! "$improved_filename" =~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}'  ]]; then
        local file_creation_date="$(stat -c '%w' "$1" | awk ' { print $1 } ' )"
        # only add the creation date to the beginning of the file if it is not '-'
        if [[ "$file_creation_date" != '-' ]]; then
            improved_filename="${file_creation_date}_${improved_filename}"
        fi
    fi

    # replace __ with _
    improved_filename="${improved_filename//__/_}"

    # remove leading and trailing _ and -
    local trailing_leading='-_.'
    local pattern="[${trailing_leading}]*"
    improved_filename="${improved_filename##$pattern}"
    improved_filename="${improved_filename%%$pattern}"

    # save destination path & actually rename the file
    local dest_path="${1%/*}/${improved_filename}"
    echo "dest_path: $dest_path"
    if [[ "$1" == "$dest_path" ]]; then
        echo "$1 and $dest_path are the same. $1 seems to have a non-problematic name already."
    else
        echo "Renaming $1 -> $dest_path"
        if ! mv "$1" "$dest_path"; then
            echo "ERROR while executing `mv $1 $dest_path`."
            false
        fi
    fi
}
function init {
    # initialize the script by checking if the dirs in the list file exist, and saving all the paths in an array

    # check if the list file exists
    if ! file_exists "$1"; then
        echo "ERROR: The list file does not exist!"
        exit 1
    fi
}

function main {
    init "$1"
    clean_name "$1"
}

# check if a filename has been gives as the first argument
check_args "$@"
# call main with all args, as given
main "$@"

