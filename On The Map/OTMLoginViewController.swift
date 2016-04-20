//
//  LoginViewController.swift
//  On The Map
//
//  Created by Avinash Mudivedu on 4/6/16.
//  Copyright © 2016 Avinash Mudivedu. All rights reserved.
//

import UIKit

// MARK: LoginViewController: UIViewController

class OTMLoginViewController: UIViewController {

    // MARK: ENUMs
    // UI State Enums
    private enum UIState {
        case initial
        case login
        case stop
    }
    
    // Mark: Properties
    var keyboardOnScreen = false
    
    // MARK: IBOutlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: BorderedButton!
    @IBOutlet weak var udacityLogo: UIImageView!
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginStackView: UIStackView!
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI(.initial)

        usernameTextField.text = "avinash@me.com"
        passwordTextField.text = "av1Flam3s"
        
        subscribeToNotification(UIKeyboardWillShowNotification, selector: UIConstants.Selectors.KeyboardWillShow)
        subscribeToNotification(UIKeyboardWillHideNotification, selector: UIConstants.Selectors.KeyboardWillHide)
        subscribeToNotification(UIKeyboardDidShowNotification, selector: UIConstants.Selectors.KeyboardDidShow)
        subscribeToNotification(UIKeyboardDidHideNotification, selector: UIConstants.Selectors.KeyboardDidHide)
        
    }
    
    //MARK: - Login Button Press
    
    @IBAction func loginPressed(sender: AnyObject) {

        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            displayError("Username or Password is empty.")
            return
        }
        
        startActivityIndicatorAndFade()
        OTMClient.sharedInstance().authenticateWithUdacity(usernameTextField.text, password: passwordTextField.text) { (success, errorString) in
            performUIUpdatesOnMain({ 
                if success {
                    self.completeLogin()
                } else {
                    self.displayError(errorString)
                }
            })
        }
    }
    
    // Load Navigation Controller
    private func completeLogin() {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("OTMNavigationController") as! UINavigationController
        presentViewController(controller, animated: true, completion: nil)
        configureUI(.stop)
    }
    
    // Alert View
    private func displayError(errorString: String?) {
        configureUI(.stop)
        let alertView = UIAlertController(title: "Login Error", message: errorString, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
        self.presentViewController(alertView, animated: true, completion: nil)
    }
}


// MARK: - LoginViewController: UITextFieldDelegate

extension OTMLoginViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
            udacityLogo.hidden = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification)
            udacityLogo.hidden = false
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(notification: NSNotification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    private func resignIfFirstResponder(textField: UITextField) {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(sender: AnyObject) {
        resignIfFirstResponder(usernameTextField)
        resignIfFirstResponder(passwordTextField)
    }
}

// MARK: - LoginViewController - UI Elements

extension OTMLoginViewController {
    
    private func setUIEnabled(enabled: Bool) {
        usernameTextField.enabled = enabled
        passwordTextField.enabled = enabled
        loginButton.enabled = enabled
        debugTextLabel.text = ""
        debugTextLabel.enabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
    
    // Initialize UI depending on the states this login controller goes through.
    private func configureUI(state: UIState) {
        
        switch state {
        case .initial:
            activityIndicator.hidden = true
            activityIndicator.stopAnimating()
            
            // configure background gradient
            let backgroundGradient = CAGradientLayer()
            backgroundGradient.colors = [UIColor.orangeColor(), UIColor.blackColor()]
            backgroundGradient.locations = [0.0, 10.0]
            backgroundGradient.frame = view.frame
            view.layer.insertSublayer(backgroundGradient, atIndex: 0)
            
            configureTextField(usernameTextField)
            configureTextField(passwordTextField)

        case .login:
            startActivityIndicatorAndFade()
            loginButton.enabled = false
            passwordTextField.text = nil
            
        case .stop:
            activityIndicator.hidden = true
            activityIndicator.stopAnimating()
            loginButton.enabled = true
            loginStackView.alpha = 1.0
        }
    }
    
    // Configure Text Fields
    private func configureTextField(textField: UITextField) {
        let textFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0)
        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
        textField.leftView = textFieldPaddingView
        textField.leftViewMode = .Always
        textField.backgroundColor = UIColor.whiteColor()
        textField.textColor = UIColor.blackColor()
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        textField.tintColor = UIColor.orangeColor()
        textField.delegate = self
    }
    
    // Start Activity Indicator
    func startActivityIndicatorAndFade() {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        loginButton.enabled = false
        loginStackView.alpha = 0.5
    }
}

// MARK: - LoginViewController - Keyboard Notifications

extension OTMLoginViewController {
    
    private func subscribeToNotification(notification: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    private func unsubscribeFromAllNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}