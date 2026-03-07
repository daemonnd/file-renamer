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
    # delete all the previous test dirs
    rm -r ./testing/
    rm -r ./auto_rename_test/

    # re-create the dirs
    mkdir ./testing/
    mkdir ./auto_rename_test/
    
    # create testing dirs
    mkdir -p ./testing/'badly name d *-+ dir  ???!'/'cool @ home'

    # touch testing files
    touch ./testing/'****-,#'
    touch ./testing/'pa ss wd )(])'
    touch './testing/badly name d *-+ dir  ???!'/'___ver yy r ==== bad #,; named fil e .pg--'
    touch ./testing/'badly name d *-+ dir  ???!'/'cool @ home'/'my uplgy % fil?e.*'

    touch ./testing/'2026-04-99_graet name d  file-'
    touch ./auto_rename_test/2026-01-23_file
}

# call main with all args, as given
main "$@"

