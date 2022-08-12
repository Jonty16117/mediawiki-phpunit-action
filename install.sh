#!/bin/sh -l

set -o pipefail

MW_BRANCH=$1
EXTENSION_NAME=$2
TYPE=$3

# Download wiki release
wget https://github.com/wikimedia/mediawiki/archive/$MW_BRANCH.tar.gz -nv -q

# Extract into `mediawiki` directory
tar -zxf $MW_BRANCH.tar.gz
mv mediawiki-$MW_BRANCH mediawiki

# Setting composer config to allow installing plugins
composer config --global allow-plugins.composer/installers true

# Install composer dependencies
cd mediawiki && composer -q install
php maintenance/install.php \
  --dbtype sqlite \
  --dbuser root \
  --dbname mw \
  --dbpath $(pwd) \
  --pass DummyAdminPassword DummyWikiName DummyAdminUser > /dev/null

# https://www.mediawiki.org/wiki/Manual:$wgShowExceptionDetails
echo '$wgShowExceptionDetails = true;' >> LocalSettings.php
# https://www.mediawiki.org/wiki/Manual:$wgShowDBErrorBacktrace , note this is deprecated in 1.37+
echo '$wgShowDBErrorBacktrace = true;' >> LocalSettings.php
# https://www.mediawiki.org/wiki/Manual:$wgDevelopmentWarnings
echo '$wgDevelopmentWarnings = true;' >> LocalSettings.php
