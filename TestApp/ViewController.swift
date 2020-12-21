//
//  ViewController.swift
//  TestApp
//
//  Created by Jimmie Wright on 12/11/20.
//  Copyright © 2020 finicity. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var urlInput: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var connectButton: UIButton!
    
    var connectViewController: ConnectViewController!
    var connectNavController: UINavigationController!
    let gradientLayer = CAGradientLayer()
    var useLegacyLoadFn = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Query Connect.xcframework for SDK version.
        print("Connect.xcframework SDK version: \(sdkVersion())")
        
        self.navigationController?.navigationBar.isHidden = true
        setupViews()
        
        if CommandLine.arguments.contains("-useLegacyLoadFn") {
            useLegacyLoadFn = true
        }
        
        // Add tap gesture recognizer to dismiss keyboard when tapped outside of textfield.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(screenTapped))
        view.addGestureRecognizer(tapGesture)
        
        urlInput.accessibilityIdentifier = AccessiblityIdentifer.UrlTextField.rawValue
        connectButton.accessibilityIdentifier = AccessiblityIdentifer.ConnectButton.rawValue
        
        urlInput.becomeFirstResponder()
    }
    
    // For iPad rotation need to adjust gradient frame size
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.frame
    }
    
    // If screen tapped then end editing in textField
    @objc func screenTapped(gesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // On startup initialize sub-views that cannot be initialized in storyboard.
    private func setupViews() {
        setGradientBackgroundLayer()
        
        activityIndicator.style = .large
        activityIndicator.color = .white
        
        infoView.layer.cornerRadius = 8
        connectButton.layer.cornerRadius = 24
        connectButton.isEnabled = false
        connectButton.setTitleColor(UIColor(red: 254.0/255.0, green: 254.0/255.0, blue: 254.0/255.0, alpha: 0.32), for: .disabled)
        connectButton.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
    }
    
    // Added gradient background layer to view hierarchy
    private func setGradientBackgroundLayer() {
        
        gradientLayer.colors = [
            UIColor(red: 0.518, green: 0.714, blue: 0.427, alpha: 1).cgColor,
            UIColor(red: 0.004, green: 0.537, blue: 0.616, alpha: 1).cgColor,
            UIColor(red: 0.008, green: 0.22,  blue: 0.447, alpha: 1).cgColor
        ]
        gradientLayer.locations = [0, 0.4, 1]
        
        // Diagonal Gradient
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.frame
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @IBAction func connectButtonClicked(_ sender: Any) {
        view.endEditing(true)
        activityIndicator.startAnimating()
        openWebKitConnectView()
    }
    
    func openWebKitConnectView() {
        if let connectUrl = urlInput.text {
            print("creating & loading connectViewController")
            self.connectViewController = ConnectViewController()
            if !useLegacyLoadFn {
                let config = ConnectViewConfig(connectUrl: connectUrl, loaded: self.connectViewLoaded, done: self.connectViewDone, cancel: self.connectViewCancelled, error: self.connectViewError, route: self.connectViewRoute, userEvent: self.connectViewUserEvent)
                self.connectViewController.load(config: config)
            } else {
                self.connectViewController.load(connectUrl: connectUrl, onLoaded: self.connectViewLoaded, onDone: self.connectViewDone(_:), onCancel: self.connectViewCancelled, onError: self.connectViewError(_:))
            }

        } else {
            print("no connect url provided.")
            activityIndicator.stopAnimating()
        }
    }
    
    func connectViewLoaded() {
        print("connectViewController loaded")
        self.connectNavController = UINavigationController(rootViewController: self.connectViewController)
        self.connectNavController.modalPresentationStyle = .automatic
        self.connectNavController.isModalInPresentation = true
        self.connectNavController.presentationController?.delegate = self
        self.present(self.connectNavController, animated: true)
    }
    
    func connectViewDone(_ data: NSDictionary?) {
        print("connectViewController done")
        print(data?.debugDescription ?? "no data in callback")
        self.activityIndicator.stopAnimating()
    }
    
    func connectViewCancelled() {
        print("connectViewController cancel")
        self.activityIndicator.stopAnimating()
    }
    
    func connectViewError(_ data: NSDictionary?) {
        print("connectViewController error")
        print(data?.debugDescription ?? "no data in callback")
        self.activityIndicator.stopAnimating()
    }
    
    func connectViewRoute(_ data: NSDictionary?) {
        print("connectViewController route")
        print(data?.debugDescription ?? "no data in callback")
    }
    
    func connectViewUserEvent(_ data: NSDictionary?) {
        print("connectViewController user")
        print(data?.debugDescription ?? "no data in callback")
    }
    
}

extension ViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("connectViewController dismissed by gesture")
        self.activityIndicator.stopAnimating()
    }
}

// If textfield is not empty enable connect button, otherwise disable connect button
extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let newLength = text.count + string.count - range.length
        let isEnabled = newLength > 0
        connectButton.isEnabled = isEnabled
        // Adjust opacity based on button enabled state
        if isEnabled {
            connectButton.backgroundColor = UIColor(red: 254.0 / 255.0, green: 254.0 / 255.0, blue: 254.0 / 255.0, alpha: 0.24)
        } else {
            connectButton.backgroundColor = UIColor(red: 254.0 / 255.0, green: 254.0 / 255.0, blue: 254.0 / 255.0, alpha: 0.16)
        }
        return true
    }
}
