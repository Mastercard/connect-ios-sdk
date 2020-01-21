//
//  ConnectViewController.swift
//  Connect
//
//  Copyright © 2020 finicity. All rights reserved.
//

import WebKit

public class ConnectViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    var webView: WKWebView!
    var childWebView: WKWebView!
    var isWebViewLoaded = false
    var isChildWebViewLoaded = false
    
    var loadedFunction: (() -> Void)!
    var closedFunction: (() -> Void)!
    var errorFunction: ((String) -> Void)!
    
    var redirectUrl = ""
    var closeOnRedirect = false
    var closeOnComplete = true
    
    var parentToolbarItems: [UIBarButtonItem]?
    
    var currentHost = ""
    var parentHost = ""
    
    var messageNameComplete = "complete"
    var messageNameError = "error"
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
    
    public func load(connectUrl: String, redirectUrl: String, onLoaded: @escaping () -> Void, onError: @escaping (String) -> Void, onClosed: @escaping () -> Void) {
        self.closeOnRedirect = true
        self.closeOnComplete = false
        
        self.redirectUrl = redirectUrl
        self.loadedFunction = onLoaded
        self.errorFunction = onError
        self.closedFunction = onClosed
        DispatchQueue.main.async {
            self.showWebView(connectUrl: connectUrl)
        }
    }
    
    public func load(connectUrl: String, onLoaded: @escaping () -> Void, onError: @escaping (String) -> Void, onClosed: @escaping () -> Void) {
        self.closeOnRedirect = false
        self.closeOnComplete = true
        
        self.loadedFunction = onLoaded
        self.errorFunction = onError
        self.closedFunction = onClosed
        DispatchQueue.main.async {
            self.showWebView(connectUrl: connectUrl)
        }
    }
    
    public func closeAndRemove() {
        self.willMove(toParent: nil)
        self.removeFromParent()
        self.view.removeFromSuperview()
    }
    
    func showWebView(connectUrl: String) {
        if let url = URL(string: connectUrl) {
            if (self.webView == nil) {
                let config = WKWebViewConfiguration()
                let userContentController = WKUserContentController()
                userContentController.add(self, name: self.messageNameComplete)
                userContentController.add(self, name: self.messageNameError)
                config.userContentController = userContentController
                
                self.webView = WKWebView(frame: .zero, configuration: config)
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
                self.loadedFunction()
            }
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let host = navigationAction.request.url?.host {
            if (navigationController?.navigationBar.isHidden == false) {
                navigationItem.title = host;
            }
            
            if self.redirectUrl.contains(host) && self.closeOnRedirect {
                decisionHandler(.cancel)
                self.closedFunction()
                return
            }
            
            // TODO: localhost is not the correct url to check. should it check
            // against a passed in string on load, or save off the old host prior to
            // loading childWebView and check for that?
            if host.contains("localhost") && self.isChildWebViewLoaded {
                decisionHandler(.cancel)
                self.unloadChildWebView()
                return
            }
            
            self.currentHost = host
        }
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            self.loadChildWebView(url: (navigationAction.request.url)!)
        }
        return nil
    }
    
    public func webViewDidClose(_ webView: WKWebView) {
        self.closedFunction()
    }
    func loadChildWebView(url: URL)  {
        self.parentHost = self.currentHost
        self.isChildWebViewLoaded = true;
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        var customRequest = URLRequest(url: url)
        customRequest.setValue("true", forHTTPHeaderField: "x-custom-header")
        
        self.childWebView = WKWebView()
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
            self.childWebView = nil
        }
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.name)
        if let messageBody = message.body as? String {
            print(messageBody)
        }
        
        if message.name == self.messageNameComplete && self.closeOnComplete {
            self.closedFunction()
        } else if message.name == self.messageNameError {
            self.errorFunction(message.body as? String ?? self.defaultErrorMessage)
        }
        
    }
}
