#! /bin/sh -e
# Script to create simulator and arm archives and bundle them together into an xcframework using xcodebuild
#
# The script file needs to have 0755 permissions with execution bit set.
#
# Build from terminal command line with following command.
#
# ./create_xcframeworks Connect
#

# Release dir path
OUTPUT_DIR_PATH=build

if [[ -z $1 ]]; then
    echo "Output dir was not set. try to run ./create_xcframeworks.sh Connect"
    exit 1;
fi

function archivePathSimulator {
  local DIR=${OUTPUT_DIR_PATH}/archives/"${1}-SIMULATOR"
  echo "${DIR}"
}

function archivePathDevice {
  local DIR=${OUTPUT_DIR_PATH}/archives/"${1}-DEVICE"
  echo "${DIR}"
}

# Archive takes 3 params
#
# 1st == SCHEME
# 2nd == destination
# 3rd == archivePath
function archive {
    echo "▸ Starts archiving the scheme: ${1} for destination: ${2};\n▸ Archive path: ${3}.xcarchive"
    xcodebuild archive \
    -project Connect.xcodeproj \
    -scheme ${1} \
    -destination "${2}" \
    -archivePath "${3}" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES | xcpretty
}

# Builds archive for iOS simulator & device
function buildArchive {
  SCHEME=Connect
  archive $SCHEME "generic/platform=iOS Simulator" $(archivePathSimulator $SCHEME)
  archive $SCHEME "generic/platform=iOS" $(archivePathDevice $SCHEME)
}

# Creates xc framework
function createXCFramework {
  FRAMEWORK_ARCHIVE_PATH_POSTFIX=".xcarchive/Products/Library/Frameworks"
  FRAMEWORK_SIMULATOR_DIR="$(archivePathSimulator $1)${FRAMEWORK_ARCHIVE_PATH_POSTFIX}"
  FRAMEWORK_DEVICE_DIR="$(archivePathDevice $1)${FRAMEWORK_ARCHIVE_PATH_POSTFIX}"

  xcodebuild -create-xcframework \
            -framework ${FRAMEWORK_SIMULATOR_DIR}/${1}.framework \
            -framework ${FRAMEWORK_DEVICE_DIR}/${1}.framework \
            -output ${OUTPUT_DIR_PATH}/xcframeworks/${1}.xcframework
   
  cp ${FRAMEWORK_SIMULATOR_DIR}/${1}.framework/Modules/Connect.swiftmodule/arm64-apple-ios-simulator.swiftmodule ${OUTPUT_DIR_PATH}/xcframeworks/${1}.xcframework/ios-arm64_x86_64-simulator/Connect.framework/Modules/Connect.swiftmodule
  cp ${FRAMEWORK_SIMULATOR_DIR}/${1}.framework/Modules/Connect.swiftmodule/arm64.swiftmodule ${OUTPUT_DIR_PATH}/xcframeworks/${1}.xcframework/ios-arm64_x86_64-simulator/Connect.framework/Modules/Connect.swiftmodule
  cp ${FRAMEWORK_SIMULATOR_DIR}/${1}.framework/Modules/Connect.swiftmodule/x86_64-apple-ios-simulator.swiftmodule ${OUTPUT_DIR_PATH}/xcframeworks/${1}.xcframework/ios-arm64_x86_64-simulator/Connect.framework/Modules/Connect.swiftmodule
  cp ${FRAMEWORK_SIMULATOR_DIR}/${1}.framework/Modules/Connect.swiftmodule/x86_64.swiftmodule ${OUTPUT_DIR_PATH}/xcframeworks/${1}.xcframework/ios-arm64_x86_64-simulator/Connect.framework/Modules/Connect.swiftmodule
  cp ${FRAMEWORK_DEVICE_DIR}/${1}.framework/Modules/Connect.swiftmodule/arm64-apple-ios.swiftmodule ${OUTPUT_DIR_PATH}/xcframeworks/${1}.xcframework/ios-arm64/Connect.framework/Modules/Connect.swiftmodule
  cp ${FRAMEWORK_DEVICE_DIR}/${1}.framework/Modules/Connect.swiftmodule/arm64.swiftmodule ${OUTPUT_DIR_PATH}/xcframeworks/${1}.xcframework/ios-arm64/Connect.framework/Modules/Connect.swiftmodule
  
  cp -r "${OUTPUT_DIR_PATH}/xcframeworks/${1}.xcframework" "${SRCROOT}"
}

echo "#####################"
echo "▸ Cleaning the dir: ${OUTPUT_DIR_PATH}"
rm -rf $OUTPUT_DIR_PATH

#### Dynamic Framework ####

DYNAMIC_FRAMEWORK=Connect

echo "▸ Archive $DYNAMIC_FRAMEWORK"
buildArchive ${DYNAMIC_FRAMEWORK}

echo "▸ Create $DYNAMIC_FRAMEWORK.xcframework"
createXCFramework ${DYNAMIC_FRAMEWORK}
