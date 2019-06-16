//
//  NeuralSentimentAnalysisPhase.swift
//  Reflection
//
//  Created by Max Zorzetti on 06/06/19.
//  Copyright © 2019 Alice Wiener. All rights reserved.
//

import NaturalLanguage

class NeuralSentimentAnalysis {
    
    static let shared = NeuralSentimentAnalysis()
    
    let tagger: NLTagger = NLTagger(tagSchemes: [.sentimentScore])
    
    func process(input: String) -> Double {
        let text = input
        tagger.string = text
        
        NLTagger.requestAssets(for: .portuguese, tagScheme: .sentimentScore) { (results, error) in
            
        }
        tagger.setLanguage(.portuguese, range: text.startIndex..<text.endIndex)
        
        let eligibleTags = tagger.tags(in: text.startIndex..<text.endIndex, unit: .paragraph, scheme: .sentimentScore).compactMap({ $0.0 != nil ? ($0.0!, $0.1) : nil })
        
        let textScore = eligibleTags.compactMap({ Double($0.0.rawValue) }).reduce(0, +)
    
        return textScore
    }
}
