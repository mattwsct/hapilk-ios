//
//  Validator.swift
//  Kenko
//
//  Created by David Garcia Tort on 7/2/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import Foundation
import UIKit.UITextField

class ValidationError: Error {
    var message: String
    
    init(_ message: String) {
        self.message = message
    }
}

enum ValidationType {
    case required(fieldName: String)
    case length(fieldName: String, min: Int?, max: Int?)
    case user
    case password
    case passwordConfirmation(password: String)
    case phoneNumber
    case verificationCode
    case height
    case weight
    case birthday
    case company
    case employeeNumber
    case name
    case displayName
    case prefecture
    case goal
    case steps
}

enum ValidatorFactory {
    static func validatorFor(type: ValidationType) -> ValidatorConvertible {
        switch type {
        case let .required(fieldName): return RequiredValidator(fieldName)
        case let .length(fieldName, min, max): return LengthValidator(fieldName: fieldName, min: min, max: max)
        case .user: return UserValidator()
        case .password: return PasswordValidator()
        case let .passwordConfirmation(password): return PasswordConfirmationValidator(password)
        case .phoneNumber: return PhoneNumberValidator()
        case .verificationCode: return VerificationCodeValidator()
        case .height: return HeightValidator()
        case .weight: return WeightValidator()
        case .birthday: return BirthdayValidator()
        case .company: return CompanyValidator()
        case .employeeNumber: return EmployeeNumberValidator()
        case .name: return NameValidator()
        case .displayName: return DisplayNameValidator()
        case .prefecture: return PrefectureValidator()
        case .goal: return GoalValidator()
        case .steps: return StepsValidator()
        }
    }
}

protocol ValidatorConvertible {
    func validate(_ value: String) throws
}

struct RequiredValidator: ValidatorConvertible {
    private let fieldName: String
    
    init(_ fieldName: String) {
        self.fieldName = fieldName
    }
    
    func validate(_ value: String) throws {
        guard !value.isEmpty else { throw ValidationError("\(fieldName)は必須項目です") }
    }
}

struct LengthValidator: ValidatorConvertible {
    private let fieldName: String
    private let min: Int?
    private let max: Int?
    
    init(fieldName: String, min: Int?, max: Int?) {
        self.fieldName = fieldName
        self.min = min
        self.max = max
    }
    
    func validate(_ value: String) throws {
        if let min = min, let max = max {
            guard !(value.count < min) && !(value.count > max) else { throw ValidationError("\(fieldName)は\(min)から\(max)文字必要です")}
        }

        guard let min = min else {
            guard let max = max else { return }
            guard !(value.count > max) else { throw ValidationError("\(fieldName)の最大文字数は\(max)です") }
            return
        }
        
        guard !(value.count < min) else { throw ValidationError("\(fieldName)はあと\(min)文字必要です") }
    }
}

struct UserValidator: ValidatorConvertible {
    func validate(_ value: String) throws {
        try RequiredValidator("ユーザー").validate(value)
    }
}

struct PasswordValidator: ValidatorConvertible {
    func validate(_ value: String) throws {
        try RequiredValidator("パスワード").validate(value)
        try LengthValidator(fieldName: "パスワード", min: 5, max: nil).validate(value)
    }
}

struct PasswordConfirmationValidator: ValidatorConvertible {
    private let password: String
    
    init(_ password: String) {
        self.password = password
    }
    
    func validate(_ value: String) throws {
        guard value == password else { throw ValidationError("パスワードが間違っています") }
    }
}

struct PhoneNumberValidator: ValidatorConvertible {
    func validate(_ value: String) throws {
        try RequiredValidator("電話番号").validate(value)
    }
}

struct VerificationCodeValidator: ValidatorConvertible {
    func validate(_ value: String) throws {
        try RequiredValidator("認証コード").validate(value)
        guard value.count == 6 else { throw ValidationError("認証コードが一致しません") }
    }
}

struct HeightValidator: ValidatorConvertible {
    func validate(_ value: String) throws {
        try RequiredValidator("身長").validate(value)
    }
}

struct WeightValidator: ValidatorConvertible {
    func validate(_ value: String) throws {
        try RequiredValidator("体重").validate(value)
    }
}

struct BirthdayValidator: ValidatorConvertible {
    func validate(_ value: String) throws {
        try RequiredValidator("生年月日").validate(value)
    }
}

struct CompanyValidator: ValidatorConvertible {
    func validate(_ value: String) throws {
        try RequiredValidator("会社").validate(value)
    }
}

struct EmployeeNumberValidator: ValidatorConvertible {
    func validate(_ value: String) throws {
        try RequiredValidator("従業員番号").validate(value)
        try LengthValidator(fieldName: "従業員番号", min: 5, max: 8).validate(value)
    }
}

struct NameValidator: ValidatorConvertible {
    func validate(_ value: String) throws {
        try RequiredValidator("氏名").validate(value)
    }
}

struct DisplayNameValidator: ValidatorConvertible {
    func validate(_ value: String) throws {
        try RequiredValidator("ニックネーム").validate(value)
    }
}

struct PrefectureValidator: ValidatorConvertible {
    func validate(_ value: String) throws {
        try RequiredValidator("都道府県").validate(value)
    }
}

struct GoalValidator: ValidatorConvertible {
    func validate(_ value: String) throws {
        try RequiredValidator("ゴール").validate(value)
    }
}

struct StepsValidator: ValidatorConvertible {
    func validate(_ value: String) throws {
        try RequiredValidator("歩数").validate(value)
    }
}

extension UITextField {
    func validateInput(validationType: ValidationType) throws {
        let validator = ValidatorFactory.validatorFor(type: validationType)
        try validator.validate(self.text!)
    }
}

extension UIViewController {
    func validateInputs(inputs: [UITextField: [ValidationType]]) -> Bool {
        do {
            for input in inputs {
                for validation in input.value {
                    try input.key.validateInput(validationType: validation)
                }
            }
            return true
        } catch let error {
            let error = (error as! ValidationError).message
            let alert = UIAlertController.init(title: "認証エラー", message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
        return false
    }
}
