#!/bin/sh

ZIPFILENAME=bitwardencli.zip

LOCATION=$(curl -L -s https://api.github.com/repos/bitwarden/cli/releases/latest | grep -o -E "https://(.*)bw-linux(.*).zip")
curl -L -o $ZIPFILENAME $LOCATION
unzip -j $ZIPFILENAME
rm $ZIPFILENAME
sudo chmod +x bw
