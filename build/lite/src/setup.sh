#!/bin/bash
wget -qO- https://brightdata.com/static/earnapp/install.sh > /app/src/earnapp.sh

PRODUCT="earnapp"
VERSION=$(grep VERSION= /app/src/earnapp.sh | cut -d'"' -f2)

# Always use x64 (amd64v3) binary
file=$PRODUCT-x64-$VERSION

mkdir /download
wget -cq --no-check-certificate https://cdn-earnapp.b-cdn.net/static/$file -O /download/earnapp
echo | md5sum /download/earnapp
chmod +x /download/earnapp