//
//  UIView+Extensions.swift
//  TF-Visualizacao
//
//  Created by Max Zorzetti on 14/06/19.
//  Copyright © 2019 Matheus Vaccaro. All rights reserved.
//

import UIKit

extension UIView {
    func constrainedExpansion(inside view: UIView, withMargin margin: CGFloat = 0) -> [NSLayoutConstraint] {
        let constraints = [
        	rightAnchor.constraint(equalTo: view.rightAnchor, constant: margin),
        	topAnchor.constraint(equalTo: view.topAnchor, constant: margin),
            leftAnchor.constraint(equalTo: view.leftAnchor, constant: margin),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: margin)]
    
        
        return constraints
    }
    
    func centered(to view: UIView) {
        let constraints = [self.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                           self.centerYAnchor.constraint(equalTo: view.centerYAnchor)]
        NSLayoutConstraint.activate(constraints)
    }
}
