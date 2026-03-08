# Automated File Renamer

This linux fs file renamer cleans the names of files and dirs that contain problemetic characters like spaces, \*, #, etc.
It is given a path to a file containing paths to dirs, where all the files in it get a cleaner name.
It works for user-made files but also for auto-generated files and is therefore great for a cron job for example.

## Installation

One-line install:

```bash
curl -fsSL https://raw.githubusercontent.com/daemonnd/file-renamer/main/install.sh | sudo bash
```

## Usage

```bash
file-renamer -v ~/path/to/file/containing/dirpaths/to/rename
# flags: -s; -v; -vv
without any flag:
file-renamer ~/path/to/file/containing/dirpaths/to/rename # only outputs the current dir from the appended file it is working on, warnings and errors
# with the -s flag:
file-renamer -s ~/path/to/file/containing/dirpaths/to/rename # outputs nothing except errors
# with the -v flag (recommended):
file-renamer -v ~/path/to/file/containing/dirpaths/to/rename # logs old_file_name -> new_file_name, only the files/dirs where the name actually changed, warings and errors
# with the -vv flag:
file-renamer -vv ~/path/to/file/containing/dirpaths/to/rename # logs everything from above, including the files that did not change their name
```

The only contents of the file appended as first arg is the dir paths (where all the children files and dirs will be renamed recursively) have to litterally be the dir paths and nothing else.

## Features

- rename files automatically
- remove problematic characters for linux fs
- control output with the -v and -s flags

## Limitations

- blacklist approach is fragile
- too much subprocesses whith a lot of files (what happens if it breaks while 50k subprocesses are running?)
- No filtering (regex) for selecting which files should be renamed

## How it works

1. It parses the flags to get the output old_file_name
2. It checks if the appended file exists and is readable
3. It iterates over each line in that file and gets all files recursively for this dir
4. For each file:
 4.1 It replaces all spaces by _
 4.2 It replaces all non-ACII characters by ACII characters (Unicode-tranliteration to ACII)
    4.3 It removes all the characters that are not in the whitelist (that only contains a-z, 0-9, ., -,_
    4.4 It checks if the filename is not nothing
        4.4.1 If the filename is nothing: The old one is kept and the file does not get renamed
        4.4.2 If the filename is not nothing, it still contains characters, it continues with step 4.5
    4.5 It removes all leading - and _and also removes all trailing . - and old_file_name
    4.6 It adds the file creation date (if it exists) to the beginning of the file
    4.7 It removes all duplicate - and_ and . (--, __, ..)
    4.8 The file gets renamed

## Status

In development
