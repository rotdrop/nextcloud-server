#!/bin/bash

export LC_ALL=C

ALL_APPS="
 activity
 app_api
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
 files_lock
 files_pdfviewer
 files_texteditor
 groupfolders
 htmlviewer
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
 related_resources
 richdocuments
 serverinfo
 suspicious_login
 text
 twofactor_gateway
 twofactor_nextcloud_notification
 twofactor_totp
 user_sql
 viewer
 workflow_pdf_converter
"

CORE_BRANCH=stable32

BUILD=false
BUILD_MODE=build
PUSH=false
RESET=false
REBASE=false
STATUS=false
LIST=false
APPS="${ALL_APPS}"

declare -A BUILD_COMMANDS
BUILD_COMMANDS=(
    [bav]="make \$BUILD_MODE"
    [cafevdb]="make \$BUILD_MODE"
    [cafevdbmembers]="make \$BUILD_MODE"
    [calendar]="rm -rf node_modules && run-krankerl.sh"
    [collectives]="make setup-dev node-modules build-js-production composer-install-no-dev"
    [contacts]="run-krankerl.sh"
    [dokuwiki]="make \$BUILD_MODE"
    [emlviewer]="make"
    [files_archive]="make \$BUILD_MODE"
    [files_lock]="rm -rf node_modules package-lock.json && npm install && run-krankerl.sh"
    [groupfolders]="make"
    # [htmlviewer]="npm install ; npm ci; npm update; make"
    [htmlviewer]="npm install ; npm ci; make"
    [ldap_write_support]="run-krankerl.sh"
    [logreader]="make"
    [mail]="make install-deps optimize-js"
    [mail_roundcube]="make \$BUILD_MODE"
    [maps]="make"
    [pdf_downloader]="make \$BUILD_MODE"
    # TODO: remove photos, either use photos or memories, not both
    # [photos]="make dev-setup build-js-production && rm -rf vendor/* && composer install --no-dev"
    [photos]="rm -rf vendor/* && composer install --no-dev"
    [redaxo]="make \$BUILD_MODE"
    [richdocuments]="run-krankerl.sh"
    [twofactor_gateway]="run-krankerl.sh"
    [workflow_pdf_converter]="run-krankerl.sh"
)

declare -A STABLE_BRANCHES
STABLE_BRANCHES=(
    [calendar]=stable6.0
    [contacts]=stable8.0
    [emlviewer]=master
    [htmlviewer]=master
    [mail]=stable5.5
)

declare -A REBASE_BRANCHES
REBASE_BRANCHES=(
    [calendar]=origin/stable6.0
    [contacts]=origin/stable8.0
    [files_lock]=origin/$CORE_BRANCH
    [groupfolders]=origin/$CORE_BRANCH
    [ldap_write_support]=origin/$CORE_BRANCH
    [logreader]=origin/$CORE_BRANCH
    [mail]=origin/stable5.5
    [maps]=origin/master
    [richdocuments]=origin/$CORE_BRANCH
    [twofactor_gateway]=origin/stable32
    [workflow_pdf_converter]=origin/$CORE_BRANCH
)

# hard reset branches, meant to update the server
declare -A RESET_BRANCHES
RESET_BRANCHES=(
    [activity]=origin/stable32
    [app_api]=origin/stable32
    [bav]=origin/master
    [cafevdb]=origin/nextcloud32
    [cafevdbmembers]=origin/stable32
    [calendar]=cjh/production/cafevdb/stable6.0
    [circles]=origin/stable32
    [collectives]=origin/main
    [contacts]=cjh/production/cafevdb/stable8.0
    [dokuwiki]=origin/master
    [emlviewer]=cjh/production/stable32
    [files_archive]=origin/main
    [files_lock]=cjh/production/cafevdb/stable32
    [files_pdfviewer]=origin/stable32
    [files_texteditor]=origin/master
    [groupfolders]=cjh/production/cafevdb/stable32
    [htmlviewer]=origin/master
    [ldap_write_support]=cjh/production/cafevdb/stable32
    [logreader]=cjh/production/cafevdb/stable32
    [mail]=cjh/feature/stable5.5/provision-additional-email-addresses
    [mail_roundcube]=origin/master
    [maps]=cjh/production/cafevdb/master
    [notifications]=origin/stable32
    [password_policy]=origin/stable32
    [pdf_downloader]=origin/main
    [photos]=origin/stable32
    [privacy]=origin/stable32
    [recommendations]=origin/stable32
    [redaxo]=origin/main
    [related_resources]=origin/stable32
    [richdocuments]=cjh/feature/authenticated-requests-32
    [serverinfo]=origin/stable32
    [suspicious_login]=origin/stable32
    [text]=origin/stable32
    [twofactor_gateway]=cjh/production/stable32/cafevdb
    [twofactor_nextcloud_notification]=origin/stable32
    [twofactor_totp]=origin/stable32
    [user_sql]=cjh/production/cafevdb/stable32
    [viewer]=origin/stable32
    [workflow_pdf_converter]=cjh/production/rotdrop/stable32
)

declare -A SUBREPO_APPS
SUBREPO_APPS=(
    [bav]=true
    [cafevdb]=true
    [cafevdbmembers]=true
    [dokuwiki]=true
    [files_archive]=true
    [mail_roundcube]=true
    [pdf_downloader]=true
    [redaxo]=true
)

NCDIR=$(realpath .)

VALID_ARGS=$(getopt -o bldor:s --long build,list,dev,only:,rebase,status,push,reset -- "$@")
# shellcheck disable=SC2181
if [[ $? -ne 0 ]]; then
    exit 1;
fi

eval set -- "$VALID_ARGS"
while true; do
  case "$1" in
    -l|--list)
      LIST=true
      shift
      ;;
    -b|--build)
      BUILD=true
      shift
      ;;
    -d|--dev)
      BUILD_MODE=dev
      shift
      ;;
    -r|--rebase)
      REBASE=true
      shift
      ;;
    -o|--only)
      ARG=$2
      if [ "$ARG" = subrepo ]; then
        ARG="$(echo "${!SUBREPO_APPS[*]}"|xargs -n1|sort|xargs)"
      fi
      APPS="$ARG"
      shift 2
      ;;
    --push)
      PUSH=true
      shift
      ;;
    --reset)
      RESET=true
      shift
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

if $LIST; then
  echo "$APPS"
  exit 0
fi

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
    if $RESET; then
        RESET_BRANCH="${RESET_BRANCHES[$APP]}"
        setTitle "$APP (get reset --hard $RESET_BRANCH)"
        if [ -z "$RESET_BRANCH" ]; then
            echo "Reset branch for app $APP is empty" 1>&2
            exit 1
        fi
        echo "*** Hard resetting $APP to $RESET_BRANCH ***"
        git reset --hard "$RESET_BRANCH"
    fi
    case $BRANCH in
        stable*|master|main)
            setTitle "$APP (git pull from $BRANCH)"
            echo "Performing simple pull from upstream"
            git pull
            ;;
    esac
    if [ "${SUBREPO_APPS[$APP]}" = true ]; then
      setTitle "$APP (git subrepo pull --all)"
      git subrepo pull --all
    fi
    if $PUSH; then
      setTitle "$APP (git push)"
      git push --force
    fi
    if $REBASE && [ -n "${REBASE_BRANCHES[$APP]}" ]; then
        setTitle "$APP (git rebase ${REBASE_BRANCHES[$APP]})"
        echo "*** Rebasing $APP to ${REBASE_BRANCHES[$APP]} ***"
        git checkout . || exit 1
        git rebase "${REBASE_BRANCHES[$APP]}" || exit 1
    fi
    if $BUILD && [ -n "${BUILD_COMMANDS[$APP]}" ]; then
        setTitle "$APP (build)"
        echo "*** Rebuilding $APP ***"
        echo "Running ${BUILD_COMMANDS[$APP]}"
        { eval "${BUILD_COMMANDS[$APP]}"; } || exit 1
    fi
    echo
    setTitle
    cd "$NCDIR" || exit 1
done

for x in "${!ATTENTION[@]}"; do
    printf "[%s]=%s\n" "$x" "${ATTENTION[$x]}"
done
