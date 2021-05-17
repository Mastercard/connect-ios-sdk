//
//  TestAppUITests.swift
//  TestAppUITests
//
//  Created by Jimmie Wright on 12/15/20.
//  Copyright © 2020 finicity. All rights reserved.
//

import XCTest
import FinicityConnect

var dynamicGeneratedUrl: String? = nil
let badExpiredUrl = "https://connect2.finicity.com?consumerId=dbceec20d8b97174e6aed204856f5a55&customerId=1016927519&partnerId=2445582695152&redirectUri=http%3A%2F%2Flocalhost%3A3001%2Fcustomers%2FredirectHandler&signature=abb1762e5c640f02823c56332daede3fe2f2143f4f5b8be6ec178ac72d7dbc5a&timestamp=1607806595887&ttl=1607813795887"

class TestAppUITests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // First time setup called try and dynamically generate a Connect URL using linked in static library FinicityConnect
        if dynamicGeneratedUrl == nil {
            let onGenerateExp = expectation(description: "generate url")
            FinicityConnect.generateUrlLink { success, urlLink in
                if success, let url = urlLink {
                    dynamicGeneratedUrl = url
                }
                onGenerateExp.fulfill()
            }
            waitForExpectations(timeout: 10) { _ in
                XCTAssertNotNil(dynamicGeneratedUrl)
            }
        }
        XCTAssertNotNil(dynamicGeneratedUrl)
    }

    func test01BadUrl() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Steps:
        // 1. Fill in textfield with bad/expired URL
        // 2. Tap Connect Button to launch WKWebView
        // 3. Assert Exit button exists
        // 4. Tap Exit button
        
        app.textFields[AccessiblityIdentifer.UrlTextField.rawValue].typeText(badExpiredUrl)
        app.buttons[AccessiblityIdentifer.ConnectButton.rawValue].tap()
        // Wait 5 seconds for WebView with Exit button
        XCTAssert(app.webViews.webViews.webViews.buttons["Exit"].waitForExistence(timeout: 5))
        app.webViews.webViews.webViews.buttons["Exit"].tap()

        sleep(2)
    }
    
    func test02GoodUrlCancel() throws {
        
        XCTAssertNotNil(dynamicGeneratedUrl)
        
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        // Steps:
        // 1. Fill in textfield with good URL
        // 2. Tap Connect Button to launch WKWebView
        // 3. Assert Exit button exists
        // 4. Tap Exit button
        // 5. Assert Yes button exists
        // 6. Tap Yes button
        
        app.textFields[AccessiblityIdentifer.UrlTextField.rawValue].typeText(dynamicGeneratedUrl!)
        app.buttons[AccessiblityIdentifer.ConnectButton.rawValue].tap()
        
        // Wait 5 seconds for WebView with Exit button
        let webViewsQuery = app.webViews.webViews.webViews
        XCTAssert(webViewsQuery.staticTexts["Exit"].waitForExistence(timeout: 5))
        webViewsQuery.staticTexts["Exit"].tap()
        // Wait 5 seconds for WebView with Yes button
        XCTAssert(webViewsQuery.buttons["Yes"].waitForExistence(timeout: 5))
        webViewsQuery.buttons["Yes"].tap()
        
        sleep(2)
    }
    
    func test03AddBankAccount() throws {
        
        XCTAssertNotNil(dynamicGeneratedUrl)
        
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        app.textFields[AccessiblityIdentifer.UrlTextField.rawValue].typeText(dynamicGeneratedUrl!)
        app.buttons[AccessiblityIdentifer.ConnectButton.rawValue].tap()

        let webViewsQuery = app.webViews.webViews.webViews
        XCTAssert(webViewsQuery.textFields["Search for your bank"].waitForExistence(timeout: 10))
        webViewsQuery.textFields["Search for your bank"].tap()
        webViewsQuery.textFields["Search for your bank"].typeText("finbank")
        XCTAssert(webViewsQuery.staticTexts["FinBank"].waitForExistence(timeout: 5))
        webViewsQuery.staticTexts["FinBank"].tap()
        XCTAssert(webViewsQuery.buttons["Next"].waitForExistence(timeout: 5))
        webViewsQuery.buttons["Next"].tap()
        XCTAssert(webViewsQuery.staticTexts["Banking Userid"].waitForExistence(timeout: 5))
        XCTAssert(webViewsQuery.staticTexts["Banking Password"].waitForExistence(timeout: 5))
        webViewsQuery.textFields["Banking Userid"].tap()
        webViewsQuery.textFields["Banking Userid"].typeText("demo")
        webViewsQuery.secureTextFields["Banking Password"].tap()
        webViewsQuery.secureTextFields["Banking Password"].typeText("go")
        webViewsQuery.buttons[" Secure sign in"].tap()
        XCTAssert(webViewsQuery.staticTexts["Eligible accounts"].waitForExistence(timeout: 15))
        webViewsQuery.otherElements["institution container"].children(matching: .other).element(boundBy: 2).switches["Account Checkbox"].tap()
        webViewsQuery.staticTexts["Savings"].swipeUp()
        XCTAssert(webViewsQuery.buttons["Save"].waitForExistence(timeout: 5))
        webViewsQuery.buttons["Save"].tap()
        XCTAssert(webViewsQuery.buttons["Submit"].waitForExistence(timeout: 5))
        webViewsQuery.buttons["Submit"].tap()
        
        sleep(2)
    }
    
    func test04SafariViewController() throws {
        
        XCTAssertNotNil(dynamicGeneratedUrl)
        
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        app.textFields[AccessiblityIdentifer.UrlTextField.rawValue].typeText(dynamicGeneratedUrl!)
        app.buttons[AccessiblityIdentifer.ConnectButton.rawValue].tap()

        let webViewsQuery = app.webViews.webViews.webViews
        XCTAssert(webViewsQuery.textFields["Search for your bank"].waitForExistence(timeout: 5))
        webViewsQuery.textFields["Search for your bank"].tap()
        webViewsQuery.textFields["Search for your bank"].typeText("finbank")
        XCTAssert(webViewsQuery.staticTexts["FinBank"].waitForExistence(timeout: 5))
        webViewsQuery.staticTexts["FinBank"].tap()
        XCTAssert(webViewsQuery.buttons["Next"].waitForExistence(timeout: 5))
        XCTAssert(webViewsQuery.staticTexts["Privacy policy"].waitForExistence(timeout: 5))
        webViewsQuery.staticTexts["Privacy policy"].tap()
        
        let doneButton = app.buttons["Done"]
        XCTAssert(doneButton.waitForExistence(timeout: 5))
        doneButton.tap()
    }
    
    func test05WindowOpen() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        app.textFields[AccessiblityIdentifer.UrlTextField.rawValue].typeText("https://pick3pro.com/TestOpenWin.html")
        app.buttons[AccessiblityIdentifer.ConnectButton.rawValue].tap()
        
        let webViewsQuery = app.webViews.webViews.webViews
        XCTAssert(webViewsQuery.buttons["Open Window"].waitForExistence(timeout: 5))
        webViewsQuery.buttons["Open Window"].tap()
        
        let doneButton = app.buttons["Done"]
        XCTAssert(doneButton.waitForExistence(timeout: 5))
        doneButton.tap()
    }
    
}
