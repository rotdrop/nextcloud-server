#!/bin/bash

export LC_ALL=C

APPS="
 activity
 bav
 cafevdb
 cafevdbmembers
 calendar
 circles
 collectives
 contacts
 dokuwiki
 emlviewer
 files_archive
 files_automatedtagging
 files_lock
 files_pdfviewer
 files_rightclick
 files_texteditor
 groupfolders
 ldap_contacts_backend
 ldap_write_support
 logreader
 mail
 mail_roundcube
 maps
 notifications
 password_policy
 pdf_downloader
 photos
 privacy
 recognize
 recommendations
 redaxo
 richdocuments
 serverinfo
 spreed
 suspicious_login
 text
 twofactor_gateway
 twofactor_totp
 user_sql
 viewer
 workflow_pdf_converter
"

declare -A BUILD_COMMANDS
declare -A REBASE
BUILD_COMMANDS=(
    [bav]="make"
    [cafevdb]="make build"
    [cafevdbmembers]="make build"
    [calendar]="run-krankerl.sh"
)

REBASE=(
    [richdocuments]=stable27
    [calendar]=stable4.6
)

NCDIR=$(realpath .)

for i in $APPS; do
    cd $NCDIR/apps/$i
    if ! [ -e .git ]; then
        cd $NCDIR
        continue
    fi
    BRANCH=$(git status |grep -i "On branch"|awk '{ print $3; }')
    REMOTE=$(git rev-parse --abbrev-ref --symbolic-full-name @{u})
    echo "** Updating $i@$BRANCH **"
    git fetch --all -p
    case $BRANCH in
        stable*|master)
            echo "Performing simple pull from upstream"
            git pull
            cd $NCDIR
            continue
            ;;
    esac
    echo
    cd $NCDIR
done
