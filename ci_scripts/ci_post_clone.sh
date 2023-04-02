#!/bin/sh

#  ci_post_clone.sh
#  tumble-ios
#
#  Created by Adis Veletanlic on 4/2/23.
#  

# Define the path to the GoogleService-Info.plist file in your source code
GOOGLE_PLIST_PATH="../tumble-ios/GoogleService-Info.plist"

# Define the destination path in the Xcode Cloud build environment
DESTINATION_PATH="$HOME/Library/MobileDevice/Provisioning\ Profiles/"

# Copy the file to the build environment
cp -r "$GOOGLE_PLIST_PATH" "$DESTINATION_PATH"
