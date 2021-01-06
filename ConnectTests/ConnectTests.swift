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
    var errorMessage: NSDictionary! = nil
    var config: ConnectViewConfig! = nil
    var loadedExp: XCTestExpectation? = nil
    var errorExp: XCTestExpectation? = nil
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        self.loadedCalled = false
        self.doneCalled = false
        self.errorCalled = false
        self.cancelCalled = false
        self.errorMessage = nil
        self.config = ConnectViewConfig(connectUrl: "testConnectUrl", loaded: self.dummyLoadedCallback, done: self.dummyDoneCallback, cancel: self.dummyCancelCallback, error: self.dummyErrorCallback)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        self.loadedCalled = false
        self.doneCalled = false
        self.errorCalled = false
        self.cancelCalled = false
        self.errorMessage = nil
        self.config = nil
        self.loadedExp = nil
        self.errorExp = nil
    }
    
    func testVersionString() {
        let version = sdkVersion()
        XCTAssertEqual("1.3.1", version)
    }
    
    func testLoad() {
        let cvc = ConnectViewController()
        cvc.load(config: self.config)
        print(cvc.connectUrl)
        print(self.config.connectUrl)
        XCTAssertEqual("testConnectUrl", cvc.connectUrl)
    }
    
    func testLoadWebView() {
        self.loadedExp = expectation(description: "Loaded callback")
        let cvc = ConnectViewController()
        cvc.load(config: self.config)
        waitForExpectations(timeout: 3) { _ in
            XCTAssertTrue(self.loadedCalled)
            XCTAssertEqual("testConnectUrl", cvc.connectUrl)
        }
    }
    
    func testMemoryLeak() {
        self.loadedExp = expectation(description: "Loaded callback")
        let cvc = ConnectViewController()
        cvc.load(config: self.config)
        waitForExpectations(timeout: 3) { _ in
            XCTAssertTrue(self.loadedCalled)
            XCTAssertEqual("testConnectUrl", cvc.connectUrl)
        }
        
        cvc.close()
        cvc.unload()
        
        addTeardownBlock { [weak cvc] in
            XCTAssertNil(cvc)
        }
    }
    
//    func testShowWebViewCalled() {
//        let showWebViewExpectation = expectation(description: "showWebView")
//        
//        class CVCMock: ConnectViewController {
//            var showWebViewExpectation: XCTestExpectation!
//            var didCallShowWebView = false
//            var showWebViewTargetUrl = ""
//            
//            override func showWebView(connectUrl: String) {
//                self.didCallShowWebView = true
//                self.showWebViewTargetUrl = connectUrl
//                self.showWebViewExpectation.fulfill()
//            }
//        }
//        
//        let cvc = CVCMock()
//        XCTAssertFalse(cvc.didCallShowWebView)
//        
//        cvc.showWebViewExpectation = showWebViewExpectation
//        
//        cvc.load(config: self.config)
//        
//        waitForExpectations(timeout: 1) { _ in
//            XCTAssertTrue(cvc.didCallShowWebView)
//            XCTAssertEqual("testConnectUrl", cvc.showWebViewTargetUrl)
//        }
//        
//    }
    
    func testCallbacks() {
        let cvc = ConnectViewController()
        cvc.load(config: self.config)
        
        cvc.handleLoadingComplete()
        cvc.handleConnectComplete(nil)
        cvc.handleConnectCancel()
        cvc.handleConnectError(nil)
        
        XCTAssertTrue(self.loadedCalled)
        XCTAssertTrue(self.doneCalled)
        XCTAssertTrue(self.errorCalled)
        XCTAssertTrue(self.cancelCalled)
        XCTAssertEqual(nil, self.errorMessage)
    }
    
    func testJailBreakCheck() {
        let cvc = ConnectViewController()
        XCTAssertFalse(cvc.hasBeenJailBroken())
    }
    
    func dummyLoadedCallback() {
        self.loadedCalled = true
        self.loadedExp?.fulfill()
    }
    
    func dummyErrorCallback(_ data: NSDictionary?) {
        self.errorCalled = true
        self.errorMessage = data
        self.errorExp?.fulfill()
    }
    
    func dummyDoneCallback(_ data: NSDictionary?) {
        self.doneCalled = true
    }
    
    func dummyCancelCallback() {
        self.cancelCalled = true
    }

}
