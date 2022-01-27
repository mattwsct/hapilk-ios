//
//  EditDashboardViewController.swift
//  Kenko
//
//  Created by David Garcia Tort on 8/20/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit

class EditDashboardViewController: UIViewController {
    
    lazy var date = Date()
    lazy var goal: Double = 0
    lazy var steps: Double = 0
    var healthData: HealthData?
    private var goalPicker: UIPickerView?
    private var goals: [Int] = []
    @IBOutlet weak var goalInputField: UITextField!
    @IBOutlet weak var stepsInputField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Picker
        if goalInputField != nil {
            Network.getGoalsList(success: { goals in
                self.goals = goals
                self.goalPicker = UIPickerView()
                self.goalPicker?.delegate = self
                self.goalPicker?.dataSource = self
                self.goalInputField?.inputView = self.goalPicker
                self.goalInputField?.text = String(Int(self.goal))
                self.goalInputField?.becomeFirstResponder()
            }, error: { error in }, failure: { error in })
        }
        
        if healthData != nil {
            stepsInputField?.text = String(Int(healthData!.steps))
            stepsInputField?.becomeFirstResponder()
        }
    }
    
    @IBAction func changeGoal(_ sender: Any) {
        if validateInputs(inputs: [
            goalInputField: [.goal]
        ]) {
            Network.request(
                target: .updateGoal(goal: Int(goalInputField.text!)!),
                success: { response in
                    self.performSegue(withIdentifier: "showDashboard", sender: nil)
            }, error: { error in
                self.validationAlert(title: "ゴール", message: error.localizedDescription, completion: {
                    self.dismiss(animated: true, completion: nil)
                })
            }, failure: { error in
                self.validationAlert(title: "ゴール", message: error.localizedDescription, completion: {
                    self.dismiss(animated: true, completion: nil)
                })
            })
        }
    }
    
    @IBAction func changeSteps(_ sender: Any) {
        if validateInputs(inputs: [
            stepsInputField: [.steps]
        ]) {
            if var healthData = healthData {
                healthData.steps = Double(stepsInputField.text!)!
                healthData.date = date.encodedUTCDateString
                Network.request(
                    target: .updateUserHealthData(healthData: [healthData]),
                    success: { response in
                        self.performSegue(withIdentifier: "showDashboard", sender: nil)
                }, error: { error in
                    self.validationAlert(title: "歩数", message: error.localizedDescription, completion: {
                        self.dismiss(animated: true, completion: nil)
                    })
                }, failure: { error in
                    self.validationAlert(title: "歩数", message: error.localizedDescription, completion: {
                        self.dismiss(animated: true, completion: nil)
                    })
                })
            }
        }
    }
    
    @IBAction func dismissButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension EditDashboardViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return goals.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(goals[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        goalInputField.text = String(goals[row])
    }
    
}
