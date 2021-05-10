//
//  ConnectTests.swift
//  ConnectTests
//
//  Copyright © 2020 finicity. All rights reserved.
//

import XCTest
@testable import Connect

class ConnectTests: XCTestCase {

    var onLoadCalled = false
    var onDoneCalled = false
    var onErrorCalled = false
    var onCancelCalled = false
    var onRouteCalled = false
    var onUserCalled = false
    var message: NSDictionary! = nil
    var config: ConnectViewConfig! = nil
    var onLoadExp: XCTestExpectation? = nil
    var onErrorExp: XCTestExpectation? = nil
    var onDoneExp: XCTestExpectation? = nil
    var onRouteExp: XCTestExpectation? = nil
    var onUserExp: XCTestExpectation? = nil
    var onCancelExp: XCTestExpectation? = nil
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        resetState()

        self.config = ConnectViewConfig(connectUrl: "testConnectUrl", onLoad: self.dummyLoadedCallback, onDone: self.dummyDoneCallback, onCancel: self.dummyCancelCallback, onError: self.dummyErrorCallback, onRoute: self.dummyRouteCallback, onUser: dummyUserCallback)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        resetState()
    }
    
    func resetState() {
        self.onLoadCalled = false
        self.onDoneCalled = false
        self.onErrorCalled = false
        self.onCancelCalled = false
        self.onRouteCalled = false
        self.onUserCalled = false
        self.config = nil
        self.message = nil
        self.onLoadExp = nil
        self.onErrorExp = nil
        self.onDoneExp = nil
        self.onRouteExp = nil
        self.onUserExp = nil
        self.onCancelExp = nil
    }
    
    func testVersionString() {
        let version = sdkVersion()
        XCTAssertEqual("2.0.0", version)
    }
    
    func testLoad() {
        let cvc = ConnectViewController()
        cvc.load(config: self.config)
        print(cvc.connectUrl)
        print(self.config.connectUrl)
        XCTAssertEqual("testConnectUrl", cvc.connectUrl)
    }
    
    func testLoadWebView() {
        self.onLoadExp = expectation(description: "Loaded callback")
        let cvc = ConnectViewController()
        cvc.load(config: self.config)
        waitForExpectations(timeout: 3) { _ in
            XCTAssertTrue(self.onLoadCalled)
            XCTAssertEqual("testConnectUrl", cvc.connectUrl)
        }
    }
    
    func testMemoryLeak() {
        self.onLoadExp = expectation(description: "Loaded callback")
        let cvc = ConnectViewController()
        cvc.load(config: self.config)
        waitForExpectations(timeout: 3) { _ in
            XCTAssertTrue(self.onLoadCalled)
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
        XCTAssertTrue(self.onLoadCalled)
        
        cvc.handleConnectCancel()
        XCTAssertTrue(self.onCancelCalled)
        
        self.message = ["key": "value"]
        cvc.handleConnectComplete(nil)
        XCTAssertTrue(self.onDoneCalled)
        XCTAssertEqual(nil, self.message)

        self.message = ["key": "value"]
        cvc.handleConnectError(nil)
        XCTAssertTrue(self.onErrorCalled)
        XCTAssertEqual(nil, self.message)
        
        self.message = ["key": "value"]
        cvc.handleConnectUser(nil)
        XCTAssertTrue(self.onUserCalled)
        XCTAssertEqual(nil, self.message)
        
        self.message = ["key": "value"]
        cvc.handleConnectRoute(nil)
        XCTAssertTrue(self.onRouteCalled)
        XCTAssertEqual(nil, self.message)
    }
    
    func testJailBreakCheck() {
        let cvc = ConnectViewController()
        XCTAssertFalse(cvc.hasBeenJailBroken())
    }
    
    func dummyLoadedCallback() {
        self.onLoadCalled = true
        self.onLoadExp?.fulfill()
    }
    
    func dummyCancelCallback() {
        self.onCancelCalled = true
        self.onCancelExp?.fulfill()
    }
    
    func dummyErrorCallback(_ data: NSDictionary?) {
        self.onErrorCalled = true
        self.message = data
        self.onErrorExp?.fulfill()
    }
    
    func dummyDoneCallback(_ data: NSDictionary?) {
        self.onDoneCalled = true
        self.message = data
        self.onDoneExp?.fulfill()
    }
    
    func dummyUserCallback(_ data: NSDictionary?) {
        self.onUserCalled = true
        self.message = data
        self.onUserExp?.fulfill()
    }
    
    func dummyRouteCallback(_ data: NSDictionary?) {
        self.onRouteCalled = true
        self.message = data
        self.onRouteExp?.fulfill()
    }

}
