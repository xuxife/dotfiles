#!/bin/bash
BACKUP=$(pwd)/backup
mkdir -p $BACKUP # mkdir a directory storing backup

function update() {
    SOURCE=$1
    TARGET=$2
    if [[ -e $TARGET ]]; then
        mv -f $TARGET $BACKUP
    fi
    ln -s $SOURCE $TARGET
}

update $(pwd)/hammerspoon ~/.hammerspoon