#!/bin/bash 

set -e

## Default values ##
: ${DB_NAME:=wikimediadb}
: ${DB_SERVER:=mariadb-internal-svc}
: ${DB_PORT:=3306}
: ${DB_INSTALL_USER:=root}
: ${DB_INSTALL_PASSWORD:=root_secret}
: ${DB_USER:=wikiuser}
: ${DB_PASSWORD:=wikipassword}
: ${MEDIAWIKI_SERVER_URL:=wiki.example.com}
: ${NODE_PORT:=31000}
: ${MEDIAWIKI_SCRIPT_PATH:=/}
: ${MEDIAWIKI_SITE_LANG:=en}
: ${MEDIAWIKI_ADMIN_PASSWORD:=HelloWorld123}
: ${MEDIAWIKI_SITE_NAME:=First_Site}
: ${MEDIAWIKI_ADMIN_USER:=admin}

if [ ! -e "LocalSettings.php" ]; then
    php maintenance/install.php \
    --dbname $DB_NAME \
    --dbserver $DB_SERVER:$DB_PORT \
    --installdbuser $DB_INSTALL_USER \
    --installdbpass $DB_INSTALL_PASSWORD \
    --dbuser $DB_USER \
    --dbpass $DB_PASSWORD \
    --server "http://$MEDIAWIKI_SERVER_URL:$NODE_PORT" \
    --scriptpath $MEDIAWIKI_SCRIPT_PATH \
    --lang $MEDIAWIKI_SITE_LANG \
    --pass $MEDIAWIKI_ADMIN_PASSWORD \
    "$MEDIAWIKI_SITE_NAME" \
    "$MEDIAWIKI_ADMIN_USER"
fi

