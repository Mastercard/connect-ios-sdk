# Connect iOS SDK [![version][connect-sdk-version]][connect-sdk-url]

## Overview  

The Connect iOS SDK allows you to embed our Mastercard Connect application anywhere you want within your own mobile applications.

The iOS SDK is distributed as a compiled binary in XCFramework format which allows you to easily integrate our SDK into your development projects.  Our iOS SDK has full bitcode support so that you don’t have to disable bitcode in your applications when integrating with our SDK.

The XCFramework format is Apple’s officially supported format for distributing binary libraries for multiple platforms and architectures in a single bundle.

Additional documentation for the Connect iOS SDK can be found at (https://developer.mastercard.com/open-banking-us/documentation/connect/integrating/)

## Requirements

The Connect iOS SDK supports iOS 14 or later.

> **Warning**: Support for deepLinkUrl parameters is deprecated from Connect iOS SDK version 3.0.0, going forward please use the redirectUrl parameter which supports both universal and deep links. 


## Installation

Connect iOS SDK can be installed either with CocoaPods or by manually dragging the Connect.xcframework into your Xcode project.

### CocoaPods
Connect iOS SDK can be installed as a [CocoaPod](https://cocoapods.org/). To install, include the following in your Podfile.

```
use_frameworks!

pod 'MastercardOpenBankingConnect'
```

### Manual

1. Open your project in Xcode and drag the Connect.xcframework folder into your project.

2. In the build settings for your target, select the **General** tab, scroll down to the **Frameworks, Libraries, and Embedded Content**, and select Connect.xcframework.  Under the **Embed** column, select **Embed & Sign** from the menu drop-down list if is not already selected.

## Integration

1. Add import Connect into all your source files that make calls to the Connect iOS SDK.
```
import UIKit
import Connect
```
2. Create callback/delegate functions for loaded, done, cancel, error, route, and user events.    
    These callbacks correspond to the following events in Connect's data flow:

    | Event | Description |
    | ------ | ------ |
    | onLoad | Called when the Connect web page is loaded and ready to display. |
    | onDone | Called when the user successfully completes the Connect application. It also has an unlabeled NSDictionary? parameter containing event information. |
    | onCancel | Called when the user cancels the Connect application. |
    | onError | Called when an error occurs while the user is using the Connect application. The unlabeled NSDictionary? parameter contains event information. |
    | onRoute | Called with the user is navigating through the screens of the Connect application. The unlabeled NSDictionary? parameter containing event information. |
    | onUser | Connect 2.0 (only)  Called when a user performs an action. User events provide visibility into what action a user could take within the Connect application. The unlabeled NSDictionary? parameter contains event information. |
    
    **Note:** The onDone, onError, onRoute, and onUser callback functions will have a **NSDictionary?** parameter that contains data about the event.

3. Using a valid Connect URL and callback functions, create a Connect URL.  See [Generate 2.0 Connect URL APIs](https://developer.mastercard.com/open-banking-us/documentation/connect/generate-2-connect-url-apis/) (Used as `connectUrl` in example code below)
4. Create an instance of the ConnectViewController class and Assign ConnectEventDelegate to ConnectViewController..
5. In the loaded callback, present the ConnectViewController using a UINavigationController with the ConnectViewController as its rootViewController.
6. The ConnectViewController automatically dismisses when the Connect flow is completed, cancelled early by the user, or when an error is encountered.



### Example

```
 ViewController: UIViewController, ConnectEventDelegate {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
   // Declaration of View and Navigation controllers
    var connectViewController: ConnectViewController!
    var connectNavController: UINavigationController!
    var connectUrl: String?
    
   // For regular Connect flow use below openConnect function
    func openConnect(connectUrl: String) {
      self.connectViewController = ConnectViewController()
      self.connectViewController.delegate = self
      self.connectViewController.load(connectUrl!)
    }

   // For App to App Connect flow use below openConnect function
    func openConnect(connectUrl: String) {
      self.connectViewController = ConnectViewController()
      self.connectViewController.delegate = self
      self.connectViewController.load(connectUrl,redirectUrl: "https://yourdomain.com/connect")
    }
    
    
    // Connect Delegate Methods
    func onCancel(_ data: NSDictionary?) {
        print("onCancel:")
        displayData(data)
        self.activityIndicator.stopAnimating()
        // Needed to trigger deallocation of ConnectViewController
        self.connectViewController = nil
        self.connectNavController = nil
    }
    
    func onDone(_ data: NSDictionary?) {
        print("onDone:")
        displayData(data)
        self.activityIndicator.stopAnimating()
        // Needed to trigger deallocation of ConnectViewController
        self.connectViewController = nil
        self.connectNavController = nil
    }
    
    func onError(_ data: NSDictionary?) {
        print("onError:")
        displayData(data)
        self.activityIndicator.stopAnimating()
        // Needed to trigger deallocation of ConnectViewController
        self.connectViewController = nil
        self.connectNavController = nil
    }
    
    func onLoad() {
        print("onLoad:")
        self.connectNavController = UINavigationController(rootViewController: self.connectViewController)
        if #available(iOS 13.0, *) {
            self.connectNavController.modalPresentationStyle = .automatic
            self.connectNavController.isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
        
        self.connectNavController.presentationController?.delegate = self
        self.present(self.connectNavController, animated: true)
    }
    
    func onRoute(_ data: NSDictionary?) {
        print("onRoute:")
        displayData(data)
    }
    
    func onUser(_ data: NSDictionary?) {
        print("onUser:")
        displayData(data)
    }
    
    func displayData(_ data: NSDictionary?) {
        print(data?.debugDescription ?? "no data in callback")
    }




```

**Note**: The onDone, onError, onRoute, and onUser callback functions will have a NSDictionary? parameter that contains data about the event.

## App to App Setup
To provide the best app to app experience for your customers, you should send a universal link URL in the redirect URL parameter when using Connect. See [here](https://developer.mastercard.com/drafts/open-banking-us/mobile-sdks/documentation/connect/mobile-sdks/#compatibility) for more information on App to App authentication.

Before installing the Connect iOS SDK for use with app to app authentication please complete the following.

### Create your domain’s redirectUrl
For information on how to create a [Universal Links](https://developer.apple.com/ios/universal-links/) to be used as redirectUrl in your application, see [Apple’s Allowing apps and websites to link to your content](https://developer.apple.com/documentation/xcode/allowing-apps-and-websites-to-link-to-your-content) for details.

>**NOTE:**
>In order to provide the best app to app customer experience, Partners should use a universal link as a redirectUrl.

>It is not recommended to create deep links (custom URL schemes) as redirectUrl since they lack the security of Universal Links through the two-way association between your app and your website. A deep link will also trigger an alert on iOS devices that can add friction to the customer experience, requesting permission to redirect back to the Partner’s app.

>Any application can register custom URL schemes and there is no further validation from iOS. If multiple applications have registered the same custom URL scheme, a different application may be launched each time the URL is opened. To complete OAuth flows, it is important that your application is opened and not any arbitrary application that has registered the same URL scheme.

### Configuring your redirectUrl
In order to return control back to your application after a customer completes a FI’s OAuth flow, you must specify a redirectUrl, which will be the URL from which Connect will be re-launched for a customer to complete the Connect experience.

Here is an example of a universal link redirectUrl within your code: ```self.connectViewController.load(connectUrl,redirectUrl: "https://yourdomain.com/mastercardConnect")```
For information on how to configure your server see [supporting associated domains](https://developer.apple.com/documentation/xcode/supporting-associated-domains)

Here is an example of a deep link redirectUrl within your code (Not Recommended): ```self.connectViewController.load(connectUrl,redirectUrl: "deeplinkurl://")```

### ConnectWrapper Swift Sample App
This repository contains a sample application ConnectWrapper written in Swift (requires Xcode 11 or greater) that demonstrates integration and use of Connect iOS SDK.


## Migrate From Framework to XCFramework
The Connect iOS SDK uses the XCFramework format which allows you to easily integrate the SDK into your development projects. Our iOS SDK has full bitcode support so that you don’t have to disable bitcode in your applications.

### Delete Connect.framework from your project
If you’re currently using framework in your projects, then you need to remove it before you start using the XCFramework. This ensures that the connect.framework won’t interfere with the new XCFramework while you’re trying to compile your source code.

>**WARNING:** Before deleting your existing framework, test the new XCFramework, and make sure it is working correctly so that you don’t accidentally delete your source files.

1. Open your project in Xcode.
2. Click the General tab.
3. Scroll down to the Frameworks, Libraries, and Embedded Content section.
4. Select connect.framework.
5. To delete the framework, click (–) minus.

### Remove the Connect.framework reference
1. From Project Navigator on the left pane, select Framework and press Delete.
2. Click Remove Reference (recommended) Note: This is the safest option to preserve your source files.

### Remove run script
If you’ve incorporated our script for stripping out the X86 simulator before submitting your application to the Apple App Store, you can remove the run script. It’s no longer needed with the XCFramework. Only customers that create a run script to incorporate with the connect-sdk-iOS-v1.2.0.zip need to do this step.

1. From Xcode in the right pane, select your Targets.
2. On the Build Phase tab, scroll down to Run Script
3. To remove the script, click the x.

Once you have migrated from the legacy framework to the new XCFramework, you can install the Connect iOS SDK via CocoaPods

[connect-sdk-version]: (https://img.shields.io/cocoapods/v/MastercardOpenBankingConnect.svg?style=flat)](https://cocoapods.org/pods/MastercardOpenBankingConnect)
[connect-sdk-url]: https://cocoapods.org/pods/MastercardOpenBankingConnect


