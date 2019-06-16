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
}
