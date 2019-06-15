//
//  Lexicons.swift
//  Reflection
//
//  Created by Max Zorzetti on 22/05/19.
//  Copyright © 2019 Alice Wiener. All rights reserved.
//

import Foundation

protocol Lexicon {
    func sentimentScore(for word: String) -> SentimentScore?
}

class AFINNLexicon: Lexicon {
    
    private static let afinnFile = "AFINN"
    
    private var backingData: Dictionary<String, Double>!
    
    init() {
        if let path = Bundle.main.path(forResource: AFINNLexicon.afinnFile, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, Double> {
                    self.backingData = jsonResult
                }
            } catch {
                fatalError("Failed to load AFINN lexicon.")
            }
        } else {
            fatalError("AFINN lexicon not found.")
        }
    }
    
    func sentimentScore(for word: String) -> SentimentScore? {
        guard let afinnScore = backingData[word.lowercased()] else { return nil }
        
        let normalizedScore = afinnScore / 5
        let sentimentScore = SentimentScore(totalScore: normalizedScore)
        
        return sentimentScore
    }
}
