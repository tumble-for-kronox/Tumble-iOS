#!/bin/sh

#  ci_post_clone.sh
#  tumble-ios
#
#  Created by Adis Veletanlic on 4/2/23.
#  

# Define the local path to the GoogleService-Info.plist file
LOCAL_PATH="/Users/adisveletanlic/git/tumble-ios/tumble-ios/GoogleService-Info.plist"

# Define the destination path in the Xcode Cloud build environment
DEST_PATH="$HOME/Library/MobileDevice/Provisioning\ Profiles/"

# Copy the file to the build environment
scp -r "$LOCAL_PATH" "xcode@$CI_RUNNER_IP:$DEST_PATH"
