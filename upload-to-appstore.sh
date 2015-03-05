#!/bin/bash
set -ex

# This scripts allows you to upload a binary to the iTunes Connect Store and do it for a specific app_id
# Because when you have multiple apps in status for download, xcodebuild upload will complain that multiple apps are in wait status

# Requires application loader to be installed
# See https://developer.apple.com/library/ios/documentation/LanguagesUtilities/Conceptual/iTunesConnect_Guide/Chapters/SubmittingTheApp.html
# Itunes Connect username & password
USER=bla
PASS=bla

# App id as in itunes store create, not in your developer account
APP_ID=123456789

IPA_FILE=$1
IPA_FILENAME=$(basename $IPA_FILE)
MD5=$(md5 -q $IPA_FILE)
BYTESIZE=$(stat -f "%z" $IPA_FILE)

TEMPDIR=itsmp
# Remove previous temp
test -d ${TEMPDIR} && rm -rf ${TEMPDIR}
mkdir ${TEMPDIR}
mkdir ${TEMPDIR}/mybundle.itmsp

# You can see this debug info when you manually do an app upload with the Application Loader
# It's when you click activity

cat <<EOM > ${TEMPDIR}/mybundle.itmsp/metadata.xml
<?xml version="1.0" encoding="UTF-8"?>
<package version="software4.7" xmlns="http://apple.com/itunes/importer">
    <software_assets apple_id="$APP_ID">
        <asset type="bundle">
            <data_file>
                <file_name>$IPA_FILENAME</file_name>
                <checksum type="md5">$MD5</checksum>
                <size>$BYTESIZE</size>
            </data_file>
        </asset>
    </software_assets>
</package>
EOM

cp ${IPA_FILE} $TEMPDIR/mybundle.itmsp

/Applications/Xcode.app/Contents/Applications/Application\ Loader.app/Contents/MacOS/itms/bin/iTMSTransporter -m upload -f ${TEMPDIR} -u "$USER" -p "$PASS" -v detailed
