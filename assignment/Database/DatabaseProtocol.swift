//
//  DatabaseProtocol.swift
//  lab03
//
//  Created by 欧高远 on 25/3/2022.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}
enum ListenerType{
    case transaction
    case currency
    case bill
    case all
    
}
protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
//    func onTeamChange(change: DatabaseChange, teamHeroes: [Superhero])
    func onTransactionsChange(change: DatabaseChange, transactions: [Transaction])
    func onBillsChange(change: DatabaseChange, bills: [Bill])
}
protocol DatabaseProtocol: AnyObject {
//    var defaultTeam: Team {get}
//
//    func addTeam(teamName: String) -> Team
//    func deleteTeam(team: Team)
//    func addHeroToTeam(hero: Superhero, team: Team) -> Bool
//    func removeHeroFromTeam(hero: Superhero, team: Team)
    
    func cleanup()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func addTransaction(type: Int32, date: Date, amount: Float, description: String, category: String) -> Transaction
    func deleteTransaction(transaction: Transaction)
    func addBill(billDescription: String, billDate: Date, amount: Float, category: String, billingCycle: String)
    func deleteBill(bill: Bill)
}
