//
//  ConnectViewController.swift
//  Connect
//
//  Copyright © 2020 finicity. All rights reserved.
//

import WebKit
import LocalAuthentication
import SafariServices

public protocol ConnectEventDelegate: AnyObject {
    func onCancel(_ data: NSDictionary?)
    func onDone(_ data: NSDictionary?)
    func onError(_ data: NSDictionary?)
    func onLoad()
    func onRoute(_ data: NSDictionary?)
    func onUser(_ data: NSDictionary?)
}

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

private enum ConnectEvents: String {
    // Internal events used by Connect
    case ACK = "ack"
    case CLOSEPOPUP = "closePopup"
    case PING = "ping"
    case URL = "url"
    
    // App events exposed to developers
    case CANCEL = "cancel"
    case DONE = "done"
    case ERROR = "error"
    case ROUTE = "route"
    case USER = "user"
}

public class ConnectViewController: UIViewController {
    // MARK: - Instance variables
    public weak var delegate: ConnectEventDelegate?
    internal var webView: ConnectWebView!
    internal var childWebView: SFSafariViewController!
    internal var pingTimer: Timer?
    internal var connectUrl: String = ""
    internal var messageNameConnect = "iosConnect"
    internal var hasDeviceLockVerification = false
    internal var isJailBroken = false
    internal var removeObserver = false
    internal var isWebViewLoaded = false
    internal var isChildWebViewLoaded = false
    
    // MARK: - View/Lifecycle functions
    deinit {
        // Some squirrly hack to get rid of assertions showing up in console when deallocating.
        if webView != nil {
            let newView = UIView()
            newView.addSubview(webView)
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(unloadChildWebView))
        
        let laContext = LAContext()
        if laContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            self.hasDeviceLockVerification = false
        } else {
            self.hasDeviceLockVerification = true
        }
        
        self.isJailBroken = self.hasBeenJailBroken()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        self.unload()
        stopPingTimer()
    }
    
    // MARK: - Webview load/unload/close/show functions
    public func load(_ connectUrl: String) {
        self.connectUrl = connectUrl
        DispatchQueue.main.async {
            self.showWebView(connectUrl: self.connectUrl)
        }
    }
    
    public func unload() {
        if self.removeObserver {
            self.webView.navigationDelegate = nil
            self.webView.uiDelegate = nil
            self.webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
            self.webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
            self.webView.configuration.userContentController.removeScriptMessageHandler(forName: messageNameConnect)
            self.removeObserver = false
        }
    }
    
    public func close() {
        stopPingTimer()
        self.removeObserver = true
        self.navigationController?.dismiss(animated: true)
    }
    
    func showWebView(connectUrl: String) {
        if let url = URL(string: connectUrl) {
            if self.webView == nil {
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
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" && !self.isWebViewLoaded {
            if self.webView.estimatedProgress == 1.0 {
                self.isWebViewLoaded = true
                self.handleLoadingComplete()
            }
        }
    }
    
    // MARK: - Safari/Popup functions
    func loadChildWebView(url: URL) {
        self.isChildWebViewLoaded = true
        self.childWebView = SFSafariViewController(url: url)
        self.childWebView.delegate = self
        present(self.childWebView, animated: true, completion: nil)
    }
    
    @objc func unloadChildWebView() {
        if self.childWebView != nil && self.isChildWebViewLoaded {
            navigationController?.setNavigationBarHidden(true, animated: true)
            childWebView.dismiss(animated: true, completion: nil)
            self.postWindowClosedMessage()
        }
    }
    
    // MARK: - Functions to interact with Connect
    func postWindowClosedMessage() {
        let javascript = "window.postMessage({ type: 'window', closed: true }, '\(self.connectUrl)')"
        self.webView.evaluateJavaScript(javascript)
        self.isChildWebViewLoaded = false
    }
    
    // MARK: - Ping Handling functions
    @objc func pingConnect() {
        let javascript = "window.postMessage({ type: 'ping', sdkVersion: '\(sdkVersion())', platform: 'iOS' }, '\(self.connectUrl)')"
        self.webView.evaluateJavaScript(javascript)
    }

    internal func startPingTimer() {
        if pingTimer != nil {
            pingTimer?.invalidate()
            pingTimer = nil
        }
        pingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(pingConnect), userInfo: nil, repeats: true)
    }
    
    internal func stopPingTimer() {
        if pingTimer != nil {
            pingTimer?.invalidate()
            pingTimer = nil
        }
    }
    
    // MARK: - Event Handling functions
    internal func handleLoadingComplete() {
        self.delegate?.onLoad()
        startPingTimer()
    }
    
    internal func getDataDictFromMessage(_ message: [String: Any]?) -> NSDictionary? {
        return message?["data"] as? NSDictionary ?? message?["query"] as? NSDictionary ?? nil
    }
    
    internal func handleConnectComplete(_ message: [String: Any]?) {
        self.close()
        self.delegate?.onDone(getDataDictFromMessage(message))
    }
    
    internal func handleConnectCancel(_ message: [String: Any]?) {
        self.close()
        self.delegate?.onCancel(getDataDictFromMessage(message))
    }
    
    internal func handleConnectError(_ message: [String: Any]?) {
        self.close()
        self.delegate?.onError(getDataDictFromMessage(message))
    }
    
    internal func handleConnectRoute(_ message: [String: Any]?) {
        self.delegate?.onRoute(getDataDictFromMessage(message))
    }
    
    internal func handleConnectUser(_ message: [String: Any]?) {
        self.delegate?.onUser(getDataDictFromMessage(message))
    }
    
    // MARK: - JailBroken functions
    internal func hasBeenJailBroken() -> Bool {
        let fileMgr = FileManager()
        if fileMgr.fileExists(atPath: "Applications/Cydia.app") || fileMgr.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib") {
            return true
        }
        return false
    }
}

// MARK: - Webview Navigation Delegate functions
extension ConnectViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let host = navigationAction.request.url?.host {
            if navigationController?.navigationBar.isHidden == false {
                navigationItem.title = host
            }
        }
        decisionHandler(.allow)
    }
}

// MARK: - Webview UI Delegate functions
extension ConnectViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Triggered by window.open()
        if navigationAction.targetFrame == nil {
            self.loadChildWebView(url: (navigationAction.request.url)!)
        }
        return nil
    }
    
    public func webViewDidClose(_ webView: WKWebView) {
        self.handleConnectComplete(nil)
    }
}

// MARK: - Interface for receiving messages from JavaScript
extension ConnectViewController: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let messageBody = message.body as? [String: Any], let type = messageBody["type"] as? String {
            if type == ConnectEvents.URL.rawValue, let urlString = messageBody["url"] as? String {
                if let url = URL(string: urlString) {
                    self.loadChildWebView(url: url)
                }
            } else if type == ConnectEvents.ERROR.rawValue {
                self.handleConnectError(messageBody)
            } else if type == ConnectEvents.DONE.rawValue {
                self.handleConnectComplete(messageBody)
            } else if type == ConnectEvents.CANCEL.rawValue {
                self.handleConnectCancel(messageBody)
            } else if type == ConnectEvents.CLOSEPOPUP.rawValue {
                self.unloadChildWebView()
            } else if type == ConnectEvents.ROUTE.rawValue {
                self.handleConnectRoute(messageBody)
            } else if type == ConnectEvents.USER.rawValue {
                self.handleConnectUser(messageBody)
            } else if type == ConnectEvents.ACK.rawValue {
                stopPingTimer()
            }
        }
    }
}

// MARK: - Safari ViewController Delegate functions
extension ConnectViewController: SFSafariViewControllerDelegate {
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)

        if self.isChildWebViewLoaded {
            self.postWindowClosedMessage()
        }
    }
}
