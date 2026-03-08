#!/bin/bash

# URL of the raw file
FILE_URL="https://raw.githubusercontent.com/berserkkv/xray/refs/heads/main/go.mod"

# Destination path
DEST_FILE="filename.ext"

# Download the file
wget -O $DEST_FILE $FILE_URL