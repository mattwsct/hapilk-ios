//
//  LoginViewController.swift
//  Kenko
//
//  Created by David Garcia Tort on 6/18/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit
import SwiftyJSON
import FlagPhoneNumber

class LoginViewController: UIViewController {

    @IBOutlet weak var phoneNumberTextField: FPNTextField! {
        didSet {
            phoneNumberTextField.delegate = self
            phoneNumberTextField.parentViewController = self
            phoneNumberTextField.setFlag(for: FPNCountryCode.JP)
            phoneNumberTextField.hasPhoneNumberExample = false
            phoneNumberTextField.placeholder = "電話番号"
            
            // Design
            phoneNumberTextField.textColor = UIColor.white
            phoneNumberTextField.layer.masksToBounds = true
            phoneNumberTextField.layer.cornerRadius = 25
            phoneNumberTextField.flagButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        }
    }
    @IBOutlet weak var passwordTextField: UITextField!
    
    private var countryCode = "81"
    private var phoneNumberIsValid = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func login(_ sender: Any) {
        if validateInputs(inputs: [
            phoneNumberTextField: [.user],
            passwordTextField: [.password],
        ]) {
            if phoneNumberIsValid {
                let phoneNumber = phoneNumberTextField.getRawPhoneNumber()!
                Network.request(
                    target: .login(countryCode: countryCode, phoneNumber: phoneNumber, password: passwordTextField.text!),
                    success: { response in
                        UserDefaults.standard.set(self.countryCode, forKey: "countryCode")
                        UserDefaults.standard.set(phoneNumber, forKey: "phoneNumber")
                        UserDefaults.standard.set(response["jwtToken"].stringValue, forKey: "userToken")
                        let navigation = UIStoryboard(name: "Navigation", bundle: nil).instantiateInitialViewController()
                        UIApplication.shared.keyWindow?.rootViewController = navigation
                }, error: { error in
                    self.validationAlert(title: "ログイン", message: error.localizedDescription)
                }, failure: { error in
                    self.validationAlert(title: "ログイン", message: error.localizedDescription)
                })
            } else {
                validationAlert(title: "認証エラー", message: "電話番号が間違っています")
            }
        }
    }
    
    @IBAction func unwindToLogin(_ unwindSegue: UIStoryboardSegue) {
        //let sourceViewController = unwindSegue.source
    }
    
}

extension LoginViewController: FPNTextFieldDelegate {
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        countryCode = dialCode.replacingOccurrences(of: "+", with: "")
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        phoneNumberIsValid = isValid
    }
}
