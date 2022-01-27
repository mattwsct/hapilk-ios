//
//  SMSViewController.swift
//  Kenko
//
//  Created by David Garcia Tort on 6/18/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit
import FirebaseAuth
import FlagPhoneNumber

class RegistrationViewController: UIViewController {

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
    
    private var verificationId: String = ""
    private var activityIndicator = UIActivityIndicatorView()
    private var countryCode = "81"
    private var phoneNumberIsValid = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Load verificationId if exists
        verificationId = UserDefaults.standard.string(forKey: "authVerificationID") ?? ""
        
        // Activity Indicator
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        self.view.addSubview(activityIndicator)
        
        // Navigation controller
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Navigation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Actions
    @IBAction func send(_ sender: Any) {
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
    
    @IBAction func resend(_ sender: Any) {
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
                self.performSegue(withIdentifier: "showUserRegistrationView", sender: nil)
            }
        }
    }
    
    @IBAction func goOnboarding(_ sender: Any) {
        if validateInputs(inputs: [
            passwordTextField: [.password],
            passwordConfirmationTextField: [.passwordConfirmation(password: passwordTextField.text!)]
        ]) {
            countryCode = UserDefaults.standard.string(forKey: "countryCode")!
            let phoneNumber = UserDefaults.standard.string(forKey: "phoneNumber")!
            Network.request(
                target: .register(countryCode: countryCode, phoneNumber: phoneNumber, password: passwordTextField.text!),
                success: { response in
                    UserDefaults.standard.set(response["jwtToken"].stringValue, forKey: "userToken")
                    UserDefaults.standard.set(true, forKey: "showOnboarding")
                    let onboarding = UIStoryboard(name: "Onboarding", bundle: nil).instantiateInitialViewController()
                    UIApplication.shared.keyWindow?.rootViewController = onboarding
            }, error: { error in
                self.validationAlert(title: "サーバーエラー", message: error.localizedDescription)
            }, failure: { error in
                self.validationAlert(title: "サーバーエラー", message: error.localizedDescription)
            })
        }
    }
    
    @IBAction func dismissButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension RegistrationViewController: FPNTextFieldDelegate {
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        countryCode = dialCode.replacingOccurrences(of: "+", with: "")
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        phoneNumberIsValid = isValid
    }
}
