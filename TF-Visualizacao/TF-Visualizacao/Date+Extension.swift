//
//  Date+Extension.swift
//  TF-Visualizacao
//
//  Created by Max Zorzetti on 14/06/19.
//  Copyright © 2019 Matheus Vaccaro. All rights reserved.
//

import Foundation

extension Date {
    static func from(string dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        let date = dateFormatter.date(from: dateString)!
        
        return date
    }
    
    static func from(altString dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E MMM d HH:mm:ss yyyy"
//        Tue Nov 27 20:04:14 2018
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        let date = dateFormatter.date(from: dateString)!
        
        return date
    }
    
    static var zero: Date { return Date(timeIntervalSince1970: 0) }
}
