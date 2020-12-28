//
//  ConnectViewController.swift
//  Connect
//
//  Copyright © 2020 finicity. All rights reserved.
//

import WebKit
import LocalAuthentication
import SafariServices

class ConnectWebView: WKWebView {
    override var inputAccessoryView: UIView? {
        // Overriding the default inputAccessoryView so the 'Done' button
        // does not appear when forms are focused.
        return nil
    }
    override var safeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            let insects = super.safeAreaInsets
            return UIEdgeInsets(top: insects.top, left: insects.left, bottom: 0, right: insects.right)
        } else {
            return .zero
        }
    }
}

public struct ConnectViewConfig {
    public var connectUrl: String
    public var loaded: (() -> Void)!
    public var done: ((NSDictionary?) -> Void)!
    public var cancel: (() -> Void)!
    public var error: ((NSDictionary?) -> Void)!
    public var route: ((NSDictionary?) -> Void)!
    public var user: ((NSDictionary?) -> Void)!
    
    public init(connectUrl: String,
         loaded: (() -> Void)? = nil,
         done: ((NSDictionary?) -> Void)? = nil,
         cancel: (() -> Void)? = nil,
         error: ((NSDictionary?) -> Void)? = nil,
         route: ((NSDictionary?) -> Void)? = nil,
         userEvent: ((NSDictionary?) -> Void)? = nil) {
        self.connectUrl = connectUrl
        self.loaded = loaded
        self.done = done
        self.cancel = cancel
        self.error = error
        self.route = route
        self.user = userEvent
    }
}

public class ConnectViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler, SFSafariViewControllerDelegate {
    var webView: ConnectWebView!
    var childWebView: SFSafariViewController!
    var isWebViewLoaded = false
    var isChildWebViewLoaded = false
    
    var loadedFunction: (() -> Void)!
    var doneFunction: ((NSDictionary?) -> Void)!
    var cancelFunction: (() -> Void)!
    var errorFunction: ((NSDictionary?) -> Void)!
    var routeFunction: ((NSDictionary?) -> Void)!
    var userFunction: ((NSDictionary?) -> Void)!

    
    internal var connectUrl: String = ""
    
    var messageNameConnect = "iosConnect"
    var messageTypeUrl = "url"
    var messageTypeError = "error"
    var messageTypeDone = "done"
    var messageTypeCancel = "cancel"
    var messageTypeClosePopup = "closePopup"
    var messageTypeRoute = "route"
    var messageTypeUser = "user"
    var defaultErrorMessage = "Connect Error"
    
    internal var hasDeviceLockVerification = false
    internal var isJailBroken = false
    
    var removeObserver = false
    
    deinit {
        print("ConnectViewController - deallocated")
        // Some squirrly hack to get rid of assertions showing up in console when deallocating.
        let newView = UIView()
        newView.addSubview(webView)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(unloadChildWebView))
        
        let laContext = LAContext()
        if (laContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)) {
            self.hasDeviceLockVerification = false;
        } else {
            self.hasDeviceLockVerification = true;
        }
        
        self.isJailBroken = self.hasBeenJailBroken()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        self.unload()
    }
    
    public func load(config: ConnectViewConfig) {
        self.connectUrl = config.connectUrl
        self.loadedFunction = config.loaded
        self.errorFunction = config.error
        self.doneFunction = config.done
        self.cancelFunction = config.cancel
        self.routeFunction = config.route
        self.userFunction = config.user
        
        DispatchQueue.main.async {
            self.showWebView(connectUrl: self.connectUrl)
        }
    }
    
    public func load(connectUrl: String, onLoaded: @escaping () -> Void, onDone: @escaping (NSDictionary?) -> Void, onCancel: @escaping () -> Void, onError: @escaping (NSDictionary?) -> Void) {
        self.connectUrl = connectUrl
        self.loadedFunction = onLoaded
        self.doneFunction = onDone
        self.cancelFunction = onCancel
        self.errorFunction = onError
        
        DispatchQueue.main.async {
            self.showWebView(connectUrl: connectUrl)
        }
    }
    
    public func unload() {
        if (self.removeObserver) {
            self.webView.navigationDelegate = nil
            self.webView.uiDelegate = nil
            self.webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
            self.webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
            self.webView.configuration.userContentController.removeScriptMessageHandler(forName: messageNameConnect)
            self.removeObserver = false
        }
    }
    
    public func close() {
        self.removeObserver = true;
        self.navigationController?.dismiss(animated: false)
    }
    
    func showWebView(connectUrl: String) {
        if let url = URL(string: connectUrl) {
            if (self.webView == nil) {
                let config = WKWebViewConfiguration()
                let userContentController = WKUserContentController()
                userContentController.add(self, name: self.messageNameConnect)
                config.userContentController = userContentController
                
                self.webView = ConnectWebView(frame: .zero, configuration: config)
                self.webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.webView.frame = self.view.frame
                self.view.addSubview(self.webView)
                self.webView.allowsBackForwardNavigationGestures = true
                self.webView.navigationDelegate = self
                self.webView.uiDelegate = self
                self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
                self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
                self.removeObserver = false
            }
            
            self.webView.load(URLRequest(url: url))
        }
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" && !self.isWebViewLoaded {
            if (self.webView.estimatedProgress == 1.0) {
                self.isWebViewLoaded = true
                self.handleLoadingComplete()
            }
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let host = navigationAction.request.url?.host {
            if (navigationController?.navigationBar.isHidden == false) {
                navigationItem.title = host;
            }
        }
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // TODO: When would this happen? - Not during OAuth
        // print("Loading ChildWebView from non-standard location")
        if navigationAction.targetFrame == nil {
            self.loadChildWebView(url: (navigationAction.request.url)!)
        }
        return nil
    }
    
    public func webViewDidClose(_ webView: WKWebView) {
        self.handleConnectComplete(nil)
    }
    
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)

        if self.isChildWebViewLoaded {
            self.postWindowClosedMessage()
        }
    }
    
    func loadChildWebView(url: URL) {
        self.isChildWebViewLoaded = true;
        self.childWebView = SFSafariViewController(url: url);
        self.childWebView.delegate = self;
        present(self.childWebView, animated: true, completion: nil);
    }
    
    @objc func unloadChildWebView() {
        if ((self.childWebView) != nil && self.isChildWebViewLoaded) {
            navigationController?.setNavigationBarHidden(true, animated: true);
            childWebView.dismiss(animated: true, completion: nil);
            self.postWindowClosedMessage()
        }
    }
    
    func postWindowClosedMessage() {
        let js = "window.postMessage({ type: 'window', closed: true }, '\(self.connectUrl)')"
        self.webView.evaluateJavaScript(js)
        self.isChildWebViewLoaded = false;
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let messageBody = message.body as? [String: Any], let type = messageBody["type"] as? String {
            if type == self.messageTypeUrl, let urlString = messageBody["url"] as? String {
                if let url = URL(string: urlString) {
                    self.loadChildWebView(url: url)
                }
            } else if type == self.messageTypeError {
                self.handleConnectError(messageBody)
            } else if type == self.messageTypeDone {
                self.handleConnectComplete(messageBody)
            } else if type == self.messageTypeCancel {
                self.handleConnectCancel()
            } else if type == self.messageTypeClosePopup {
                self.unloadChildWebView()
            } else if type == self.messageTypeRoute {
                self.handleConnectRoute(messageBody)
            } else if type == self.messageTypeUser {
                self.handleConnectUser(messageBody)
            }
        }
    }
    
    internal func sendVersionInfoToWebview() {
        // Create dictionary with version info
        let data = ["type":"sdkVersion","version":sdkVersion(),"os":"iOS"]
        let serializedData = try! JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        let encodedData = serializedData.base64EncodedString(options: .endLineWithLineFeed)
        if webView != nil {
            webView.evaluateJavaScript("getSdkVersionInfo('\(encodedData)')", completionHandler: nil)
        }
    }
    
    internal func handleLoadingComplete() {
        if self.loadedFunction != nil {
            self.loadedFunction()
        }
        sendVersionInfoToWebview()
    }
    
    internal func handleConnectComplete(_ message: [String: Any]?) {
        self.close()
        if self.doneFunction != nil {
            if let data = message?["data"] as? NSDictionary {
                self.doneFunction(data)
            } else if let query = message?["query"] as? NSDictionary {
                self.doneFunction(query)
            } else {
                self.doneFunction(nil)
            }
            
        }
    }
    
    internal func handleConnectCancel() {
        self.close()
        if self.cancelFunction != nil {
            self.cancelFunction()
        }
    }
    
    internal func handleConnectError(_ message: [String: Any]?) {
        self.close()
        if self.errorFunction != nil {
            if let data = message?["data"] as? NSDictionary {
                self.errorFunction(data)
            } else if let query = message?["query"] as? NSDictionary {
                self.errorFunction(query)
            } else {
                self.errorFunction(nil)
            }
        }
    }
    
    internal func handleConnectRoute(_ message: [String: Any]?) {
        if self.routeFunction != nil {
            if let data = message?["data"] as? NSDictionary {
                self.routeFunction(data)
            } else if let query = message?["query"] as? NSDictionary {
                self.routeFunction(query)
            } else {
                self.routeFunction(nil)
            }
        }
    }
    
    internal func handleConnectUser(_ message: [String: Any]?) {
        if self.userFunction != nil {
            if let data = message?["data"] as? NSDictionary {
                self.userFunction(data)
            } else if let query = message?["query"] as? NSDictionary {
                self.userFunction(query)
            } else {
                self.userFunction(nil)
            }
        }
    }
    
    internal func hasBeenJailBroken() -> Bool {
        let fm = FileManager()
        if (fm.fileExists(atPath: "Applications/Cydia.app") || fm.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib")) {
            return true
        }
        
        return false
    }
}
