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

CORE_BRANCH=stable30

declare -A STABLE_BRANCHES
STABLE_BRANCHES=(
    [contacts]=stable6.0
    [calendar]=stable4.7
)

declare -A BUILD_COMMANDS
BUILD_COMMANDS=(
    [bav]="make"
    [cafevdb]="make build"
    [cafevdbmembers]="make build"
    [calendar]="run-krankerl.sh"
    [maps]="make"
    [richdocuments]="run-krankerl.sh"
    [workflow_pdf_converter]="run-krankerl.sh"
    [twofactor_gateway]="run-krankerl.sh"
    [groupfolders]="make"
    [files_lock]="run-krankerl.sh"
    [mail]="make install-deps optimize-js"
)

declare -A REBASE_BRANCHES
REBASE_BRANCHES=(
    [richdocuments]=stable30
    [calendar]=stable4.7
    [workflow_pdf_converter]=stable30
    [twofactor_gateway]=master
    [mail]=stable3.7
)

BUILD=false
REBASE=false

NCDIR=$(realpath .)

VALID_ARGS=$(getopt -o br --long build,rebase -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi

eval set -- "$VALID_ARGS"
while [ : ]; do
  case "$1" in
    -b|--build)
        BUILD=true
        shift
        ;;
    -r|--rebase)
        REBASE=true
        shift
        ;;
    --) shift;
        break
        ;;
  esac
done

for i in $APPS; do
    echo
    cd $NCDIR/apps/$i
    if ! [ -e .git ]; then
        cd $NCDIR
        continue
    fi
    BRANCH=$(git status |grep -i "On branch"|awk '{ print $3; }')
    # REMOTE=$(git rev-parse --abbrev-ref --symbolic-full-name @{u})
    if [ -n "${STABLE_BRANCHES[$i]}" ]; then
        STABLE_BRANCH=${STABLE_BRANCHES[$i]}
    else
        STABLE_BRANCH=$CORE_BRANCH
    fi
    echo "** Updating $i@$BRANCH **"
    git fetch --all -p
    case $BRANCH in
        $STABLE_BRANCH)
            ;;
        stable*)
            echo "Updating to $STABLE_BRANCH"
            git checkout $STABLE_BRANCH
            ;;
    esac
    case $BRANCH in
        stable*|master)
            echo "Performing simple pull from upstream"
            git pull
            echo
            cd $NCDIR
            continue
            ;;
    esac
    if $BUILD && [ -n "${BUILD_COMMANDS[$i]}" ]; then
        echo "*** Rebuilding $i ***"
        ${BUILD_COMMANDS[$i]} || exit 1
    fi
    if $REBASE && [ -n "${REBASE_BRANCHES[$i]}" ]; then
        echo "*** Rebasing $i to ${REBASE_BRANCHES[$i]} ***"
        git rebase ${REBASE_BRANCHES[$i]} || exit 1
    fi
    echo
    cd $NCDIR
done
