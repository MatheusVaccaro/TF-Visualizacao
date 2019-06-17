//
//  Array+Extension.swift
//  TF-Visualizacao
//
//  Created by Max Zorzetti on 15/06/19.
//  Copyright © 2019 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit

extension ArraySlice {
    func asArray() -> Array<Self.Element>{
        return Array(self)
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Range where Range.Bound == String.Index {
    static var zero: Range<String.Index> {
        return Range<String.Index>(NSRange(location: 0, length: 0), in: "")!
    }
}

extension UIColor {
    static var random: UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
//    static var lightOrange: UIColor {
//        return .orange.lighter()
//    }
//
    func lighter(by percentage: CGFloat = 20.0) -> UIColor! {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage: CGFloat = 20.0) -> UIColor! {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat = 20.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}

struct App {
    static let detailColor = UIColor.orange
    
    static let projects = ["Desastres", "Dietoterapia", "Easy Class", "Milhas", "OAB", "Paisagem", "Rastreamento"]
    
    static let projectColor = ["Desastres" : UIColor.yellow.darker()!,
                               "Dietoterapia" : UIColor.red,
                               "Easy Class" : UIColor.blue,
                               "Milhas" : UIColor.cyan,
                               "OAB" : UIColor.green,
                               "Paisagem" : UIColor.magenta,
                               "Rastreamento" : UIColor.purple]
}



