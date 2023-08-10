# Connect iOS SDK ChangeLog

## Version 3.0.0 - 2023-10-10

### Enhancements
- Newly added redirectUrl parameter inside Connect iOS SDK to support universal link and deeplink for navigation between mobile apps, It will help in enhancing App to App seamless communication.

### Breaking changes
- Connect iOS SDK support for deepLinkUrl is deprecated from this version, Please use the redirectUrl parameter instead, it will support both universal link and deeplink. Please follow the readme for more details https://github.com/Mastercard/connect-ios-sdk/blob/main/README.md

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
