#!/usr/bin/env bash

echo "Copying secure Keys.plist to source directory"

mv ${BUDDYBUILD_SECURE_FILES}/Keys.plist Film\ Locations/Film\ Locations/

echo "Copying xcconfig files"

mv ${BUDDYBUILD_SECURE_FILES}/Debug.xcconfig Film\ Locations/
mv ${BUDDYBUILD_SECURE_FILES}/Release.xcconfig Film\ Locations/

