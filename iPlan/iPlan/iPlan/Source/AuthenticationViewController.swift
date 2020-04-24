//
//  AuthenticationViewController.swift
//  iPlan
//
//  Created by Petra Čačkov on 07/04/2020.
//  Copyright © 2020 Petra Čačkov. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthenticationViewController: UIViewController {
    @IBOutlet private var buttonView: UIView?
    @IBOutlet private var button: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buttonView?.layer.cornerRadius = 10
        buttonView?.layer.shadowColor = UIColor.systemGray.cgColor
        buttonView?.layer.shadowOpacity = 0.7
        buttonView?.layer.shadowOffset = .zero
        buttonView?.layer.shadowRadius = 2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        goToViewController()
        //setupFaceID()
        //goToViewController()
    }
    
    @IBAction func useFaceID(_ sender: Any) {
        setupFaceID()
    }
    private func setupFaceID() {
        let myContext = LAContext()
        let myLocalizedReasonString = "Biometric Authntication testing !! "
        
        var authError: NSError?
        if #available(iOS 8.0, macOS 10.12.1, *) {
            if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, error in
                    DispatchQueue.main.async {
                        if success {
                            self.goToViewController()
                        } else {
                            self.alert(title: "Error!", description: "User did not authenticate successfully")
                        }
                    }
                }
            } else {
                alert(title: "Face ID is disabled", description: "Go to settings and enable Face ID to use the app")
            }
        } else {
            alert(title: "Ooops!!..", description: "This feature is not supported.")
        }
        
    }
    
    private func alert(title: String, description: String) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
        self.present(alert, animated:  true)
    }
    
    private func goToViewController() {
        let controller = storyboard?.instantiateViewController(identifier: "ViewController") as! ViewController
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.modalTransitionStyle = .flipHorizontal
        self.present(navigationController, animated: true)
    }
}
