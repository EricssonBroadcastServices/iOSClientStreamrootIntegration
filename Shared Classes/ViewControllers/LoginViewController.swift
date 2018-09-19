//
//  LoginViewController.swift
//  StreamrootIntegrationApp
//
//  Created by Fredrik Sjöberg on 2018-09-14.
//  Copyright © 2018 emp. All rights reserved.
//

import UIKit
import Exposure

class LoginViewController: UIViewController {

    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var businessUnitLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var loginButton: UIButton!
    
    var environment: Environment!
    
    var onDidAuthenticate: (SessionToken) -> Void = { _ in }
    @IBAction func loginAction(_ sender: Any) {
        guard let username = usernameTextField.text, username != "" else {
            showMessage(title: "Username missing", message: "Please enter a username")
            return
        }
        guard let password = passwordTextField.text, password != "" else {
            showMessage(title: "Password missing", message: "Please enter a password")
            return
        }
        Authenticate(environment: environment)
            .login(username: username, password: password)
            .request()
            .validate()
            .response{ [weak self] in
                if let error = $0.error {
                    self?.showMessage(title: "\(error.code): " + error.message, message: error.info ?? "")
                }
                
                if let sessionToken = $0.value?.sessionToken {
                    UserDefaults.standard.set(sessionToken.value, forKey: "exposureSessionToken")
                    self?.onDidAuthenticate(sessionToken)
                }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
