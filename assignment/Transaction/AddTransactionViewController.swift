//
//  AddTransactionViewController.swift
//  assignment
//
//  Created by 欧高远 on 29/4/2022.
//

import UIKit

class AddTransactionViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBAction func onhh(_ sender: Any) {
        catogeryTextField.resignFirstResponder()

    }
    @IBOutlet weak var viewBankTransactionsButton: UIButton!
    @IBOutlet weak var contentView: ContentView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var catogeryTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    weak var databaseController: DatabaseProtocol?
    
    //string list for pickerView
    var pickerView = UIPickerView()
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //add the transaction to core data
    @IBAction func addTransaction(_ sender: Any) {
        // check if getting nil
        guard let type = TransactionType(rawValue: Int32(typeSegmentedControl.selectedSegmentIndex)), let date = datePicker?.date, let category = catogeryTextField.text, var amount = Float(amountTextField.text!), let description = descriptionTextField.text, !description.isBlank else{
            //show error message if getting invalid input
            let errorMsg = "\nPlease ensure all fields are filled"

            displayMessage(title: "Not all fields filled", message: errorMsg)
            
            return
        }
        if typeSegmentedControl.selectedSegmentIndex == 0{
            amount *= -1
        }
        let _ = databaseController?.addTransaction(type: type.rawValue, date: date, amount: amount, description: description, category: category)
        
        displayMessage(title: "Transaction Added!", message: "", completion: { _ in
                self.navigationController?.popViewController(animated: true)
            })

}

    
    override func viewDidLoad() {
        super.viewDidLoad()
        catogeryTextField.delegate = self
        amountTextField.delegate = self
        descriptionTextField.delegate = self
        pickerView.delegate = self
        pickerView.dataSource = self
        catogeryTextField.inputView = pickerView

        // Do any additional setup after loading the view.
        // add the database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        //limiting the maximum date to current date
        datePicker.maximumDate = Calendar.current.date(byAdding: .day, value: 0, to: .now)
        viewBankTransactionsButton.titleLabel?.textAlignment = .center
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //end editing if user touches on the Content view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        contentView.touchesBegan(touches, with: event)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if typeSegmentedControl.selectedSegmentIndex == 0{
            return Category.expenseCategories.count
        }
        else{
            return Category.incomeCategories.count
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if typeSegmentedControl.selectedSegmentIndex == 0{
            return Category.expenseCategories[row]
        }
        else{
            return Category.incomeCategories[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if typeSegmentedControl.selectedSegmentIndex == 0{
            catogeryTextField.text = Category.expenseCategories[row]
            catogeryTextField.resignFirstResponder()
        }
        else{
            catogeryTextField.text = Category.incomeCategories[row]
            catogeryTextField.resignFirstResponder()
        }
    }
    
}
//refer to https://stackoverflow.com/a/44335392
extension String {
    var isBlank: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

