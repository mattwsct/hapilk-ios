//
//  ChangePhoneNumberViewController.swift
//  Kenko
//
//  Created by David Garcia Tort on 9/3/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit
import FirebaseAuth
import FlagPhoneNumber

class ChangePhoneNumberViewController: UIViewController {

    @IBOutlet weak var phoneNumberWrapperView: UIView! {
        didSet {
            phoneNumberWrapperView.layer.borderWidth = 0.5
            phoneNumberWrapperView.layer.borderColor = UIColor.lightGray.cgColor
            phoneNumberWrapperView.layer.cornerRadius = 10
            phoneNumberWrapperView.layer.shadowColor = UIColor.lightGray.cgColor
            phoneNumberWrapperView.layer.shadowRadius = 10
            phoneNumberWrapperView.layer.shadowOpacity = 0.7
            phoneNumberWrapperView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        }
    }
    
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
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    private var verificationId: String = ""
    private var activityIndicator = UIActivityIndicatorView()
    private var countryCode = "81"
    private var phoneNumberIsValid = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load verificationId if exists
        verificationId = UserDefaults.standard.string(forKey: "authVerificationID") ?? ""
        
        // Activity Indicator
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        self.view.addSubview(activityIndicator)
        
        if let phoneNumber = UserDefaults.standard.string(forKey: "phoneNumber") {
            if let countryCode = UserDefaults.standard.string(forKey: "countryCode") {
                phoneNumberLabel.text = "+\(countryCode)\(phoneNumber)"
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func verifyPhoneNumber(_ sender: Any) {
        if validateInputs(inputs: [
            phoneNumberTextField: [.phoneNumber]
        ]) {
            Auth.auth().languageCode = "ja"
            self.activityIndicator.startAnimating()
            if phoneNumberIsValid {
                let verificationPhoneNumber = phoneNumberTextField.getFormattedPhoneNumber(format: .E164)!
                let phoneNumber = phoneNumberTextField.getRawPhoneNumber()!
                PhoneAuthProvider.provider().verifyPhoneNumber(verificationPhoneNumber, uiDelegate: nil) { (verificationId, error) in
                    self.activityIndicator.stopAnimating()
                    if let error = error {
                        self.validationAlert(title: "認証", message: error.localizedDescription)
                        return
                    }
                    UserDefaults.standard.set(self.countryCode, forKey: "countryCode")
                    UserDefaults.standard.set(verificationPhoneNumber, forKey: "verificationPhoneNumber")
                    UserDefaults.standard.set(phoneNumber, forKey: "phoneNumber")
                    UserDefaults.standard.set(verificationId, forKey: "authVerificationID")
                    self.performSegue(withIdentifier: "showVerifyCodeView", sender: nil)
                }
            } else {
                validationAlert(title: "認証エラー", message: "電話番号が間違っています")
            }
        }
    }
    
    @IBAction func resendVerificationCode(_ sender: Any) {
        Auth.auth().languageCode = "ja"
        let verificationPhoneNumber = UserDefaults.standard.string(forKey: "verificationPhoneNumber")!
        PhoneAuthProvider.provider().verifyPhoneNumber(verificationPhoneNumber, uiDelegate: nil) { (verificationId, error) in
            if let error = error {
                self.validationAlert(title: "認証", message: error.localizedDescription)
                return
            }
            self.validationAlert(title: "検証コード", message: "確認コードが送信されました")
        }
    }
    
    @IBAction func verify(_ sender: Any) {
        if validateInputs(inputs: [
            verificationCodeTextField: [.verificationCode]
        ]) {
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: verificationCodeTextField.text!)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    self.validationAlert(title: "認証", message: error.localizedDescription)
                    return
                }
                self.countryCode = UserDefaults.standard.string(forKey: "countryCode")!
                let phoneNumber = UserDefaults.standard.string(forKey: "phoneNumber")!
                Network.request(
                    target: .updatePhoneNumber(countryCode: self.countryCode, phoneNumber: phoneNumber),
                    success: { response in
                        UserDefaults.standard.set(response["jwtToken"].stringValue, forKey: "userToken")
                        self.validationAlert(
                            title: "電話番号",
                            message: "変更が完了しました", completion: {
                               self.performSegue(withIdentifier: "showSettingsView", sender: nil)
                        })
                    }, error: { error in
                        self.validationAlert(title: "エラー", message: error.localizedDescription)
                    }, failure: { error in
                        self.validationAlert(title: "エラー", message: error.localizedDescription)
                    })
            }
        }
    }

}

extension ChangePhoneNumberViewController: FPNTextFieldDelegate {
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        countryCode = dialCode.replacingOccurrences(of: "+", with: "")
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        phoneNumberIsValid = isValid
    }
}
