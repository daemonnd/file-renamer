# Automated File Renamer
This linux fs file renamer cleans the names of files and dirs that contain problemetic characters like spaces, \*, #, etc.
It is given a path to a file containing paths to dirs, where all the files in it get a cleaner name. It works for user-made files but also for auto-generated files and is therefore great for a cron job for example.

# Installation
One-line install:
```bash
curl -fsSL https://raw.githubusercontent.com/daemonnd/file-renamer/main/install.sh | sudo bash
```

# Usage
```bash
file-renamer ~/path/to/file/containing/dirpaths/to/rename
```

The only contents of the file appended as first arg is the dir paths (where all the children files and dirs will be renamed recursively) have to litterally be the dir paths and nothing else.

# Features
- rename files automatically
- remove problematic characters for linux fs


# Status
in development
