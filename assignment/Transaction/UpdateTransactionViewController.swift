//
//  UpdateTransactionViewController.swift
//  assignment
//
//  Created by 欧高远 on 11/5/2022.
//

import UIKit

class UpdateTransactionViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
 
    

    @IBOutlet weak var viewBankTransactionsButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: ContentView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var catogeryTextField: UITextField!
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    
    var transaction: Transaction?
    var pickerView = UIPickerView()
    weak var databaseController: DatabaseProtocol?

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    
    @IBAction func updateTransaction(_ sender: Any) {
        guard let _ = TransactionType(rawValue: Int32(typeSegmentedControl.selectedSegmentIndex)), let _ = datePicker?.date, let _ = catogeryTextField.text, let _ = Float(amountTextField.text!), let description = descriptionTextField.text, !description.isBlank else{
            //show error message if getting invalid input
            let errorMsg = "\nPlease ensure all fields are filled"

            displayMessage(title: "Not all fields filled", message: errorMsg)
            
            return
        }
        
        transaction?.type = Int32(typeSegmentedControl.selectedSegmentIndex)
        if transaction?.type == 0 {
            transaction?.amount = Float(amountTextField.text!)! * -1
        }
        else{
            transaction?.amount = Float(amountTextField.text!)!
        }
        
        transaction?.itemDescription = descriptionTextField.text
        transaction?.category = catogeryTextField.text
        transaction?.date = datePicker.date
        displayMessage(title: "Transaction Updated!", message: "", completion: { _ in
                self.navigationController?.popViewController(animated: true)
            })    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        catogeryTextField.delegate = self
        amountTextField.delegate = self
        descriptionTextField.delegate = self
        pickerView.dataSource = self
        pickerView.delegate = self
        catogeryTextField.inputView = pickerView
        
        // Do any additional setup after loading the view.
        guard let transaction = transaction else {
            return
        }
        
        //display the information of current transaction
        typeSegmentedControl.selectedSegmentIndex = Int(transaction.type)
        datePicker.date = transaction.date!
        descriptionTextField.text = transaction.itemDescription!
        
        if transaction.amount < 0{
            amountTextField.text = (transaction.amount * -1).description
        }else{
            amountTextField.text = transaction.amount.description
        }
        
        catogeryTextField.text
        = transaction.category!
        datePicker.maximumDate = Calendar.current.date(byAdding: .day, value: 0, to: .now)
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
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
    }  /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

