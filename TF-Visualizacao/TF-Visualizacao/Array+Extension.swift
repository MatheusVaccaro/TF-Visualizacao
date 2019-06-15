//
//  Array+Extension.swift
//  TF-Visualizacao
//
//  Created by Max Zorzetti on 15/06/19.
//  Copyright © 2019 Matheus Vaccaro. All rights reserved.
//

import Foundation

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
