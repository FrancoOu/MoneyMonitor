//
//  ExchangeRate.swift
//  assignment
//
//  Created by 欧高远 on 7/5/2022.
//

import Foundation
class ExchangeRateData: NSObject, Decodable{
//    var currency: String?
    var rates: Dictionary<String, Float>?
    
    required init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: ExchangeRateKeys.self)
        rates = try rootContainer.decode([String:Float].self, forKey: .rates)
    }
    
    private enum ExchangeRateKeys: String, CodingKey{
        case rates
    }
    
}
