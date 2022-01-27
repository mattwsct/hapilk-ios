//
//  ChangePasswordViewController.swift
//  Kenko
//
//  Created by David Garcia Tort on 9/3/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var oldPasswordTextField: RoundedUITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func changePassword(_ sender: Any) {
        if validateInputs(inputs: [
            oldPasswordTextField: [.password],
            passwordTextField: [.password],
            passwordConfirmationTextField: [.passwordConfirmation(password: passwordTextField.text!)]
        ]) {
            Network.request(
                target: .updatePassword(
                    oldPassword: oldPasswordTextField.text!,
                    password: passwordTextField.text!
            ), success: { response in
                self.validationAlert(
                    title: "パスワード",
                    message: response.description, completion: {
                        self.navigationController?.popViewController(animated: true)
                })
            }, error: { error in
                self.validationAlert(title: "エラー", message: error.localizedDescription)
            }, failure: { error in
                self.validationAlert(title: "エラー", message: error.localizedDescription)
            })
        }
    }
    
}
