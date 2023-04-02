#!/bin/zsh

#  ci_post_clone.sh
#  tumble-ios
#
#  Created by Adis Veletanlic on 4/2/23.
#

# Define the path to the GoogleService-Info.plist file in your source code
GOOGLE_PLIST_PATH="../tumble-ios/GoogleService-Info.plist"

# Copy the file to the tumble-ios directory
cp -r "$GOOGLE_PLIST_PATH" ../tumble-ios/
