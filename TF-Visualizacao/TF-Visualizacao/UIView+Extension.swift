//
//  UIView+Extensions.swift
//  TF-Visualizacao
//
//  Created by Max Zorzetti on 14/06/19.
//  Copyright © 2019 Matheus Vaccaro. All rights reserved.
//

import UIKit

extension UIView {
    func constrainedExpansion(inside view: UIView, withMargin margin: CGFloat = 0) {
        let constraints = [
        	rightAnchor.constraint(equalTo: view.rightAnchor, constant: margin),
        	topAnchor.constraint(equalTo: view.topAnchor, constant: margin),
            leftAnchor.constraint(equalTo: view.leftAnchor, constant: margin),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: margin)]
    
        NSLayoutConstraint.activate(constraints)
    }
    
    func centered(to view: UIView) {
        let constraints = [self.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                           self.centerYAnchor.constraint(equalTo: view.centerYAnchor)]
        
        NSLayoutConstraint.activate(constraints)
    }
}

extension UIColor {
    convenience init?(hexString: String) {
        var chars = Array(hexString.hasPrefix("#") ? hexString.dropFirst() : hexString[...])
        let red, green, blue, alpha: CGFloat
        switch chars.count {
        case 3:
            chars = chars.flatMap { [$0, $0] }
            fallthrough
        case 6:
            chars = ["F","F"] + chars
            fallthrough
        case 8:
            alpha = CGFloat(strtoul(String(chars[0...1]), nil, 16)) / 255
            red   = CGFloat(strtoul(String(chars[2...3]), nil, 16)) / 255
            green = CGFloat(strtoul(String(chars[4...5]), nil, 16)) / 255
            blue  = CGFloat(strtoul(String(chars[6...7]), nil, 16)) / 255
        default:
            return nil
        }
        self.init(red: red, green: green, blue:  blue, alpha: alpha)
    }
}
