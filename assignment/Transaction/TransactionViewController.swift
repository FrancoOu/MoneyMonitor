//
//  TransactionViewController.swift
//  assignment
//
//  Created by 欧高远 on 29/4/2022.
//

import UIKit

class TransactionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DatabaseListener {

    
    var listenerType: ListenerType = .transaction
    weak var databaseController: DatabaseProtocol?
   
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var transactionTableView: UITableView!
    let SECTION_TRANSACTION = 0
    let SECTION_HINT = 1
    let TRANSACTION_CELL = "Transaction"
    let HINT_CELL = "hint"
    let dateFormatter = DateFormatter()
    var amount: Float = 0.0
    var currentTransactions: [Transaction] = []
    var filteredTransactions: [Transaction] = []
    var currentCurrency = CurrencyData(name: "Australian Dollar", rate: 1.0, code: "AUD")
    
    func onBillsChange(change: DatabaseChange, bills: [Bill]) {
        
    }
    
    func onTransactionsChange(change: DatabaseChange, transactions: [Transaction]) {
        currentTransactions = transactions
        filteredTransactions = transactions
        filterTransactionByType((Any).self)
        dateChange()
        transactionTableView.reloadData()
        totalAmount.text = amount.formatted(.currency(code: currentCurrency.code!))

    }

    @IBAction func goToToday(_ sender: Any) {
        //set the date to current date
        datePicker.setDate(Date.now, animated: true)
        datePicker.setNeedsFocusUpdate()
        datePicker.setNeedsDisplay()
        filterTransactionByDate(sender)
    }
    
    @IBAction func filterTransactionByDate(_ sender: Any) {
        //filter the transactions according to the date but need to be filtered by type first
        filterTransactionByType(sender)
        dateChange()
        totalAmount.text = amount.formatted(.currency(code: currentCurrency.code!))

    }
    
    func dateChange(){
        //filter the transactions by date
        dateFormatter.dateFormat = "dd/MM/yyyy"
        filteredTransactions = filteredTransactions.filter{
            transaction in
            let transactionDate = dateFormatter.string(from: transaction.date!)
            let currentDate = dateFormatter.string(from: datePicker.date)
            return transactionDate == currentDate
        }
        amount = 0
        //sum up all the amount of all transactions
        for transaction in filteredTransactions {
            amount += transaction.amount
        }
        transactionTableView.reloadData()
    }
    
    @IBAction func filterTransactionByType(_ sender: Any) {
        //filter the transactions according to the type
        if typeSegmentedControl.selectedSegmentIndex == 0{
            filteredTransactions = currentTransactions.filter{
                transaction in
                return transaction.type == 0
            }
            transactionTableView.reloadData()
        }
        else if typeSegmentedControl.selectedSegmentIndex == 1{
            filteredTransactions = currentTransactions.filter{
                transaction in
                return transaction.type == 1
            }
            transactionTableView.reloadData()
        }
        dateChange()
        totalAmount.text = amount.formatted(.currency(code: currentCurrency.code!))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set up the embedded tableview
        transactionTableView.delegate = self
        transactionTableView.dataSource = self
        // Do any additional setup after loading the view.
        
        //add the database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        totalAmount.text = 0.0.formatted(.currency(code: currentCurrency.code!))
        filteredTransactions = currentTransactions
        
        //Create a NotificationCenter to recieve data from CurrenciesTableViewController
        NotificationCenter.default.addObserver(self, selector: #selector(changeCurrency), name: NSNotification.Name(rawValue: "Currency"), object: nil)

    }
   
    
    @objc func changeCurrency(notification: NSNotification){
        //change the amount according to the exchange rate
        let newCurrency = notification.object as! CurrencyData
        for transaction in currentTransactions {
            transaction.amount = transaction.amount/currentCurrency.rate! * (newCurrency.rate)!
        }
        currentCurrency = newCurrency
        transactionTableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //show the current selected date as header
        if section == 0{
            dateFormatter.dateFormat = "dd/MM/yyyy EEE"
            
            return dateFormatter.string(from: datePicker.date)
        }
        else{
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SECTION_TRANSACTION{
            return filteredTransactions.count
        }
        else if section == SECTION_HINT{
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //create new cell for new transaction
        if indexPath.section == SECTION_TRANSACTION{
            let cell = tableView.dequeueReusableCell(withIdentifier: TRANSACTION_CELL,for:indexPath)
            var content = cell.defaultContentConfiguration()
            let currentTransaction = filteredTransactions[indexPath.row]
            content.text = currentTransaction.itemDescription
            content.secondaryText = currentTransaction.amount.formatted(.currency(code:currentCurrency.code!))
            cell.contentConfiguration = content
            return cell
        }
        else
        {   //show the infomation of transactions
            let infoCell = tableView.dequeueReusableCell(withIdentifier: HINT_CELL, for: indexPath) as! InfoTableViewCell
            if filteredTransactions.isEmpty{
                infoCell.label.text = "NO \(typeSegmentedControl.titleForSegment(at: typeSegmentedControl.selectedSegmentIndex) ?? "Transaction")! \nPlease click '+' at top-right to add some"
            }
            else{
                infoCell.label.text = "\(filteredTransactions.count) Transaction(s)"
            }
          return infoCell
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == SECTION_TRANSACTION{
            return true
        }
        return false
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            deleteAlert(indexPath: indexPath)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "updateTransactionSegue"{
            let destination = segue.destination as! UpdateTransactionViewController
            destination.transaction = filteredTransactions[transactionTableView.indexPathForSelectedRow!.row]
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         databaseController?.removeListener(listener: self)
    }

    //alert when user deletes the transaction
    func deleteAlert(indexPath:IndexPath){
        let alert = UIAlertController(title: nil, message: "Are you sure you'd like to delete this transaction?", preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            let transaction = self.filteredTransactions[indexPath.row]
            self.databaseController?.deleteTransaction(transaction: transaction)
            self.amount -= transaction.amount
            self.totalAmount.text = self.amount.formatted(.currency(code: self.currentCurrency.code ?? "AUS"))
            self.currentTransactions.remove(at: indexPath.row)
            }
        alert.addAction(yesAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
