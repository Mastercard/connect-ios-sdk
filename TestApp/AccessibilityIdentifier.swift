//
//  AccessibilityIdentifier.swift
//  TestApp
//
//  Created by Jimmie Wright on 12/15/20.
//  Copyright © 2020 finicity. All rights reserved.
//

import Foundation

// A centralized place to store strings for accessibility identifiers so you
// refer to them in both the application and tests.  These are strings which
// will not be read out loud to the user, so they do not need to be localized.

enum AccessiblityIdentifer: String {
    case UrlTextField = "URL Textfield",
         ConnectButton = "Connect Button"
}
