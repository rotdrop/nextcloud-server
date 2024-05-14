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
BUILD_COMMANDS=(
    [bav]="make"
    [cafevdb]="make build"
    [cafevdbmembers]="make build"
    [calendar]="run-krankerl.sh"
)

for i in $APPS; do
    cd $i
    BRANCH=$(git status |grep -i "On branch"|awk '{ print $3; }')
    echo "** Updating $i@$BRANCH **"
    git fetch --all -p
    case $BRANCH in
        stable*|master)
            echo "Performing simple pull from upstream"
            git pull
            ;;
    esac
    echo
    cd ..
done



# ./activity
# On branch stable27
# Your branch is up to date with 'origin/stable27'.

# nothing to commit, working tree clean
# ./bav
# On branch stable27
# Your branch is up to date with 'origin/stable27'.

# nothing to commit, working tree clean
# ./cafevdb
# On branch nextcloud27
# Your branch is up to date with 'origin/nextcloud27'.

# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
# 	.dir-locals.el
# 	.phpactor.json
# 	APITEST-TOKEN
# 	LICENSE-SNIPPET.txt
# 	SentEmailBug.json
# 	SentEmailBug.txt
# 	TODO.txt
# 	dev-scripts/playground/php/dirname.php
# 	dev-scripts/playground/php/empty-keys.php
# 	dev-scripts/playground/php/join-table-fun.php
# 	img/logo-stempel.pdf
# 	img/logo-stempel.png
# 	slow-query.sql
# 	slowquery.sql
# 	src/views/EditEventSimple.vue
# 	tmp/

# nothing added to commit but untracked files present (use "git add" to track)
# ./cafevdbmembers
# On branch stable27
# Your branch is up to date with 'origin/stable27'.

# Changes not staged for commit:
#   (use "git add <file>..." to update what will be committed)
#   (use "git restore <file>..." to discard changes in working directory)
# 	modified:   lib/Controller/ProjectRegistrationController.php
# 	modified:   src/stores/memberData.js

# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
# 	src/mixins/#registrationData.js#

# no changes added to commit (use "git add" and/or "git commit -a")
# ./calendar
# On branch production/cafevdb/stable4.6
# Your branch is up to date with 'cjh/production/cafevdb/stable4.6'.

# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
# 	.ac-php-conf.json

# nothing added to commit but untracked files present (use "git add" to track)
# ./circles
# On branch cjh/production/stable27
# Your branch and 'cjh/cjh/production/stable27' have diverged,
# and have 3 and 2 different commits each, respectively.
#   (use "git pull" if you want to integrate the remote branch with yours)

# Changes not staged for commit:
#   (use "git add <file>..." to update what will be committed)
#   (use "git restore <file>..." to discard changes in working directory)
# 	modified:   composer.lock

# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
# 	.ac-php-conf.json

# no changes added to commit (use "git add" and/or "git commit -a")
# ./collectives
# On branch main
# Your branch is up to date with 'origin/main'.

# Changes not staged for commit:
#   (use "git add <file>..." to update what will be committed)
#   (use "git restore <file>..." to discard changes in working directory)
# 	modified:   Makefile

# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
# 	.ac-php-conf.json

# no changes added to commit (use "git add" and/or "git commit -a")
# ./contacts
# On branch stable5.5
# Your branch is up to date with 'origin/stable5.5'.

# nothing to commit, working tree clean
# ./dokuwiki
# On branch stable27
# Your branch is up to date with 'origin/stable27'.

# Changes not staged for commit:
#   (use "git add/rm <file>..." to update what will be committed)
#   (use "git restore <file>..." to discard changes in working directory)
# 	deleted:    css/app-aeb7e25e3e845900a451.css
# 	deleted:    css/app-aeb7e25e3e845900a451.css.map
# 	deleted:    css/popup-cbf5df3e99d3a523a58e.css
# 	deleted:    css/popup-cbf5df3e99d3a523a58e.css.map
# 	modified:   js/asset-meta.json
# 	modified:   lib/AppInfo/Application.php
# 	modified:   vendor/autoload.php
# 	modified:   vendor/composer/autoload_classmap.php
# 	modified:   vendor/composer/autoload_namespaces.php
# 	modified:   vendor/composer/autoload_psr4.php
# 	modified:   vendor/composer/autoload_real.php
# 	modified:   vendor/composer/autoload_static.php
# 	modified:   vendor/composer/installed.json
# 	modified:   vendor/composer/installed.php

# no changes added to commit (use "git add" and/or "git commit -a")
# ./emlviewer
# On branch master
# Your branch is up to date with 'upstream/master'.

# nothing to commit, working tree clean
# ./files_archive
# On branch stable27
# Your branch is up to date with 'origin/stable27'.

# Changes not staged for commit:
#   (use "git add <file>..." to update what will be committed)
#   (use "git restore <file>..." to discard changes in working directory)
# 	modified:   git-modules/nextcloud-vue-components (new commits)
# 	modified:   src/views/FilesTab.vue

# no changes added to commit (use "git add" and/or "git commit -a")
# ./files_automatedtagging
# On branch production/stable27
# Your branch is up to date with 'cjh/production/stable27'.

# nothing to commit, working tree clean
# ./files_lock
# On branch bugfix/do-not-kill-infinite-locks
# Your branch is up to date with 'cjh/bugfix/do-not-kill-infinite-locks'.

# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
# 	.ac-php-conf.json

# nothing added to commit but untracked files present (use "git add" to track)
# ./files_pdfviewer
# On branch stable27
# Your branch is up to date with 'origin/stable27'.

# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
# 	.php-cs-fixer.cache

# nothing added to commit but untracked files present (use "git add" to track)
# ./files_rightclick
# On branch stable27
# Your branch is up to date with 'origin/stable27'.

# nothing to commit, working tree clean
# ./files_texteditor
# On branch master
# Your branch is up to date with 'origin/master'.

# nothing to commit, working tree clean
# ./groupfolders
# On branch production/cafevdb/stable27
# Your branch is up to date with 'cjh/production/cafevdb/stable27'.

# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
# 	.ac-php-conf.json

# nothing added to commit but untracked files present (use "git add" to track)
# ./ldap_contacts_backend
# On branch stable27
# Your branch is up to date with 'origin/stable27'.

# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
# 	.ac-php-conf.json

# nothing added to commit but untracked files present (use "git add" to track)
# ./ldap_write_support
# On branch production/cafevdb/stable27
# Your branch is up to date with 'cjh/production/cafevdb/stable27'.

# nothing to commit, working tree clean
# ./logreader
# On branch production/cafevdb/stable27
# Your branch is up to date with 'cjh/production/cafevdb/stable27'.

# nothing to commit, working tree clean
# ./mail
# On branch feature/stable3.4/provision-additional-email-addresses
# Your branch is up to date with 'cjh/feature/stable3.4/provision-additional-email-addresses'.

# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
# 	.ac-php-conf.json

# nothing added to commit but untracked files present (use "git add" to track)
# ./mail_roundcube
# On branch stable27
# Your branch is up to date with 'origin/stable27'.

# nothing to commit, working tree clean
# ./maps
# On branch experimental/stable27
# Your branch is up to date with 'cjh/experimental/stable27'.

# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
# 	.ac-php-conf.json

# nothing added to commit but untracked files present (use "git add" to track)
# ./notifications
# On branch stable27
# Your branch is up to date with 'origin/stable27'.

# nothing to commit, working tree clean
# ./password_policy
# On branch stable27
# Your branch is up to date with 'origin/stable27'.

# nothing to commit, working tree clean
# ./pdf_downloader
# On branch stable27
# Your branch is up to date with 'origin/stable27'.

# nothing to commit, working tree clean
# ./photos
# On branch stable27
# Your branch is up to date with 'origin/stable27'.

# nothing to commit, working tree clean
# ./privacy
# On branch stable27
# Your branch is up to date with 'origin/stable27'.

# nothing to commit, working tree clean
# ./recognize
# On branch cjh-stable27
# Your branch is up to date with 'cjh/cjh-stable27'.

# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
# 	.ac-php-conf.json
# 	vendor-bin/php-cs-fixer/composer.lock
# 	vendor-bin/phpunit/composer.lock
# 	vendor-bin/psalm/composer.lock

# nothing added to commit but untracked files present (use "git add" to track)
# ./recommendations
# On branch stable27
# Your branch is up to date with 'origin/stable27'.

# nothing to commit, working tree clean
# ./redaxo
# On branch stable27
# Your branch is up to date with 'origin/stable27'.

# nothing to commit, working tree clean
# ./richdocuments
# On branch feature/authenticated-requests-27
# Your branch is up to date with 'cjh/feature/authenticated-requests-27'.

# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
# 	.ac-php-conf.json

# nothing added to commit but untracked files present (use "git add" to track)
# ./serverinfo
# On branch stable27
# Your branch is up to date with 'origin/stable27'.

# nothing to commit, working tree clean
# ./spreed
# On branch stable27
# Your branch is up to date with 'origin/stable27'.

# nothing to commit, working tree clean
# ./suspicious_login
# On branch stable27
# Your branch is up to date with 'origin/stable27'.

# nothing to commit, working tree clean
# ./text
# On branch stable27
# Your branch is up to date with 'origin/stable27'.

# nothing to commit, working tree clean
# ./twofactor_gateway
# On branch production/stable27/cafevdb
# Your branch is up to date with 'cjh/production/stable27/cafevdb'.

# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
# 	.ac-php-conf.json

# nothing added to commit but untracked files present (use "git add" to track)
# ./twofactor_totp
# On branch stable27
# Your branch is up to date with 'origin/stable27'.

# nothing to commit, working tree clean
# ./user_sql
# On branch production/cafevdb/stable27
# Your branch is up to date with 'cjh/production/cafevdb/stable27'.

# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
# 	.ac-php-conf.json

# nothing added to commit but untracked files present (use "git add" to track)
# ./viewer
# On branch stable27
# Your branch is up to date with 'origin/stable27'.

# nothing to commit, working tree clean
# ./workflow_pdf_converter
# On branch production/rotdrop/stable27
# Your branch is up to date with 'cjh/production/rotdrop/stable27'.

# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
# 	.ac-php-conf.json

# nothing added to commit but untracked files present (use "git add" to track)
