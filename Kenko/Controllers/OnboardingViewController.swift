//
//  QuestionsViewController.swift
//  Kenko
//
//  Created by David Garcia Tort on 6/20/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var branchTextField: UITextField!
    @IBOutlet weak var departmentTextField: UITextField!
    @IBOutlet weak var employeeNumberTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var prefectureTextField: UITextField!
    
    private var userProfile: UserProfile?
    
    enum ActiveTextFieldType {
        case company
        case branch
        case department
        case prefecture
    }
    
    private var activeTextField: ActiveTextFieldType?
    
    private var datePicker: UIDatePicker?
    private var senkoPicker: UIPickerView?
    private var companies: [Company] = [] {
        willSet {
            companyTextField?.isEnabled = newValue.count > 0
        }
    }
    private var branches: [Branch] = [] {
        willSet {
            branchTextField?.isEnabled = newValue.count > 0
        }
    }
    private var departments: [Department] = [] {
        willSet {
            departmentTextField?.isEnabled = newValue.count > 0
        }
    }
    private var prefectures: [Prefecture] = [] {
        willSet {
            prefectureTextField?.isEnabled = newValue.count > 0
        }
    }
    
    // MARK: - Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // DatePicker
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.locale = Locale(identifier: "ja_JP")
        datePicker?.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        birthdayTextField?.inputView = datePicker
        
        loadPickersData()
        setupDatePicker()
        
        // User Profile
        loadUserProfile()
    }
    
    private func saveUserProfile() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: "userProfile")
        }
    }
    
    private func loadUserProfile() {
        if let encoded = UserDefaults.standard.object(forKey: "userProfile") as? Data {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(UserProfile.self, from: encoded) {
                userProfile = decoded
            }
        } else {
            userProfile = UserProfile()
        }
    }
    
    private func setupDatePicker() {
        // TextFields Delegates
        companyTextField?.delegate = self
        branchTextField?.delegate = self
        departmentTextField?.delegate = self
        prefectureTextField?.delegate = self
        
        // SenkoPicker
        senkoPicker = UIPickerView()
        senkoPicker?.delegate = self
        senkoPicker?.dataSource = self
        companyTextField?.inputView = senkoPicker
        branchTextField?.inputView = senkoPicker
        departmentTextField?.inputView = senkoPicker
        prefectureTextField?.inputView = senkoPicker
    }
    
    private func loadPickersData() {
        if companyTextField != nil {
            Network.getCompanies(success: { companies in
                self.companies = companies
            }, error: { error in }, failure: { error in })
        }
        if prefectureTextField != nil {
            Network.getPrefectures(success: { prefectures in
                self.prefectures = prefectures
            }, error: { error in }, failure: { error in })
        }
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        birthdayTextField.text = dateFormatter.string(from: datePicker.date)
        userProfile?.birthday = datePicker.date.encodedUTCDateString
    }
    
    @IBAction func skipStepOne(_ sender: Any) {
        performSegue(withIdentifier: "showStepTwoView", sender: nil)
    }
    
    @IBAction func saveStepOne(_ sender: Any) {
        if validateInputs(inputs: [
            heightTextField: [.height],
            weightTextField: [.weight],
            birthdayTextField: [.birthday],
        ]) {
            userProfile?.height = Double(heightTextField.text!)!
            userProfile?.weight = Double(weightTextField.text!)!
            saveUserProfile()
            performSegue(withIdentifier: "showStepTwoView", sender: nil)
        }
    }
    
    @IBAction func saveStepTwo(_ sender: Any) {
        if validateInputs(inputs: [
            companyTextField: [.company],
            employeeNumberTextField: [.employeeNumber],
        ]) {
            userProfile?.employeeNumber = employeeNumberTextField.text!
            saveUserProfile()
            performSegue(withIdentifier: "showStepThreeView", sender: nil)
        }
    }
    
    @IBAction func saveUserProfile(_ sender: Any) {
        if validateInputs(inputs: [
            nameTextField: [.name],
            displayNameTextField: [.displayName],
            prefectureTextField: [.prefecture],
        ]) {
            userProfile?.name = nameTextField.text!
            userProfile?.displayName = displayNameTextField.text!
            Network.request(
                target: .updateUserProfile(
                    height: userProfile?.height,
                    weight: userProfile?.weight,
                    birthday: userProfile?.birthday,
                    employeeNumber: userProfile?.employeeNumber,
                    companyId: userProfile?.companyId,
                    company: userProfile?.company,
                    branchId: userProfile?.branchId,
                    branch: userProfile?.branch,
                    departmentId: userProfile?.departmentId,
                    department: userProfile?.department,
                    name: userProfile?.name,
                    displayName: userProfile?.displayName,
                    prefectureId: userProfile?.prefectureId,
                    prefectureCode: userProfile?.prefectureCode,
                    prefecture: userProfile?.prefecture
                ),
                success: { response in
                    self.view.endEditing(true)
                    UserDefaults.standard.removeObject(forKey: "userProfile")
                    UserDefaults.standard.removeObject(forKey: "showOnboarding")
                    self.performSegue(withIdentifier: "showStartView", sender: nil)
            },
                error: { error in
                    self.validationAlert(title: "プロフィール", message: error.localizedDescription)
            },
                failure: { error in
                    self.validationAlert(title: "プロフィール", message: error.localizedDescription)
            })
        }
    }
    
    @IBAction func startDashboard(_ sender: Any) {
        let navigation = UIStoryboard(name: "Navigation", bundle: nil).instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = navigation
    }
    
    @IBAction func dismissButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension OnboardingViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case companyTextField:
            activeTextField = .company
            if let textFieldText = textField.text, let rowId = companies.firstIndex(where: { $0.name == textFieldText }) {
                senkoPicker?.reloadAllComponents()
                senkoPicker?.selectRow(rowId, inComponent: 0, animated: true)
            }
        case branchTextField:
            activeTextField = .branch
            if let textFieldText = textField.text, let rowId = branches.firstIndex(where: { $0.name == textFieldText }) {
                senkoPicker?.reloadAllComponents()
                senkoPicker?.selectRow(rowId, inComponent: 0, animated: true)
            }
        case departmentTextField:
            activeTextField = .department
            if let textFieldText = textField.text, let rowId = departments.firstIndex(where: { $0.name == textFieldText }) {
                senkoPicker?.reloadAllComponents()
                senkoPicker?.selectRow(rowId, inComponent: 0, animated: true)
            }
        case prefectureTextField:
            activeTextField = .prefecture
            if let textFieldText = textField.text, let rowId = prefectures.firstIndex(where: { $0.name == textFieldText }) {
                senkoPicker?.reloadAllComponents()
                senkoPicker?.selectRow(rowId, inComponent: 0, animated: true)
            }
        default: break
        }
    }
}

extension OnboardingViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let textField = activeTextField {
            switch textField {
            case .company: return companies.count
            case .branch: return branches.count
            case .department: return departments.count
            case .prefecture: return prefectures.count
            }
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let textField = activeTextField {
            switch textField {
            case .company: return companies[row].name
            case .branch: return branches[row].name
            case .department: return departments[row].name
            case .prefecture: return prefectures[row].name
            }
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let textField = activeTextField {
            switch textField {
            case .company:
                if companies.count > 0 {
                    self.userProfile?.companyId = companies[row].id
                    self.userProfile?.company = companies[row].name
                    companyTextField!.text = companies[row].name
                    Network.getBranches(companyId: companies[row].id, success: { branches in
                        self.branches = branches
                        if branches.count > 0 {
                            self.userProfile?.branchId = branches[0].id
                            self.userProfile?.branch = branches[0].name
                            self.branchTextField!.text = branches[0].name
                            Network.getDepartments(branchId: branches[0].id, success: { departments in
                                self.departments = departments
                                if departments.count > 0 {
                                    self.userProfile?.departmentId = departments[0].id
                                    self.userProfile?.department = departments[0].name
                                    self.departmentTextField!.text = departments[0].name
                                } else {
                                    self.userProfile?.departmentId = 0
                                    self.userProfile?.department = nil
                                    self.departmentTextField!.text = ""
                                }
                            }, error: { error in }, failure: { error in })
                        } else {
                            self.userProfile?.branchId = 0
                            self.userProfile?.branch = nil
                            self.branchTextField!.text = ""
                            self.departments = []
                            self.userProfile?.departmentId = 0
                            self.userProfile?.department = nil
                            self.departmentTextField!.text = ""
                        }
                    }, error: { error in }, failure: { error in })
                }
            case .branch:
                if branches.count > 0 {
                    self.userProfile?.branchId = branches[row].id
                    self.userProfile?.branch = branches[row].name
                    branchTextField!.text = branches[row].name
                    Network.getDepartments(branchId: branches[row].id, success: { departments in
                        self.departments = departments
                        if departments.count > 0 {
                            self.userProfile?.departmentId = departments[0].id
                            self.userProfile?.department = departments[0].name
                            self.departmentTextField!.text = departments[0].name
                        } else {
                            self.userProfile?.departmentId = 0
                            self.userProfile?.department = nil
                            self.departmentTextField!.text = ""
                        }
                    }, error: { error in }, failure: { error in })
                }
            case .department:
                if departments.count > 0 {
                    self.userProfile?.departmentId = departments[row].id
                    self.userProfile?.department = departments[row].name
                    departmentTextField!.text = departments[row].name
                }
            case .prefecture: prefectureTextField!.text = prefectures[row].name
                if prefectures.count > 0 {
                    self.userProfile?.prefectureId = prefectures[row].id
                    self.userProfile?.prefectureCode = prefectures[row].code
                    self.userProfile?.prefecture = prefectures[row].name
                    prefectureTextField!.text = prefectures[row].name
                }
            }
        }
    }
}
