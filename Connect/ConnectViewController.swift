//
//  ConnectViewController.swift
//  Connect
//
//  Created by Sid Pitt on 12/16/19.
//  Copyright © 2019 finicity. All rights reserved.
//

import WebKit
import SafariServices

public class ConnectViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    var safariViewController:SFSafariViewController? = nil;
    var webView: WKWebView!
    var childWebView: WKWebView!
    var isWebViewLoaded = false;
    var isChildWebViewLoaded = false;
    
    var loadedFunction: (() -> Void)!
    var closedFunction: (() -> Void)!
    
    var redirectUrl = ""
    
    var parentToolbarItems: [UIBarButtonItem]?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let nc = NotificationCenter.default
        let notificationName = Notification.Name("closesafariViewController");
        // Register to receive notification
        nc.addObserver(self, selector: #selector(self.closeSafariViewController), name: notificationName, object: nil);
    }
    
    override public func didMove(toParent parent: UIViewController?) {
        self.parentToolbarItems = parent?.toolbarItems
        
        print("didMove!!")
        
        parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(unloadChildWebView))

        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let refresh = UIBarButtonItem(barButtonSystemItem: .cancel, target: webView, action: #selector(webView.goBack))

        parent?.toolbarItems = [spacer, refresh]
        navigationController?.isToolbarHidden = true;
        navigationController?.setNavigationBarHidden(true, animated: false);
    }
    
    public func load(connectUrl: String, redirectUrl: String, onLoaded: @escaping () -> Void, onClosed: @escaping () -> Void) {
        self.redirectUrl = redirectUrl
        self.loadedFunction = onLoaded
        self.closedFunction = onClosed
        print("load...")
        DispatchQueue.main.async {
            self.showWebView(connectUrl: connectUrl)
        }
    }
    
    public func loadSafari(connectUrl: String) -> SFSafariViewController? {
        if let url = URL(string: connectUrl) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let sfViewController = SFSafariViewController(url: url, configuration: config)
            
            self.safariViewController = sfViewController
            return sfViewController
//            self.present(self.safariViewController!, animated: true)
        }
        
        return nil
    }
    
    public func openWebKit(connectUrl: String, onLoaded: @escaping () -> Void, onClosed: @escaping () -> Void) {
        
        self.loadedFunction = onLoaded
        self.closedFunction = onClosed
        DispatchQueue.main.async {
            self.showWebView(connectUrl: connectUrl)
        }
    }
    
    public func closeWebKit() {
        self.willMove(toParent: nil)
        self.removeFromParent()
        self.view.removeFromSuperview()
    }
    
    public func closeAndRemove() {
//        if ((self.webView) != nil) {
//            self.webView.removeFromSuperview()
//            self.webView.navigationDelegate = nil
//            self.webView.uiDelegate = nil
//            self.webView = nil
//        }
        self.willMove(toParent: nil)
        self.removeFromParent()
        self.view.removeFromSuperview()
    }
    
    func showWebView(connectUrl: String) {
        if let url = URL(string: connectUrl) {
            if (self.webView == nil) {
                let config = WKWebViewConfiguration()
                let userContentController = WKUserContentController()
                userContentController.add(self, name: "complete")
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
        print("observeValue.. " + (keyPath ?? "nil"))
        if keyPath == "estimatedProgress" && !self.isWebViewLoaded {
            print(Float(self.webView.estimatedProgress))
            if (self.webView.estimatedProgress == 1.0) {
                self.isWebViewLoaded = true
                self.loadedFunction()
            }
        }
        if keyPath == "title" {
            if let title = webView.title {
                print(title)
            }
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let host = navigationAction.request.url?.host {
            print(host)
            if (navigationController?.navigationBar.isHidden == false) {
                navigationItem.title = host;
            }
            
            if self.redirectUrl.contains(host) {
                print("redirectUrl match. calling closedFunction")
                decisionHandler(.cancel)
                self.closedFunction()
                return
            }
            
            if host.contains("localhost") && self.isChildWebViewLoaded {
                decisionHandler(.cancel)
                self.unloadChildWebView()
                return
            }
        }
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        print("---navigationType---",navigationAction.navigationType.rawValue)
        if navigationAction.targetFrame == nil {
            self.loadChildWebView(url: (navigationAction.request.url)!)
        }
        return nil
    }
    
    public func webViewDidClose(_ webView: WKWebView) {
        self.closedFunction()
    }
    func loadChildWebView(url: URL)  {
        self.isChildWebViewLoaded = true;
        navigationController?.setNavigationBarHidden(false, animated: true);
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
        
        if message.name == "complete" {
            self.closedFunction()
        }
        
    }
    
    @objc func closeSafariViewController(){
        if ((self.safariViewController) != nil){
            self.safariViewController?.dismiss(animated: true, completion:nil);
        }
    }
}
