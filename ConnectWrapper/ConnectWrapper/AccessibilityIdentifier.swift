//
//  AccessibilityIdentifier.swift
//  ConnectWrapper
//
//  Created by Jimmie Wright on 2/2/21.
//  Copyright © 2021 MastercardOpenBanking. All rights reserved.
//

import Foundation

// A centralized place to store strings for accessibility identifiers so you
// refer to them in both the application and tests.  These are strings which
// will not be read out loud to the user, so they do not need to be localized.

enum AccessiblityIdentifer: String {
    case urlTextField = "URL Textfield",
         connectButton = "Connect Button"
}
