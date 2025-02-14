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
 twofactor_email
 twofactor_gateway
 twofactor_totp
 user_sql
 viewer
 workflow_pdf_converter
"

CORE_BRANCH=stable30

declare -A STABLE_BRANCHES
STABLE_BRANCHES=(
    [contacts]=stable7.0
    [calendar]=stable5.1
)

declare -A BUILD_COMMANDS
BUILD_COMMANDS=(
    [bav]="make"
    [cafevdb]="make build"
    [cafevdbmembers]="make build"
    [calendar]="run-krankerl.sh"
    [collectives]="make setup-dev node-modules build-js-production composer-install-no-dev"
    [files_lock]="run-krankerl.sh"
    [groupfolders]="make"
    [mail]="make install-deps optimize-js"
    [maps]="make"
    # TODO: remove photos git
    [photos]="make dev-setup build-js-production && rm -rf vendor/* && composer install --no-dev"
    [richdocuments]="run-krankerl.sh"
    [twofactor_gateway]="run-krankerl.sh"
    [workflow_pdf_converter]="run-krankerl.sh"
)

declare -A REBASE_BRANCHES
REBASE_BRANCHES=(
    [calendar]=origin/stable5.0
    [files_lock]=origin/stable30
    [groupfolders]=origin/stable30
    [mail]=origin/stable4.1
    [maps]=origin/release
    [richdocuments]=origin/stable30
    [twofactor_gateway]=origin/master
    [workflow_pdf_converter]=origin/stable30
)

BUILD=false
REBASE=false
STATUS=false

NCDIR=$(realpath .)

VALID_ARGS=$(getopt -o bro:s --long build,rebase,only:,status -- "$@")
# shellcheck disable=SC2181
if [[ $? -ne 0 ]]; then
    exit 1;
fi

eval set -- "$VALID_ARGS"
while true; do
  case "$1" in
    -b|--build)
        BUILD=true
        shift
        ;;
    -r|--rebase)
        REBASE=true
        shift
        ;;
    -o|--only)
        APPS=$2
        shift 2
        ;;
    -s|--status)
        STATUS=true
        shift
        ;;
    --) shift;
        break
        ;;
  esac
done

declare -A ATTENTION

SHORT_PWD=$(basename "$(pwd)")
CMD=$(basename "$0")

function setTitle
{
    if [ -n "$1" ]; then
        echo -ne "\033]2;.../$SHORT_PWD - $CMD: $1\007"
    else
        echo -ne "\033]2;\007"
    fi
}

for APP in $APPS; do
    setTitle "$APP"
    cd "$NCDIR/apps/$APP" || exit 1
    if ! [ -e .git ]; then
        cd "$NCDIR" || exit 1
        continue
    fi
    if $STATUS; then
        APP_STATUS=$(git status)
        case "$APP_STATUS" in
            *diverged*)
                ATTENTION[$APP]=diverged
                ;;
            *)
                ;;
        esac
        cd "$NCDIR" || exit 1
        continue
    fi
    echo
    BRANCH=$(git status |grep -i "On branch"|awk '{ print $3; }')
    # REMOTE=$(git rev-parse --abbrev-ref --symbolic-full-name @{u})
    if [ -n "${STABLE_BRANCHES[$APP]}" ]; then
        STABLE_BRANCH=${STABLE_BRANCHES[$APP]}
    else
        STABLE_BRANCH=$CORE_BRANCH
    fi
    echo "** Updating $APP@$BRANCH **"
    setTitle "$APP (git fetch)"
    git fetch --all -p
    case $BRANCH in
        "$STABLE_BRANCH")
            ;;
        stable*)
            setTitle "$APP (git checkout $STABLE_BRANCH)"
            echo "Updating to $STABLE_BRANCH"
            git checkout "$STABLE_BRANCH"
            ;;
    esac
    case $BRANCH in
        stable*|master|main)
            setTitle "$APP (git pull from $BRANCH)"
            echo "Performing simple pull from upstream"
            git pull
            ;;
    esac
    if $REBASE && [ -n "${REBASE_BRANCHES[$APP]}" ]; then
        setTitle "$APP (git rebase ${REBASE_BRANCHES[$APP]})"
        echo "*** Rebasing $APP to ${REBASE_BRANCHES[$APP]} ***"
        git checkout . || exit 1
        git rebase "${REBASE_BRANCHES[$APP]}" || exit 1
    fi
    if $BUILD && [ -n "${BUILD_COMMANDS[$APP]}" ]; then
        setTitle "$APP (build)"
        echo "*** Rebuilding $APP ***"
        { eval "${BUILD_COMMANDS[$APP]}"; } || exit 1
    fi
    echo
    setTitle
    cd "$NCDIR" || exit 1
done

for x in "${!ATTENTION[@]}"; do
    printf "[%s]=%s\n" "$x" "${ATTENTION[$x]}"
done
