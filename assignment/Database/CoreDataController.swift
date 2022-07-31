//
//  CoreDataController.swift
//  assignment
//
//  Created by 欧高远 on 4/5/2022.
//

import Foundation
import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate{
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    var allTransactionsFetchedResultsController: NSFetchedResultsController<Transaction>?
    var allBillsFetchedResultsController: NSFetchedResultsController<Bill>?

    override init() {
        persistentContainer = NSPersistentContainer(name: "MoneyMonitor-DataModel")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data Stack with error: \(error)")
            }
        }
        super.init()
        
       
    }
    func cleanup() {
        if persistentContainer.viewContext.hasChanges{
            do{
                try persistentContainer.viewContext.save()
            }catch{
                fatalError("Failed to save changes to Core Data Stack with error: \(error)")
            }
        }
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .transaction || listener.listenerType == .all {
            listener.onTransactionsChange(change:.update, transactions:
            fetchAllTransactions())
         }
        else if listener.listenerType == .bill || listener.listenerType == .all {
            listener.onBillsChange(change: .update, bills: fetchAllBills())
          }

        
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func fetchAllTransactions() -> [Transaction] {
        if allTransactionsFetchedResultsController == nil {
         // Do something
            let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
            request.sortDescriptors = [dateSortDescriptor]
            allTransactionsFetchedResultsController = NSFetchedResultsController<Transaction>(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            allTransactionsFetchedResultsController?.delegate = self
            
            do{
                try allTransactionsFetchedResultsController?.performFetch()
            }catch{
                print("Fetch Request Failed \(error)")
            }
         }

         if let transactions = allTransactionsFetchedResultsController?.fetchedObjects {
             return transactions
         }
         return [Transaction]()
    }
    
    func fetchAllBills() -> [Bill] {
        if allBillsFetchedResultsController == nil {
         // Do something
            let request: NSFetchRequest<Bill> = Bill.fetchRequest()
            let dateSortDescriptor = NSSortDescriptor(key: "billDate", ascending: false)
            request.sortDescriptors = [dateSortDescriptor]
            allBillsFetchedResultsController = NSFetchedResultsController<Bill>(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            allBillsFetchedResultsController?.delegate = self
            
            do{
                try allBillsFetchedResultsController?.performFetch()
            }catch{
                print("Fetch Request Failed \(error)")
            }
         }

         if let bills = allBillsFetchedResultsController?.fetchedObjects {
             return bills
         }
         return [Bill]()
    }
    
    
    func addTransaction(type: Int32, date: Date, amount: Float, description: String, category: String) -> Transaction {
        let transaction = NSEntityDescription.insertNewObject(forEntityName: "Transaction", into: persistentContainer.viewContext) as! Transaction
        transaction.type = type
        transaction.date = date
        transaction.amount = amount
        transaction.itemDescription = description
        transaction.category = category
        return transaction
    }
    
    func deleteTransaction(transaction: Transaction) {
        persistentContainer.viewContext.delete(transaction)
    }
    
    func addBill(billDescription: String, billDate: Date, amount: Float, category: String, billingCycle: String) {
        let bill = NSEntityDescription.insertNewObject(forEntityName: "Bill", into: persistentContainer.viewContext) as! Bill
        bill.billDescription = billDescription
        bill.billDate = billDate
        bill.amount = amount
        bill.category = category
        bill.billingCycle = billingCycle
        var dateComponents = DateComponents()
        let formatter = DateFormatter()
        
        //for demonstration purpose
//        formatter.dateFormat = "ss"
//        dateComponents.second = Int(formatter.string(from: billDate))! + 10
//        dateComponents.calendar = Calendar.current

        if billingCycle == "weekly"{
            dateComponents.weekday = Calendar.current.dateComponents([.weekday], from: billDate).weekday! - 1

        }
        else if billingCycle == "monthly"{
            formatter.dateFormat = "dd"
            dateComponents.day = Int(formatter.string(from: billDate))! - 1

        }
        else if billingCycle == "yearly"{
            formatter.dateFormat = "dd"
            dateComponents.day = Int(formatter.string(from: billDate))! - 1
            formatter.dateFormat = "M"
            dateComponents.month = Int(formatter.string(from: billDate))!
        }
        dateComponents.hour = 9

        let content = UNMutableNotificationContent()
        content.title = "Payment Reminder for \(billDescription)"
        content.body = "\(billDescription) will be due tomorrow"
        


        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents, repeats: true)
        let uuidString = UUID().uuidString
        bill.notificationID = uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                    content: content, trigger: trigger)

        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
           if error != nil {
              // Handle any errors.
           }
        }
    }
    
    func deleteBill(bill: Bill) {
        var identifiers: [String] = []
        identifiers.append(bill.notificationID!)
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        persistentContainer.viewContext.delete(bill)

    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allTransactionsFetchedResultsController {
         listeners.invoke() {
             listener in
             if listener.listenerType == .transaction
             || listener.listenerType == .all {
             listener.onTransactionsChange(change: .update,
                                           transactions: fetchAllTransactions())
                }
            }
         }
        else if controller == allBillsFetchedResultsController{
            listeners.invoke() {
                listener in
                if listener.listenerType == .bill
                || listener.listenerType == .all {
                    listener.onBillsChange(change: .update, bills: fetchAllBills())
                   }
               }
        }
   
    }
}
