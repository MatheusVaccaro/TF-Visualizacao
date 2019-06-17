//
//  NumberDateFormatter.swift
//  TF-Visualizacao
//
//  Created by Max Zorzetti on 17/06/19.
//  Copyright © 2019 Matheus Vaccaro. All rights reserved.
//

import Foundation

class NumberDateFormatter: NumberFormatter {
    
    let dateFormatter = DateFormatter()
    
    override func string(from number: NSNumber) -> String? {
        let date = Date(timeIntervalSince1970: number.doubleValue)

        dateFormatter.dateFormat = "dd/MM"
        let week = dateFormatter.string(from: date)
        
        return week
    }
}
