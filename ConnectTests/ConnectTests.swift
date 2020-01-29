//
//  ConnectTests.swift
//  ConnectTests
//
//  Copyright © 2020 finicity. All rights reserved.
//

import XCTest
@testable import Connect

class ConnectTests: XCTestCase {

    var loadedCalled = false
    var closedCalled = false
    var errorCalled = false
    var errorMessage = ""
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        self.loadedCalled = false
        self.closedCalled = false
        self.errorCalled = false
        self.errorMessage = ""
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testLoad() {
        let cvc = ConnectViewController()
        cvc.load(connectUrl: "testConnectUrl", onLoaded: self.dummyLoadedCallback, onError: self.dummyErrorCallback, onClosed: self.dummyClosedCallback)
        
        XCTAssertEqual("testConnectUrl", cvc.connectUrl)
    }
    
    func testShowWebViewCalled() {
        let showWebViewExpectation = expectation(description: "showWebView")
        
        class CVCMock: ConnectViewController {
            var showWebViewExpectation: XCTestExpectation!
            var didCallShowWebView = false
            var showWebViewTargetUrl = ""
            
            override func showWebView(connectUrl: String) {
                self.didCallShowWebView = true
                self.showWebViewTargetUrl = connectUrl
                self.showWebViewExpectation.fulfill()
            }
        }
        
        let cvc = CVCMock()
        XCTAssertFalse(cvc.didCallShowWebView)
        
        cvc.showWebViewExpectation = showWebViewExpectation
        
        cvc.load(connectUrl: "testConnectUrl", onLoaded: self.dummyLoadedCallback, onError: self.dummyErrorCallback, onClosed: self.dummyClosedCallback)
        
        waitForExpectations(timeout: 1) { _ in
            XCTAssertTrue(cvc.didCallShowWebView)
            XCTAssertEqual("testConnectUrl", cvc.showWebViewTargetUrl)
        }
        
    }
    
    func testCallbacks() {
        let cvc = ConnectViewController()
        cvc.load(connectUrl: "testConnectUrl", onLoaded: self.dummyLoadedCallback, onError: self.dummyErrorCallback, onClosed: self.dummyClosedCallback)
        
        cvc.handleLoadingComplete()
        cvc.handleConnectComplete()
        cvc.handleConnectError("testErrorMessage")
        
        XCTAssertTrue(self.loadedCalled)
        XCTAssertTrue(self.closedCalled)
        XCTAssertTrue(self.errorCalled)
        XCTAssertEqual("testErrorMessage", self.errorMessage)
    }
    
    func dummyLoadedCallback() {
        self.loadedCalled = true
    }
    
    func dummyErrorCallback(_ msg: String) {
        self.errorCalled = true
        self.errorMessage = msg
    }
    
    func dummyClosedCallback() {
        self.closedCalled = true
    }

}
