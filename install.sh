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
trap 'cleanup' INT TERM ERR

function check_args {
    echo 
}

function main {
    cp rename_one_file.sh /usr/local/bin/rename_one_file.sh
    cp file-renamer.sh /usr/local/bin/file-renamer
    chmod 755 /usr/local/bin/file-renamer
}

# call main with all args, as given
main "$@"

