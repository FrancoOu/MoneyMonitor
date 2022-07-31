//
//  BillViewController.swift
//  assignment
//
//  Created by 欧高远 on 6/5/2022.
//

import UIKit
class BillViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DatabaseListener {
    
    var listenerType: ListenerType = .bill
    let BILL_CELL = "bill"
    let INFO_CELL = "hint"
    
    @IBOutlet weak var billTotal: UILabel!
    @IBOutlet weak var billTableView: UITableView!
    var currentBills = [Bill]()
    weak var databaseController: DatabaseProtocol?

    func onTransactionsChange(change: DatabaseChange, transactions: [Transaction]) {
        
    }
    
    func onBillsChange(change: DatabaseChange, bills: [Bill]) {
        //shows bills' amount when bills are changed
        currentBills = bills
        billTableView.reloadData()
        var amount: Float = 0.0
        for bill in bills {
            amount += bill.amount
        }
        billTotal.text = amount.formatted(.currency(code: "AUD"))
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //set up the embedded tableview
        billTableView.delegate = self
        billTableView.dataSource = self
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
     super.viewWillAppear(animated)
     databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
     super.viewWillDisappear(animated)
     databaseController?.removeListener(listener: self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return currentBills.count
        }
        else if section == 1{
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: BILL_CELL,for:indexPath)
            var content = cell.defaultContentConfiguration()
            let currentBill = currentBills[indexPath.row]
            content.text = currentBill.billDescription
            let component = Calendar.current.dateComponents([.day], from: Date.now, to: currentBill.billDate!)
            if component.day! >= 0{
                content.secondaryText = "Due in \(component.day!) day(s) \(currentBill.amount.formatted(.currency(code: "aud")))"
                
            }
            else{
                content.secondaryText = "Overdue for \(component.day! * -1) day(s) \(currentBill.amount.formatted(.currency(code: "aud")))"
            }
            cell.contentConfiguration = content
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: INFO_CELL,for:indexPath) as! InfoTableViewCell
            if currentBills.isEmpty{
                cell.label.text = "No Bills! \nPlease click '+' at top-right to add some"
                
            }
            else {
                cell.label.text = "\(currentBills.count) Bills."
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0{
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            deleteAlert(indexPath: indexPath)
        }
    }
    
    func deleteAlert(indexPath:IndexPath){
        //ask user to confirm the deletion
        let alert = UIAlertController(title: nil, message: "Are you sure you'd like to delete this bill?", preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            let bill = self.currentBills[indexPath.row]
            self.databaseController?.deleteBill(bill: bill)
            self.currentBills.remove(at: indexPath.row)
            }
        alert.addAction(yesAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)

    }
}
