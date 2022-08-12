//
//  Version.swift
//  Connect
//
//  Copyright © 2022 MastercardOpenBanking. All rights reserved.
//

import Foundation

public func sdkVersion() -> String {
    var version: String?
    if let dict = Bundle(identifier: "com.MastercardOpenBanking.Connect")?.infoDictionary {
        version = dict["CFBundleShortVersionString"] as? String
    }
    return version ?? "2.0.0"
}
