//
//  CurrencyData.swift
//  assignment
//
//  Created by 欧高远 on 7/5/2022.
//

import Foundation

class CurrencyData: NSObject{
    var name: String?
    var rate: Float?
    var code: String?
    
    init(name: String, rate: Float, code: String) {
        self.rate = rate
        self.name = name
        self.code = code
    }
}
