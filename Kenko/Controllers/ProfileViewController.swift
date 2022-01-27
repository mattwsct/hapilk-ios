//
//  ProfileViewController.swift
//  Kenko
//
//  Created by David Garcia Tort on 8/1/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit
import Kingfisher

class ProfileViewController: UITableViewController {
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var profilePictureView: ProfilePictureUIView!
    @IBOutlet var editProfilePictureTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var prefectureTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var employeeNumberTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var branchTextField: UITextField!
    @IBOutlet weak var departmentTextField: UITextField!
    
    private var editingProfile = false
    
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
            if editingProfile == true {
                companyTextField?.isEnabled = newValue.count > 0
            }
        }
    }
    private var branches: [Branch] = [] {
        willSet {
            if editingProfile == true {
                branchTextField?.isEnabled = newValue.count > 0
            }
        }
    }
    private var departments: [Department] = [] {
        willSet {
            if editingProfile == true {
                departmentTextField?.isEnabled = newValue.count > 0
            }
        }
    }
    private var prefectures: [Prefecture] = [] {
        willSet {
            if editingProfile == true {
                prefectureTextField?.isEnabled = newValue.count > 0
            }
        }
    }
    
    private var userProfile: UserProfile? {
        didSet {
            displayProfileInformation()
        }
    }
    private var editedUserProfile: UserProfile?
    
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
        Network.getCompanies(success: { companies in
            self.companies = companies
        }, error: { error in }, failure: { error in })
        
        if let userProfile = userProfile {
            if userProfile.companyId != nil {
                if let companyId = userProfile.companyId {
                    Network.getBranches(companyId: companyId, success: { branches in
                        self.branches = branches
                    }, error: { error in }, failure: { error in })
                }
            }
            if userProfile.branchId != nil {
                if let branchId = userProfile.branchId {
                    Network.getDepartments(branchId: branchId, success: { departments in
                        self.departments = departments
                    }, error: { error in }, failure: { error in })
                }
            }
        }
        
        Network.getPrefectures(success: { prefectures in
            self.prefectures = prefectures
        }, error: { error in }, failure: { error in })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Add edit button
        navigationItem.rightBarButtonItem = editButton
        
        // DatePicker
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.locale = Locale(identifier: "ja_JP")
        datePicker?.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        birthdayTextField?.inputView = datePicker
        
        profileNotEditable()
        
        // Pickers
        setupDatePicker()
        
        Network.getUserProfile(success: { userProfile in
            self.userProfile = userProfile
        }, error: { error in }, failure: { error in })
        
        Network.getUserProfilePicture(success: { userProfilePicture in
            DispatchQueue.main.async {
                self.profilePictureView.image = UIImage(data: userProfilePicture)
            }
        }, error: { error in }, failure: { error in })
        
        setupProfilePicture()
    }
    
    @IBAction func editProfile(_ sender: Any) {
        profileEditable()
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
        editedUserProfile = userProfile
        editingProfile = true
    }
    
    @IBAction func saveProfile(_ sender: Any) {
        if validateInputs(inputs: [
            nameTextField: [.name],
            displayNameTextField: [.displayName],
            prefectureTextField: [.prefecture],
            heightTextField: [.height],
            weightTextField: [.weight],
            birthdayTextField: [.birthday],
            employeeNumberTextField: [.employeeNumber],
            companyTextField: [.company],
        ]) {
            editedUserProfile?.name = nameTextField.text!
            editedUserProfile?.displayName = displayNameTextField.text!
            editedUserProfile?.height = Double(heightTextField.text!)!
            editedUserProfile?.weight = Double(weightTextField.text!)!
            editedUserProfile?.employeeNumber = employeeNumberTextField.text!
            
            Network.request(
                target: .updateUserProfile(
                    height: editedUserProfile?.height,
                    weight: editedUserProfile?.weight,
                    birthday: editedUserProfile?.birthday,
                    employeeNumber: editedUserProfile?.employeeNumber,
                    companyId: editedUserProfile?.companyId,
                    company: editedUserProfile?.company,
                    branchId: editedUserProfile?.branchId,
                    branch: editedUserProfile?.branch,
                    departmentId: editedUserProfile?.departmentId,
                    department: editedUserProfile?.department,
                    name: editedUserProfile?.name,
                    displayName: editedUserProfile?.displayName,
                    prefectureId: editedUserProfile?.prefectureId,
                    prefectureCode: editedUserProfile?.prefectureCode,
                    prefecture: editedUserProfile?.prefecture
                ), success: { response in
                    self.userProfile = self.editedUserProfile
                    self.profileNotEditable()
                    self.navigationItem.leftBarButtonItem = nil
                    self.navigationItem.rightBarButtonItem = self.editButton
                    self.editingProfile = false
            }, error: { error in
                self.validationAlert(title: "プロフィール", message: error.localizedDescription)
            }, failure: { error in
                self.validationAlert(title: "プロフィール", message: error.localizedDescription)
            })
        }
    }
    
    @IBAction func cancelEditProfile(_ sender: Any) {
        profileNotEditable()
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = editButton
        editingProfile = false
        displayProfileInformation()
    }
    
    private func displayProfileInformation() {
        nameTextField.text = userProfile?.name
        displayNameTextField.text = userProfile?.displayName
        prefectureTextField.text = userProfile?.prefecture
        heightTextField.text = (userProfile?.height ?? 0).formattedWithSeparator
        weightTextField.text = (userProfile?.weight ?? 0).formattedWithSeparator
        birthdayTextField.text = userProfile?.birthday
        employeeNumberTextField.text = userProfile?.employeeNumber
        companyTextField.text = userProfile?.company
        branchTextField.text = userProfile?.branch
        departmentTextField.text = userProfile?.department
    }
    
    private func profileNotEditable() {
        editProfilePictureTapGestureRecognizer.isEnabled = false
        nameTextField.isEnabled = false
        displayNameTextField.isEnabled = false
        prefectureTextField.isEnabled = false
        heightTextField.isEnabled = false
        weightTextField.isEnabled = false
        birthdayTextField.isEnabled = false
        employeeNumberTextField.isEnabled = false
        companyTextField.isEnabled = false
        branchTextField.isEnabled = false
        departmentTextField.isEnabled = false
    }
    
    private func profileEditable() {
        loadPickersData()
        editProfilePictureTapGestureRecognizer.isEnabled = true
        nameTextField.isEnabled = true
        displayNameTextField.isEnabled = true
        prefectureTextField.isEnabled = true
        heightTextField.isEnabled = true
        weightTextField.isEnabled = true
        birthdayTextField.isEnabled = true
        employeeNumberTextField.isEnabled = true
        companyTextField.isEnabled = true
        branchTextField.isEnabled = true
        departmentTextField.isEnabled = true
    }
    
    @IBAction func loadNewProfilePicture(_ sender: Any) {
        loadPicture()
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        birthdayTextField.text = dateFormatter.string(from: datePicker.date)
        editedUserProfile?.birthday = datePicker.date.encodedUTCDateString
    }
    
    private func setupProfilePicture() {
        profilePictureView.layer.borderWidth = 3
        profilePictureView.layer.masksToBounds = false
        profilePictureView.layer.borderColor = Colors.darkOrange.cgColor
        profilePictureView.layer.cornerRadius = profilePictureView.frame.height / 2
        profilePictureView.clipsToBounds = true
    }
    
    private func loadPicture() {
        let cancelButton = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        let cameraButton = UIAlertAction(title: "カメラ", style: .default, handler: { action in
            self.camera()
        })
        let photoLibraryButton = UIAlertAction(title: "写真", style: .default, handler: { action in
            self.photoLibrary()
        })
        let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(cancelButton)
        alertController.addAction(cameraButton)
        alertController.addAction(photoLibraryButton)
        
        self.present(alertController, animated: true)
    }
    
    private func camera() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func photoLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func saveProfilePicture(image: UIImage) {
        Network.request(
            target: .updateUserProfilePicture(profilePicture: image.jpegData(compressionQuality: 0.1)!),
            success: { response in
                let cache = ImageCache.default
                cache.memoryStorage.config.expiration = .days(1)
                cache.diskStorage.config.expiration = .days(7)
                let cacheKey = "profilePicture"
                
                cache.removeImage(forKey: cacheKey)
                cache.store(image, forKey: cacheKey)
                
                self.profilePictureView.image = image
        }, error: { error in
                self.validationAlert(title: "プロフィール", message: error.localizedDescription)
        }, failure: { error in
                self.validationAlert(title: "プロフィール", message: error.localizedDescription)
        })
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            saveProfilePicture(image: image)
        }
        dismiss(animated: true, completion: nil)
    }

}

extension ProfileViewController: UITextFieldDelegate {
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

extension ProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
                    self.editedUserProfile?.companyId = companies[row].id
                    self.editedUserProfile?.company = companies[row].name
                    companyTextField!.text = companies[row].name
                    Network.getBranches(companyId: companies[row].id, success: { branches in
                        self.branches = branches
                        if branches.count > 0 {
                            self.editedUserProfile?.branchId = branches[0].id
                            self.editedUserProfile?.branch = branches[0].name
                            self.branchTextField!.text = branches[0].name
                            Network.getDepartments(branchId: branches[0].id, success: { departments in
                                self.departments = departments
                                if departments.count > 0 {
                                    self.editedUserProfile?.departmentId = departments[0].id
                                    self.editedUserProfile?.department = departments[0].name
                                    self.departmentTextField!.text = departments[0].name
                                } else {
                                    self.editedUserProfile?.departmentId = 0
                                    self.editedUserProfile?.department = nil
                                    self.departmentTextField!.text = ""
                                }
                            }, error: { error in }, failure: { error in })
                        } else {
                            self.editedUserProfile?.branchId = 0
                            self.editedUserProfile?.branch = nil
                            self.branchTextField!.text = ""
                            self.departments = []
                            self.editedUserProfile?.departmentId = 0
                            self.editedUserProfile?.department = nil
                            self.departmentTextField!.text = ""
                        }
                    }, error: { error in }, failure: { error in })
                }
            case .branch:
                if branches.count > 0 {
                    self.editedUserProfile?.branchId = branches[row].id
                    self.editedUserProfile?.branch = branches[row].name
                    branchTextField!.text = branches[row].name
                    Network.getDepartments(branchId: branches[row].id, success: { departments in
                        self.departments = departments
                        if departments.count > 0 {
                            self.editedUserProfile?.departmentId = departments[0].id
                            self.editedUserProfile?.department = departments[0].name
                            self.departmentTextField!.text = departments[0].name
                        } else {
                            self.editedUserProfile?.departmentId = 0
                            self.editedUserProfile?.department = nil
                            self.departmentTextField!.text = ""
                        }
                    }, error: { error in }, failure: { error in })
                }
            case .department:
                if departments.count > 0 {
                    self.editedUserProfile?.departmentId = departments[row].id
                    self.editedUserProfile?.department = departments[row].name
                    departmentTextField!.text = departments[row].name
                }
            case .prefecture: prefectureTextField!.text = prefectures[row].name
            if prefectures.count > 0 {
                self.editedUserProfile?.prefectureId = prefectures[row].id
                self.editedUserProfile?.prefectureCode = prefectures[row].code
                self.editedUserProfile?.prefecture = prefectures[row].name
                prefectureTextField!.text = prefectures[row].name
                }
            }
        }
    }
}
