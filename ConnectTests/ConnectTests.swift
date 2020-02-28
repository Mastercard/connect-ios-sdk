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
    var doneCalled = false
    var errorCalled = false
    var cancelCalled = false
    var errorMessage = ""
    var config: ConnectViewConfig! = nil
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        self.loadedCalled = false
        self.doneCalled = false
        self.errorCalled = false
        self.cancelCalled = false
        self.errorMessage = ""
        self.config = ConnectViewConfig(connectUrl: "testConnectUrl", loaded: self.dummyLoadedCallback, done: self.dummyDoneCallback, cancel: self.dummyCancelCallback, error: self.dummyErrorCallback)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        self.loadedCalled = false
        self.doneCalled = false
        self.errorCalled = false
        self.cancelCalled = false
        self.errorMessage = ""
        self.config = nil
    }
    
    func testLoad() {
        let cvc = ConnectViewController()
        cvc.load(config: self.config)
        
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
        
        cvc.load(config: self.config)
        
        waitForExpectations(timeout: 1) { _ in
            XCTAssertTrue(cvc.didCallShowWebView)
            XCTAssertEqual("testConnectUrl", cvc.showWebViewTargetUrl)
        }
        
    }
    
    func testCallbacks() {
        let cvc = ConnectViewController()
        cvc.load(config: self.config)
        
        cvc.handleLoadingComplete()
        cvc.handleConnectComplete()
        cvc.handleConnectCancel()
        cvc.handleConnectError("testErrorMessage")
        
        XCTAssertTrue(self.loadedCalled)
        XCTAssertTrue(self.doneCalled)
        XCTAssertTrue(self.errorCalled)
        XCTAssertTrue(self.cancelCalled)
        XCTAssertEqual("testErrorMessage", self.errorMessage)
    }
    
    func testJailBreakCheck() {
        let cvc = ConnectViewController()
        XCTAssertFalse(cvc.hasBeenJailBroken())
    }
    
    func dummyLoadedCallback() {
        self.loadedCalled = true
    }
    
    func dummyErrorCallback(_ msg: String) {
        self.errorCalled = true
        self.errorMessage = msg
    }
    
    func dummyDoneCallback() {
        self.doneCalled = true
    }
    
    func dummyCancelCallback() {
        self.cancelCalled = true
    }

}
