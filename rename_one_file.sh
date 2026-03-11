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
    : "${1:?ERROR: The output mode has to be given as first argument (int from -1 to 2).}"
    : "${2:?ERROR: An absolute filepath has to be gives as the first argument.}"

    # save the output mode
    output_mode="$1"
    args="$2"
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
function is_file {
    # check wether the arg is a regular file or a dir
    if [[ -f "$1" ]]; then
        return 0
    else
        return 1
    fi
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
function clean_name {
    # clean_names the file given by the first arg
    local raw_filename="${1##*/}"
    local improved_filename="$raw_filename"

    # replace all spaces by _
    improved_filename="${improved_filename//[[:space:]]/_}"
    #echo "DEBUG: after replacing spaces: $improved_filename"

    # unicode transliterate characters to ACII # TODO make this work
    improved_filename="$(echo $improved_filename | iconv -f utf-8 -t ASCII//TRANSLIT)"

    # removing all the characters that are not in the whitelist
    improved_filename="$(echo $improved_filename | sed 's/[^a-zA-Z0-9._-]//g')"
    #echo "DEBUG: after whitelist: $improved_filename"

    # replace duplicate . - _ by non-duplicate versions
    improved_filename="$(echo $improved_filename | sed -E 's/-+/-/g; s/_+/_/g; s/\.+/\./g')"
    #echo "DEBUG: after . _ - duplicate: $improved_filename"

    # remove leading and trailing _ and - and trailing .
    improved_filename=$(echo "$improved_filename" | sed -E 's/^-+//; s/^_+//; s/_+$//; s/-+$//; s/\.$//')

    # replace -_ and _- by _
    improved_filename="${improved_filename//-_/_}"
    improved_filename="${improved_filename//_-/_}"

    # replace ._ and _. by .
    improved_filename="${improved_filename//\._/\.}"
    improved_filename="${improved_filename//_\./\.}"

    # re-replace duplicate . - _ by non-duplicate versions to avoid double __ after ._ -_ replacements
    improved_filename="$(echo $improved_filename | sed -E 's/-+/-/g; s/_+/_/g; s/\.+/\./g')"
    #echo "DEBUG: after . _ - duplicate: $improved_filename"

    # check if the filename is not nothing
    if [[ -z "$improved_filename" ]]; then
        log "WARNING" "Counld not clean the name of ${raw_filename}, because it would be empty. It will stay as it is, so please rename it manually." 0
        return 0
    fi
    # add file creation date to the beginning if it does not exist and it is a regular file
    if is_file "$1"; then
        if [[ ! "$improved_filename" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
            local file_creation_date="$(stat -c '%w' "$1" | awk ' { print $1 } ')"
            # only add the creation date to the beginning of the file if it is not '-'
            if [[ "$file_creation_date" != '-' ]]; then
                improved_filename="${file_creation_date}_${improved_filename}"
            fi
        fi
    fi

    # save destination path & actually rename the file
    local dest_path="${1%/*}/${improved_filename}"
    if [[ "$1" == "$dest_path" ]]; then
        log "INFO" "$1 and $dest_path are the same. $1 seems to have a non-problematic name already." 2
    else
        log "INFO" "Renaming $1 -> $dest_path" 1
        if ! mv "$1" "$dest_path"; then
            log "ERROR" "ERROR while executing: mv $1 $dest_path." -2
            false
        fi
    fi
}
function init {
    # save the output mode
    output_mode="$1"
    args="$2"
    # check if the list file exists
    if ! file_exists "$args"; then
        log "ERROR" "The list file does not exist!" -2
        exit 1
    fi
}

function main {
    init "$@"
    clean_name "$args"
}

# check if a filename has been gives as the first argument
check_args "$@"
# call main with all args, as given
main "$@"
