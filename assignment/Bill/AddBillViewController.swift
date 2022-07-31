//
//  AddBillViewController.swift
//  assignment
//
//  Created by 欧高远 on 13/5/2022.
//

import UIKit

class AddBillViewController: UIViewController,
                             UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: ContentView!
    weak var databaseController: DatabaseProtocol?
    @IBOutlet weak var billDescriptionTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var billingCycleTextField: UITextField!
    var periodPickerView = UIPickerView()
    var categoryPickerView = UIPickerView()
    let period = ["weekly", "monthly", "yearly"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        categoryTextField.delegate = self
        amountTextField.delegate = self
        billDescriptionTextField.delegate = self
        
        periodPickerView.delegate = self
        periodPickerView.dataSource = self
        periodPickerView.tag = 0
        billingCycleTextField.inputView = periodPickerView

        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        categoryPickerView.tag = 1
        categoryTextField.inputView = categoryPickerView
        
        datePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 0, to: .now)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    @IBAction func addBill(_ sender: Any) {
        guard let billDescription = billDescriptionTextField.text, let amount = Float(amountTextField.text!),
              let category = categoryTextField.text, let date = datePicker?.date,
              let billingCycle = billingCycleTextField.text, !description.isBlank, !billingCycle.isBlank else{
            //show error message if getting invalid input
            let errorMsg = "\nPlease ensure all fields are filled"

            displayMessage(title: "Not all fields filled", message: errorMsg)
            return
        }
        databaseController?.addBill(billDescription: billDescription, billDate: date, amount: amount, category: category, billingCycle: billingCycle)
        
        //a popup will be displayed when the bill is added
        displayMessage(title: "Bill Added!", message: "You will be notified at 9am one day before the due date.", completion: { _ in
                self.navigationController?.popViewController(animated: true)
            })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)

    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo, let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            bottomConstraint.constant = keyboardSize.cgRectValue.height
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {

        bottomConstraint.constant = 0
     }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0{
            return period.count
        }
        else {
            return Category.expenseCategories.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0{
            return period[row]
        }
        else{
            return Category.expenseCategories[row]
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0{
            billingCycleTextField.text = period[row]
            billDescriptionTextField.resignFirstResponder()
        }
        else{
            categoryTextField.text = Category.expenseCategories[row]
            categoryTextField.resignFirstResponder()
        }
    }
}
