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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Query Connect.xcframework for SDK version.
        print("Connect.xcframework SDK version: \(sdkVersion())")
        
        self.navigationController?.navigationBar.isHidden = true
        setupViews()
        
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
            self.connectViewController.delegate = self
            self.connectViewController.load(connectUrl)
        } else {
            print("no connect url provided.")
            activityIndicator.stopAnimating()
        }
    }
    
}

extension ViewController: ConnectEventDelegate {
    func onCancel(_ data: NSDictionary?) {
        print("onCancel:")
        print(data?.debugDescription ?? "no data in callback")
        self.activityIndicator.stopAnimating()
        // Needed to trigger deallocation of ConnectViewController
        self.connectViewController = nil
        self.connectNavController = nil
    }
    
    func onDone(_ data: NSDictionary?) {
        print("onDone:")
        print(data?.debugDescription ?? "no data in callback")
        self.activityIndicator.stopAnimating()
        // Needed to trigger deallocation of ConnectViewController
        self.connectViewController = nil
        self.connectNavController = nil
    }
    
    func onError(_ data: NSDictionary?) {
        print("onError:")
        print(data?.debugDescription ?? "no data in callback")
        self.activityIndicator.stopAnimating()
        // Needed to trigger deallocation of ConnectViewController
        self.connectViewController = nil
        self.connectNavController = nil
    }
    
    func onLoad() {
        print("onLoad:")
        self.connectNavController = UINavigationController(rootViewController: self.connectViewController)
        self.connectNavController.modalPresentationStyle = .automatic
        self.connectNavController.isModalInPresentation = true
        self.connectNavController.presentationController?.delegate = self
        self.present(self.connectNavController, animated: true)
    }
    
    func onRoute(_ data: NSDictionary?) {
        print("onRoute:")
        print(data?.debugDescription ?? "no data in callback")
    }
    
    func onUser(_ data: NSDictionary?) {
        print("onUser:")
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
