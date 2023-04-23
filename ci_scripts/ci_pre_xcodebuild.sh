#!/bin/sh

#  ci_pre_xcodebuild.sh
#  Tumble
#
#  Created by Adis Veletanlic on 2023-04-24.
#

# Retrieve the encoded secret from the environment variable
GOOGLE_SERVICE_PLIST=$GOOGLE_SERVICE

# Decode the secret using base64
DECODED_SECRET=$(echo "$GOOGLE_SERVICE_PLIST" | base64 --decode)

# Write the secret to a file
echo "$GOOGLE_SERVICE_PLIST" > GoogleService-Info.plist
