# MastercardOpenBankingConnect iOS SDK [![version][connect-sdk-version]][connect-sdk-url]

## Overview

The MastercardOpenBankingConnect iOS SDK allows you to embed our Mastercard Connect application anywhere you want within your own mobile applications.

The iOS SDK is distributed as a compiled binary in XCFramework format which allows you to easily integrate our SDK into your development projects.  Our iOS SDK has full bitcode support so that you don’t have to disable bitcode in your applications when integrating with our SDK.

The XCFramework format is Apple’s officially supported format for distributing binary libraries for multiple platforms and architectures in a single bundle.

Additional documentation for the Connect iOS SDK can be found at (https://developer.mastercard.com/open-banking/staging/documentation/connect/mobile-sdks/#ios)

## Requirements

The Connect iOS SDK supports iOS 11 or later.

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

<img src="https://prod-findocs.s3-us-west-2.amazonaws.com/wp-content/uploads/2020/12/03124541/iOS_AddXCFramework.png" width=100%>

2. In the build settings for your target, select the **General** tab, scroll down to the **Frameworks, Libraries, and Embedded Content**, and select Connect.xcframework.  Under the **Embed** column, select **Embed & Sign** from the menu drop-down list if is not already selected.

<img src="https://prod-findocs.s3-us-west-2.amazonaws.com/wp-content/uploads/2020/12/03124538/iOS_EmbedSign.png" width=100%>

## Integration

1. Add import Connect into all your source files that make calls to the Connect iOS SDK.
```
import UIKit
import Connect
```
2. Create callback functions for loaded, done, cancel, error, route, and user events.    
    These callbacks correspond to the following events in Connect's data flow:

    | Event | Description |
    | ------ | ------ |
    | loaded | Called when the Connect web page is loaded and ready to display. |
    | done | Called when the user successfully completes the Connect application. It also has an unlabeled NSDictionary? parameter containing event information. |
    | cancel | Called when the user cancels the Connect application. |
    | error | Called when an error occurs while the user is using the Connect application. The unlabeled NSDictionary? parameter contains event information. |
    | route | Called with the user is navigating through the screens of the Connect application. The unlabeled NSDictionary? parameter containing event information. |
    | user | Connect 2.0 (only)  Called when a user performs an action. User events provide visibility into what action a user could take within the Connect application. The unlabeled NSDictionary? parameter contains event information. |
    
    **Note:** The done, error, route, and user callback functions will have a **NSDictionary?** parameter that contains data about the event.

3. Using a valid Connect URL and callback functions, create a Connect URL.  See [Generate 2.0 Connect URL APIs](https://developer.mastercard.com/open-banking-connect/documentation/) (Used it as `generatedConnectURL` in example code below)
4. Create an instance of the ConnectViewController class, providing the ConnectViewConfig class as input when calling its load method.
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
    
    // 
    func openConnect(connectUrl: String) {
        self.connectViewController = ConnectViewController()
        self.connectViewController.delegate = self
        self.connectViewController.load(connectUrl!)
    }
    
    
    // MastercardOpenBankingConnect Delegate Methods
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
### ConnectWrapper Swift Sample App

This repository contains a sample application ConnectWrapper written in Swift (requires Xcode 11 or greater) that demonstrates integration and use of Connect iOS SDK.

[connect-sdk-version]: (https://img.shields.io/cocoapods/v/MastercardOpenBankingConnect.svg?style=flat)](https://cocoapods.org/pods/MastercardOpenBankingConnect)
[connect-sdk-url]: https://cocoapods.org/pods/MastercardOpenBankingConnect
