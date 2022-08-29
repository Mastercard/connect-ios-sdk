//
//  ConnectTests.swift
//  ConnectTests
//
//  Copyright © 2022 MastercardOpenBanking. All rights reserved.
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
    var onLoadExp: XCTestExpectation? = nil
    var onErrorExp: XCTestExpectation? = nil
    var onDoneExp: XCTestExpectation? = nil
    var onRouteExp: XCTestExpectation? = nil
    var onUserExp: XCTestExpectation? = nil
    var onCancelExp: XCTestExpectation? = nil
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        resetState()
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
        cvc.load("testConnectUrl")
        cvc.delegate = self
        XCTAssertEqual("testConnectUrl", cvc.connectUrl)
    }
    
    func testLoadWebView() {
        self.onLoadExp = expectation(description: "Loaded callback")
        let cvc = ConnectViewController()
        cvc.load("testConnectUrl")
        cvc.delegate = self
        waitForExpectations(timeout: 3) { _ in
            XCTAssertTrue(self.onLoadCalled)
            XCTAssertEqual("testConnectUrl", cvc.connectUrl)
        }
    }
    
    func testMemoryLeak() {
        self.onLoadExp = expectation(description: "Loaded callback")
        let cvc = ConnectViewController()
        cvc.load("testConnectUrl")
        cvc.delegate = self
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
        cvc.load("testConnectUrl")
        cvc.delegate = self
        
        cvc.handleLoadingComplete()
        XCTAssertTrue(self.onLoadCalled)
        
        self.message = ["key": "value"]
        cvc.handleConnectCancel(nil)
        XCTAssertTrue(self.onCancelCalled)
        XCTAssertEqual(nil, self.message)
        
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

}

extension ConnectTests: ConnectEventDelegate {
    func onCancel(_ data: NSDictionary?) {
        self.onCancelCalled = true
        self.message = data
        self.onCancelExp?.fulfill()
    }
    func onDone(_ data: NSDictionary?) {
        self.onDoneCalled = true
        self.message = data
        self.onDoneExp?.fulfill()
    }
    func onError(_ data: NSDictionary?) {
        self.onErrorCalled = true
        self.message = data
        self.onErrorExp?.fulfill()
    }
    func onLoad() {
        self.onLoadCalled = true
        self.onLoadExp?.fulfill()
    }
    func onRoute(_ data: NSDictionary?) {
        self.onRouteCalled = true
        self.message = data
        self.onRouteExp?.fulfill()
    }
    func onUser(_ data: NSDictionary?) {
        self.onUserCalled = true
        self.message = data
        self.onUserExp?.fulfill()
    }
}
