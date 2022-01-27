//
//  ForgotPasswordViewController.swift
//  Kenko
//
//  Created by David Garcia Tort on 7/2/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit
import FlagPhoneNumber

class ForgotPasswordViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var phoneNumberTextField: FPNTextField! {
        didSet {
            phoneNumberTextField.delegate = self
            phoneNumberTextField.parentViewController = self
            phoneNumberTextField.setFlag(for: FPNCountryCode.JP)
            phoneNumberTextField.hasPhoneNumberExample = false
            phoneNumberTextField.placeholder = "電話番号を入力してください"
            
            // Design
            phoneNumberTextField.layer.borderColor = UIColor.lightGray.cgColor
            phoneNumberTextField.layer.borderWidth = 1
            phoneNumberTextField.layer.masksToBounds = true
            phoneNumberTextField.layer.cornerRadius = 25
            phoneNumberTextField.flagButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        }
    }
    @IBOutlet weak var verificationCodeTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    
    private var activityIndicator = UIActivityIndicatorView()
    private var countryCode = "81"
    private var phoneNumberIsValid = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Activity Indicator
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        self.view.addSubview(activityIndicator)
    }
    
    // MARK: - Actions
    @IBAction func sendVerificationCode(_ sender: Any) {
        if validateInputs(inputs: [
            phoneNumberTextField: [.phoneNumber]
        ]) {
            self.activityIndicator.startAnimating()
            if phoneNumberIsValid {
                let phoneNumber = phoneNumberTextField.getRawPhoneNumber()!
                Network.request(
                    target: .resetPasswordCode(countryCode: countryCode, phoneNumber: phoneNumber),
                    success: { response in
                        UserDefaults.standard.set(self.countryCode, forKey: "countryCode")
                        UserDefaults.standard.set(phoneNumber, forKey: "phoneNumber")
                        self.performSegue(withIdentifier: "showResetPasswordView", sender: nil)
                    }, error: { error in
                        self.validationAlert(title: "認証", message: error.localizedDescription)
                    }, failure: { error in
                        self.validationAlert(title: "認証", message: error.localizedDescription)
                    })
            } else {
                validationAlert(title: "認証エラー", message: "電話番号が間違っています")
            }
        }
    }
    
    @IBAction func resendVerificationCode(_ sender: Any) {
        let phoneNumber = UserDefaults.standard.string(forKey: "phoneNumber")!
        Network.request(
            target: .resetPasswordCode(countryCode: countryCode, phoneNumber: phoneNumber),
            success: { response in
                self.validationAlert(title: "検証コード", message: "確認コードが送信されました")
            }, error: { error in
                self.validationAlert(title: "認証", message: error.localizedDescription)
            }, failure: { error in
                self.validationAlert(title: "認証", message: error.localizedDescription)
            })
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        if validateInputs(inputs: [
            verificationCodeTextField: [.verificationCode],
            passwordTextField: [.password],
            passwordConfirmationTextField: [.passwordConfirmation(password: passwordTextField.text!)]
        ]) {
            countryCode = UserDefaults.standard.string(forKey: "countryCode")!
            let phoneNumber = UserDefaults.standard.string(forKey: "phoneNumber")!
            let otpNumber = verificationCodeTextField.text!
            let password = passwordTextField.text!
            Network.request(
                target: .resetPassword(countryCode: countryCode, phoneNumber: phoneNumber, otpNumber: otpNumber, password: password),
                success: { response in
                    self.validationAlert(title: "パスワードリセット", message: "パスワードの変更が完了しました", completion: {
                        self.performSegue(withIdentifier: "showLoginView", sender: nil)
                    })
                }, error: { error in
                    self.validationAlert(title: "認証", message: error.localizedDescription)
                }, failure: { error in
                    self.validationAlert(title: "認証", message: error.localizedDescription)
                })
        }
    }
    
    @IBAction func dismissButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension ForgotPasswordViewController: FPNTextFieldDelegate {
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        countryCode = dialCode.replacingOccurrences(of: "+", with: "")
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        phoneNumberIsValid = isValid
    }
}
