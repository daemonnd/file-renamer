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
trap 'echo "Error on line $LINENO in file-renamer.sh: command \"$BASH_COMMAND\" exited with status $?" >&2' ERR
# trap signals
trap 'cleanup' INT TERM 

function check_args {
    echo "${1:?ERROR: A path to a list file containing dir paths have to be providen as first argument.}"
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
function dir_exists {
    # check wether $1 exists or not, return 1 if not, return 0 if yes
    if [[ ! -d "$1" ]]; then
        if [[ ! file_exists ]]; then
            echo "ERROR: ${1@Q} does not exist!"
        else
            echo "ERROR: ${1@Q}1 is not a dir!"
        fi
        return 1
    else
            return 0
        fi
    }
    function init {
        # initialize the script by checking if the dirs in the list file exist, and saving all the paths in an array

        # check if the list file exists
        if ! file_exists "$1"; then
            echo "ERROR: The list file does not exist!"
            exit 1
        fi

        # save all the dir paths in an array
        mapfile -t dirlist < <(cat "$1")

    for dir in "${dirlist[@]}"; do
        dir_exists "$dir"
    done

}

function main {
    check_args "$@"
    init "$@"
    for dir in "${dirlist[@]}"; do
        echo "current dir: ${dir@Q}"
        find "${dir}" -depth -print0 | xargs -0 -L1 /usr/local/bin/rename_one_file.sh
    done
}

# call main with all args, as given
main "$@"

