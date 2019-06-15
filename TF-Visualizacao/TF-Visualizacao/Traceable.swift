//
//  Traceable.swift
//  Reflection
//
//  Created by Max Zorzetti on 21/05/19.
//  Copyright © 2019 Alice Wiener. All rights reserved.
//

import Foundation

protocol Traceable {
    associatedtype T
    var trace: T? { get }
}

extension String: Traceable {
    var trace: Any? { return nil }
}
