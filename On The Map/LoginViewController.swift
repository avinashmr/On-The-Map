//
//  ViewController.swift
//  On The Map
//
//  Created by Avinash Mudivedu on 4/6/16.
//  Copyright © 2016 Avinash Mudivedu. All rights reserved.
//

import UIKit

// MARK: LoginViewController: UIViewController

class LoginViewController: UIViewController {

    // Mark: Properties
    var keyboardOnScreen = false
    
    // MARK: Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: BorderedButton!
    @IBOutlet weak var udacityLogo: UIImageView!
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginStackView: UIStackView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        subscribeToNotification(UIKeyboardWillShowNotification, selector: UIConstants.Selectors.KeyboardWillShow)
        subscribeToNotification(UIKeyboardWillHideNotification, selector: UIConstants.Selectors.KeyboardWillHide)
        subscribeToNotification(UIKeyboardDidShowNotification, selector: UIConstants.Selectors.KeyboardDidShow)
        subscribeToNotification(UIKeyboardDidHideNotification, selector: UIConstants.Selectors.KeyboardDidHide)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Login Button Press
    
    @IBAction func loginPressed(sender: AnyObject) {
        
        userDidTapView(self)
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            
            // TODO: Change to Alert View
            debugTextLabel.text = "Username or Password Empty."
        } else {
            setUIEnabled(false)

        }
        loginToUdacity()
        
    }
    
    func loginToUdacity() {
        if Reachability.isConnectedToNetwork() == true {
            print("Internet connection OK")
            startActivityIndicatorAndFade()
            UClient.sharedInstance().createASession(usernameTextField.text!, password: passwordTextField.text!, completionHandlerForSession: { (success, userID, errorString) in
                if success {
                    self.completeLogin()
                } else {
                    self.displayError(errorString)
                }
            })
            
        } else {
            print("Internet connection FAILED")
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .Alert)
            

            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    private func completeLogin() {
        performUIUpdatesOnMain {
            self.debugTextLabel.text = ""
            self.setUIEnabled(true)
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    private func displayError(errorString: String?) {
        if let errorString = errorString {
            debugTextLabel.text = errorString
        }
    }

}

// MARK: - LoginViewController: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
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

// MARK: - LoginViewController (Configure UI)

extension LoginViewController {
    
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
    
    private func configureUI() {
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
        
        // configure background gradient
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [UIConstants.UI.LoginColorTop, UIConstants.UI.LoginColorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, atIndex: 0)
        
        configureTextField(usernameTextField)
        configureTextField(passwordTextField)
        
    }
    
    private func configureTextField(textField: UITextField) {
        let textFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0)
        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
        textField.leftView = textFieldPaddingView
        textField.leftViewMode = .Always
        textField.backgroundColor = UIConstants.UI.GreyColor
        textField.textColor = UIConstants.UI.BlueColor
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        textField.tintColor = UIConstants.UI.BlueColor
        textField.delegate = self
    }
    
    func startActivityIndicatorAndFade() {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        loginButton.enabled = false
        loginStackView.alpha = 0.5
    }
}

// MARK: - LoginViewController (Notifications)

extension LoginViewController {
    
    private func subscribeToNotification(notification: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    private func unsubscribeFromAllNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}