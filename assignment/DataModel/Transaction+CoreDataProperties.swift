//
//  Transaction+CoreDataProperties.swift
//  assignment
//
//  Created by 欧高远 on 7/5/2022.
//
//

import Foundation
import CoreData
enum TransactionType: Int32{
     case expense = 0
     case income = 1
}

extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var amount: Float
    @NSManaged public var category: String?
    @NSManaged public var date: Date?
    @NSManaged public var itemDescription: String?
    @NSManaged public var type: Int32

}

extension Transaction : Identifiable {

}
extension Transaction {
    var transactionType: TransactionType{
        get{
            return TransactionType(rawValue: self.type)!
        }
        set{
            self.type = newValue.rawValue
        }
    }
}
