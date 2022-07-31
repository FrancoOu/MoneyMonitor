//
//  Bill+CoreDataProperties.swift
//  assignment
//
//  Created by 欧高远 on 9/6/2022.
//
//

import Foundation
import CoreData


extension Bill {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bill> {
        return NSFetchRequest<Bill>(entityName: "Bill")
    }

    @NSManaged public var amount: Float
    @NSManaged public var billDate: Date?
    @NSManaged public var billDescription: String?
    @NSManaged public var billingCycle: String?
    @NSManaged public var category: String?
    @NSManaged public var notificationID: String?

}

extension Bill : Identifiable {

}
