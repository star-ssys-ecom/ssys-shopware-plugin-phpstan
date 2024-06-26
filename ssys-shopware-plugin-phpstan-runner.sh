#!/usr/bin/env bash

set -e

PLUGIN_DIR="$1"
SHOP_DIR="$2"

echo "Plugin dir: $PLUGIN_DIR"
echo "Shop dir: $SHOP_DIR"

DEVOPS_DIR="$SHOP_DIR/vendor/shopware/core/DevOps"
if [[ ! -d "$DEVOPS_DIR" ]]; then
  DEVOPS_DIR="$SHOP_DIR/src/Core/DevOps"
fi

if [[ ! -f "$SHOP_DIR/vendor/bin/phpstan" ]]; then
    cd $SHOP_DIR
    composer config --no-plugins allow-plugins.phpstan/extension-installer true
    composer config --no-plugins allow-plugins.symfony/runtime true
    composer require --dev phpstan/extension-installer \
                           phpstan/phpstan \
                           phpstan/phpstan-deprecation-rules \
                           phpstan/phpstan-doctrine \
                           phpstan/phpstan-phpunit \
                           phpstan/phpstan-symfony
fi

cp "$PLUGIN_DIR/phpstan.neon.dist" "$PLUGIN_DIR/phpstan.neon"
sed -i "s|%rootDir%/.*/DevOps|$DEVOPS_DIR|g" "$PLUGIN_DIR/phpstan.neon"
sed -i "s|%rootDir%/\.\./\.\./\.\.|$SHOP_DIR|g" "$PLUGIN_DIR/phpstan.neon"

if [[ ! -d "$SHOP_DIR/var/cache/phpstan_dev" ]]; then
  php "$DEVOPS_DIR/StaticAnalyze/phpstan-bootstrap.php"
fi

cd $PLUGIN_DIR
$SHOP_DIR/vendor/bin/phpstan analyse --no-interaction
