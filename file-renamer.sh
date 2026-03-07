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
    : "${1:?ERROR: A path to a list file containing dir paths have to be providen as first argument.}"
}
function calc_output_mode {
    # calculate the output mode with the -v and -s flags
    output_mode=$(($output_mode+$1))
}
function parse_flags {
    # parse the args
    # s = silent (no output except errors) output_mode=-1
    # default (no s nor v): only prints errors and the current dir processed in the given file output_mode=0
    # v = all errors, all filenames from -> to changed output_mode=1
    # vv = all errors, all filenames from --> to changed, also which filenames did not change output_mode=2
    output_mode=0 
    while getopts "sv" flag; do
        case "${flag}" in
            s) calc_output_mode -1;;
            v) calc_output_mode 1;;
        esac
    done
    shift "$((OPTIND-1))"
    args="$@"
}
function log {
    # logs the output depending on the output_mode
    # args: 
    # 1. loglevel (DEBUG, INFO, WARNING, ERROR, CRITICAL)
    # 2. logmessage
    # 3. min. output_mode
    if [[ "$3" -le "$output_mode" ]]; then
        echo "${1}: $2"
    fi
}
function file_exists {
    # check wether $1 exists or not, return 1 if not, return 0 if yes
    if [[ ! -e "$1" ]]; then 
        log "ERROR" "File ${1@Q} does not exist!" -2
        return 1
    else
        return 0
    fi
}
function dir_exists {
    # check wether $1 exists or not, return 1 if not, return 0 if yes
    if [[ ! -d "$1" ]]; then
        if ! file_exists "$1"; then
            log "ERROR" "${1@Q} does not exist!" -2
        else
            log "{1@Q}1 is not a dir!"
        fi
        return 1
    else
        if ! find "$1" -type d -empty | grep -q .; then
            return 0
        else
            echo "The dir $1 is empty!"
            return 1
        fi
    fi
    }
    function init {
        # initialize the script by checking if the dirs in the list file exist, and saving all the paths in an array

        # check if the list file exists
        if ! file_exists "$1"; then
            log "ERROR" "The list file does not exist!" -2
            exit 1
        fi

        # save all the dir paths in an array
        mapfile -t dirlist < <(cat "$1")

        for dir in "${dirlist[@]}"; do
            dir_exists "$dir"
        done

}

function main {
    parse_flags "$@"
    check_args "$args"
    init "$args"
    for dir in "${dirlist[@]}"; do
        log "INFO" "current dir: ${dir@Q}" 0
        find "${dir}" -mindepth 1 -depth -print0 | xargs -0 -L1 /usr/local/bin/rename_one_file.sh "$output_mode"
    done
}

# call main with all args, as given
main "$@"

