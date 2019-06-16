//
//  WordSizer.swift
//  TF-Visualizacao
//
//  Created by Max Zorzetti on 15/06/19.
//  Copyright © 2019 Matheus Vaccaro. All rights reserved.
//

import NaturalLanguage

class WordSizer {

    private let smallestSize: Double = 10
    private let biggestSize: Double = 500
    private let maxWords: Int = 50
    
    private var counts: [Token: Int] = [:]
    
    func reset() {
        counts = [:]
    }
    
    func count(tokens: [Token]) {
        for token in tokens {
            counts[token] = 1 + (counts[token] ?? 0)
        }
    }
    
    func spit() -> [(word: String, size: Int)] {
        let words = counts
            .map({ (word: $0.key.lemma, size: counts[$0.key]!) })
            .sorted(by: { $0.size > $1.size })
        	.prefix(maxWords)
        	.asArray()
        
        let sizes = words.map({ $0.size })
        let smallest = sizes.reduce(.max, min)
        let biggest = sizes.reduce(.min, max)
        
        let scaledWords = words.map({ ($0.word, scale(size: $0.size, between: smallest, and: biggest)) })
        
        return scaledWords
    }
    
    private func scale(size: Int, between smallest: Int, and biggest: Int) -> Int {
        let percentageSize = Double(size - smallest) / Double(biggest - smallest)
        let moddedSize = pow(percentageSize, 1.2)
        let scaledSize = (biggestSize - smallestSize) * moddedSize + smallestSize
        
        return Int(scaledSize)
    }
}
