//
//  SummaryViewController.swift
//  assignment
//
//  Created by 欧高远 on 13/5/2022.
//

import UIKit
import Charts

class SummaryViewController: UIViewController, DatabaseListener {

    
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var hintLabel: UILabel!
    
    var listenerType: ListenerType = .transaction
    weak var databaseController: DatabaseProtocol?
    var currentTransactions: [Transaction] = []
    


    func onTransactionsChange(change: DatabaseChange, transactions: [Transaction]) {
        currentTransactions = transactions
        
    }
    
    func onBillsChange(change: DatabaseChange, bills: [Bill]) {
        
    }
    
    @IBAction func updateType(_ sender: Any) {
        pieChart.drawHoleEnabled = false
        pieChart.usePercentValuesEnabled = true
        var totalAmount: Float = 0.0
        var expenseAmounts = [String:Float]()
        var incomeAmounts = [String:Float]()
        //initialise the amount for each category
      
        var values = [PieChartDataEntry]()
        var set = PieChartDataSet(entries: values, label: "Categories")
        
        //initialize the dictionaries
        for category in Category.expenseCategories{
            expenseAmounts[category] = 0
        }
        
        for category in Category.incomeCategories{
            incomeAmounts[category] = 0
        }

        //filter the transaction by type(expense or income) and category
        for transaction in currentTransactions {
            if transaction.type == typeSegmentedControl.selectedSegmentIndex{
              
                if typeSegmentedControl.selectedSegmentIndex == 0 {
              
                    for category in Category.expenseCategories{
                        if transaction.category == category{
                            expenseAmounts[category]! += transaction.amount
                            totalAmount += transaction.amount
                        }
                    }
//                    set.setColors(#colorLiteral(red: 0.6453095078, green: 1, blue: 0.1581008136, alpha: 1), #colorLiteral(red: 1, green: 0.6310264468, blue: 0.6414355636, alpha: 1),#colorLiteral(red: 1, green: 0.4534791708, blue: 0.9964446425, alpha: 0.8470588235),#colorLiteral(red: 0.9402045012, green: 1, blue: 0.2969156802, alpha: 0.8470588235),#colorLiteral(red: 1, green: 0.2566058338, blue: 0.2750721872, alpha: 0.8470588235))
//                    for category in Category.expenseCategories{
//                        values.append(PieChartDataEntry(value: Double(amounts[category]!/totalAmount), label: category))
//                    }
                }
                else if typeSegmentedControl.selectedSegmentIndex == 1 {

                    for category in Category.incomeCategories{
                        if transaction.category == category{
                            incomeAmounts[category]! += transaction.amount
                            totalAmount += transaction.amount
                        }
                        }
//                        set.setColors(#colorLiteral(red: 0.6453095078, green: 1, blue: 0.1581008136, alpha: 1), #colorLiteral(red: 1, green: 0.6310264468, blue: 0.6414355636, alpha: 1),#colorLiteral(red: 1, green: 0.4534791708, blue: 0.9964446425, alpha: 0.8470588235))
//                    for category in Category.incomeCategories{
//                        values.append(PieChartDataEntry(value: Double(amounts[category]!/totalAmount), label: category))
//                    }
                }
            }
        }
        if typeSegmentedControl.selectedSegmentIndex == 0{
            set.setColors(#colorLiteral(red: 0.6453095078, green: 1, blue: 0.1581008136, alpha: 1), #colorLiteral(red: 1, green: 0.6310264468, blue: 0.6414355636, alpha: 1),#colorLiteral(red: 1, green: 0.4534791708, blue: 0.9964446425, alpha: 0.8470588235),#colorLiteral(red: 0.9402045012, green: 1, blue: 0.2969156802, alpha: 0.8470588235),#colorLiteral(red: 1, green: 0.2566058338, blue: 0.2750721872, alpha: 0.8470588235))
                               for category in Category.expenseCategories{
                                   values.append(PieChartDataEntry(value: Double(expenseAmounts[category]!/totalAmount), label: category))
                               }
        }
        else {
            set.setColors(#colorLiteral(red: 0.6453095078, green: 1, blue: 0.1581008136, alpha: 1), #colorLiteral(red: 1, green: 0.6310264468, blue: 0.6414355636, alpha: 1),#colorLiteral(red: 1, green: 0.4534791708, blue: 0.9964446425, alpha: 0.8470588235))
                                for category in Category.incomeCategories{
                                    values.append(PieChartDataEntry(value: Double(incomeAmounts[category]!/totalAmount), label: category))
                                }
            
        }

        set.append(contentsOf: values)
        let data = PieChartData(dataSet: set)
        
        pieChart.data = data
        pieChart.drawEntryLabelsEnabled = false
        pieChart.data?.setValueTextColor(.black)

    }
    
    
 
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        if currentTransactions.isEmpty {
            pieChart.isHidden = true
            hintLabel.isHidden = false
        }
        else{
            pieChart.isHidden = false
            hintLabel.isHidden = true
        }
        updateType((Any).self)

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

    
}
