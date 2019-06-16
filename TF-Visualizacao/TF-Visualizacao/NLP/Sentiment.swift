//
//  Sentiment.swift
//  Reflection
//
//  Created by Max Zorzetti on 22/05/19.
//  Copyright © 2019 Alice Wiener. All rights reserved.
//

import Foundation

class SentimentScoredObject<T> {
    let object: T
    let sentimentScore: SentimentScore
    
    init(object: T, sentimentScore: SentimentScore) {
        self.object = object
        self.sentimentScore = sentimentScore
    }
}

struct SentimentScore {
    let positiveScore: Double
    let negativeScore: Double
    
    var totalScore: Double { return positiveScore - negativeScore}
    
    init(positiveScore: Double, negativeScore: Double) {
        self.positiveScore = positiveScore
        self.negativeScore = negativeScore
    }
    
    init(totalScore: Double) {
        self.positiveScore = totalScore > 0 ? totalScore : 0
        self.negativeScore = totalScore < 0 ? -totalScore : 0
    }
}

struct SentiWordNet: Codable {
    let pos: String
    let id: String
    let positiveScore: Double
    let negativeScore: Double
    let synsetTerms: String
    let gloss: String
    
    private enum CodingKeys : String, CodingKey {
        case pos = "POS", id = "ID", positiveScore = "PosScore", negativeScore = "NegScore", synsetTerms = "SynsetTerms", gloss = "Gloss"
    }
}
