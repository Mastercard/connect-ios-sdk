//
//  ConnectViewController.swift
//  Connect
//
//  Copyright © 2020 finicity. All rights reserved.
//

import WebKit

class ConnectWebView: WKWebView {
    override var inputAccessoryView: UIView? {
        // Overriding the default inputAccessoryView so the 'Done' button
        // does not appear when forms are focused.
        return nil
    }
}

public struct ConnectViewConfig {
    public var connectUrl: String
    public var loaded: (() -> Void)!
    public var done: (() -> Void)!
    public var cancel: (() -> Void)!
    public var error: ((String) -> Void)!
    
    public init(connectUrl: String,
         loaded: (() -> Void)? = nil,
         done: (() -> Void)? = nil,
         cancel: (() -> Void)? = nil,
         error: ((String) -> Void)? = nil) {
        self.connectUrl = connectUrl
        self.loaded = loaded
        self.done = done
        self.cancel = cancel
        self.error = error
    }
}

public class ConnectViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    var webView: ConnectWebView!
    var childWebView: ConnectWebView!
    var isWebViewLoaded = false
    var isChildWebViewLoaded = false
    
    var loadedFunction: (() -> Void)!
    var doneFunction: (() -> Void)!
    var cancelFunction: (() -> Void)!
    var errorFunction: ((String) -> Void)!
    
    internal var connectUrl: String = ""
    
    var parentToolbarItems: [UIBarButtonItem]?
    
    var messageNameConnect = "iosConnect"
    var messageTypeUrl = "url"
    var messageTypeError = "error"
    var messageTypeDone = "done"
    var messageTypeCancel = "cancel"
    var messageTypeClosePopup = "closePopup"
    var defaultErrorMessage = "Connect Error"
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override public func didMove(toParent parent: UIViewController?) {
        self.parentToolbarItems = parent?.toolbarItems
        
        parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(unloadChildWebView))

        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let refresh = UIBarButtonItem(barButtonSystemItem: .cancel, target: webView, action: #selector(webView.goBack))

        parent?.toolbarItems = [spacer, refresh]
        navigationController?.isToolbarHidden = true;
        navigationController?.setNavigationBarHidden(true, animated: false);
    }
    
    public func load(config: ConnectViewConfig) {
        self.connectUrl = config.connectUrl
        self.loadedFunction = config.loaded
        self.errorFunction = config.error
        self.doneFunction = config.done
        self.cancelFunction = config.cancel
        
        DispatchQueue.main.async {
            self.showWebView(connectUrl: self.connectUrl)
        }
    }
    
    public func load(connectUrl: String, onLoaded: @escaping () -> Void, onDone: @escaping () -> Void, onCancel: @escaping () -> Void, onError: @escaping (String) -> Void) {
        self.connectUrl = connectUrl
        self.loadedFunction = onLoaded
        self.doneFunction = onDone
        self.cancelFunction = onCancel
        self.errorFunction = onError
        
        DispatchQueue.main.async {
            self.showWebView(connectUrl: connectUrl)
        }
    }
    
    public func closeAndRemove() {
        self.willMove(toParent: nil)
        self.removeFromParent()
        self.view.removeFromSuperview()
        
        self.webView.navigationDelegate = nil
        self.webView.uiDelegate = nil
        self.webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        self.webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
    }
    
    func showWebView(connectUrl: String) {
        if let url = URL(string: connectUrl) {
            if (self.webView == nil) {
                let config = WKWebViewConfiguration()
                let userContentController = WKUserContentController()
                userContentController.add(self, name: self.messageNameConnect)
                config.userContentController = userContentController
                
                self.webView = ConnectWebView(frame: .zero, configuration: config)
                self.webView.frame = self.view.frame
                self.webView.navigationDelegate = self
                self.webView.uiDelegate = self
                self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
                self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
            }
            
            self.webView.load(URLRequest(url: url))
            self.webView.allowsBackForwardNavigationGestures = true
            self.view.addSubview(self.webView)
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
        print("Loading ChildWebView from non-standard location")
        if navigationAction.targetFrame == nil {
            self.loadChildWebView(url: (navigationAction.request.url)!)
        }
        return nil
    }
    
    public func webViewDidClose(_ webView: WKWebView) {
        self.handleConnectComplete()
    }
    
    func loadChildWebView(url: URL)  {
        self.isChildWebViewLoaded = true;
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        var customRequest = URLRequest(url: url)
        customRequest.setValue("true", forHTTPHeaderField: "x-custom-header")
        
        self.childWebView = ConnectWebView()
        self.childWebView.frame = self.view.frame
        self.childWebView.navigationDelegate = self
        self.childWebView.uiDelegate = self
        self.childWebView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        self.childWebView.load(customRequest)
        self.childWebView.allowsBackForwardNavigationGestures = true
        
        self.view.addSubview(self.childWebView)
    }
    
    @objc func unloadChildWebView(){
        if ((self.childWebView) != nil) {
            navigationController?.setNavigationBarHidden(true, animated: true);
            self.isChildWebViewLoaded = false
            self.childWebView.removeFromSuperview()
            self.childWebView.navigationDelegate = nil
            self.childWebView.uiDelegate = nil
            self.childWebView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
            
            let js = "window.postMessage({ type: 'window', closed: true }, '\(self.connectUrl)')"
            self.webView.evaluateJavaScript(js)
        }
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let messageBody = message.body as? [String: Any], let type = messageBody["type"] as? String {
            if type == self.messageTypeUrl, let urlString = messageBody["url"] as? String {
                if let url = URL(string: urlString) {
                    self.loadChildWebView(url: url)
                }
            } else if type == self.messageTypeError {
                self.handleConnectError(type)
            } else if type == self.messageTypeDone {
                self.handleConnectComplete()
            } else if type == self.messageTypeCancel {
                self.handleConnectCancel()
            } else if type == self.messageTypeClosePopup {
                self.unloadChildWebView()
            }
        }
    }
    
    internal func handleLoadingComplete() {
        if self.loadedFunction != nil {
            self.loadedFunction()
        }
    }
    
    internal func handleConnectComplete() {
        if self.doneFunction != nil {
            self.doneFunction()
        }
    }
    
    internal func handleConnectCancel() {
        if self.cancelFunction != nil {
            self.cancelFunction()
        }
    }
    
    internal func handleConnectError(_ msg: String?) {
        if self.errorFunction != nil {
            self.errorFunction(msg ?? self.defaultErrorMessage)
        }
    }
}
