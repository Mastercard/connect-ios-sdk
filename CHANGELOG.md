# Connect iOS SDK ChangeLog

## Version 3.0.3 - 2024-08-01
### Changes
- Added a fix to resolve an issue with iOS OS version greater than 17.3

## Version 3.0.2 - 2024-07-03
### Changes
- Added a fix to resolve an issue with App To App OAuth flow 


## Version 3.0.1 - 2024-04-22 
### Changes
- Added Privacy Manifest XCPrivacy file - https://developer.apple.com/documentation/bundleresources/privacy_manifest_files

## Version 3.0.0 - 2023-10-10

### Enhancements
- Enhanced App To App OAuth Flow with newly added redirectUrl parameter inside Connect iOS SDK to support universal link and deeplink for navigation between mobile apps. For details on App To App refer [documentation here](https://developer.mastercard.com/open-banking-us/documentation/connect/mobile-sdks/).

### Breaking changes
- Connect iOS SDK support for deepLinkUrl is deprecated from this version, Please use the redirectUrl parameter instead, it will support both universal link and deeplink. Please follow the readme for [more details](https://github.com/Mastercard/connect-ios-sdk/blob/main/README.md)

## Version 2.1.0 - 2023-06-13
### Changes
- Added support for App to App deeplink navigation for external (Partner's) App OAuth flow.

## Version 2.0.0 - 2023-05-30
### Changes
- Added fix for typed text not visible in text area provided in Connect Wrapper demo app.


## Version 1.3.1 - 2021-01-07

### Changes
- Fixed memory leak in ConnectViewController caused by retain cycle.
- Enhanced UI in Connect Wrapper demo app.

## Version 1.3.0 - 2020-12-04

### Changes
- Initial release to CocoaPods.
- Connect iOS SDK distributed in xcframework binary format to make it easier to integrate with our SDK.
- Enabled bitcode support.
- Added API sdkVersion() to return the current SDK version in semantic versioning string format.
