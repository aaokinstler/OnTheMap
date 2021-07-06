//
//  DocumentViewController.swift
//  OnTheMap
//
//  Created by Anton Kinstler on 26.06.2021.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var liginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UdacityClient.isAuthorised {
            let currentUser = Settings.currentUser ?? ""
            startLogin(email: currentUser, password: UdacityClient.getPassword(currentUser: currentUser) ?? "")
        }
        
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        guard let emailString = emailTextField.text  else {
            showLoginFailure(message: "Please enter email.")
            return
        }
        guard emailString != "" else {
            showLoginFailure(message: "Please enter email.")
            return
        }
        
        guard let passwordString = passwordTextField.text else {
            showLoginFailure(message: "Please enter password")
            return
        }
        
        guard passwordString != "" else {
            showLoginFailure(message: "Please enter password")
            return
        }
        
        startLogin(email: emailString, password: passwordString)
    }
    
    func startLogin(email: String, password: String) {
        setLoggingIn(true)
        UdacityClient.login(username: email, password: password, completion: handleLogin(success:error:))
    }
    
    func handleLogin(success: Bool, error: String?) {
        setLoggingIn(false)
        if success {
            performSegue(withIdentifier: "completeLogin", sender: nil)
        } else {
            showLoginFailure(message: error ?? "")
        }
    }
    
    func setLoggingIn(_ loggingIn: Bool) {
        if loggingIn {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
        emailTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        liginButton.isEnabled = !loggingIn
        signUpButton.isEnabled = !loggingIn
    }
    
    func showLoginFailure(message: String) {
        let alertVC = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    @IBAction func signUpButtonTapped(_ sender: Any) {
        let app = UIApplication.shared
        app.open(URL(string: "https://auth.udacity.com/sign-up")!)
        
    }
}
