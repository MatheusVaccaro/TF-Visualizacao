//
//  ReflectionWrapUpPhase.swift
//  Reflection
//
//  Created by Max Zorzetti on 22/05/19.
//  Copyright © 2019 Alice Wiener. All rights reserved.
//

import Foundation

class ReflectionWrapUpPhase: NLPPhase {
    
    func process(input: SentimentAnalysisResult) -> ReflectionAnalysis {
        let reflectionAnalysis = ReflectionAnalysis(scoredDocument: input.scoredDocument,
                                                    scoredTokens: input.scoredTokens,
                                                    entities: input.trace!.entities,
                                                    trace: input)
        
        return reflectionAnalysis
    }
}

struct ReflectionAnalysis: Traceable {
    let trace: SentimentAnalysisResult?
    
    let scoredDocument: SentimentScoredObject<String>
    let scoredTokens: [SentimentScoredObject<Token>]
    let entities: [Entity]
    
    init(scoredDocument: SentimentScoredObject<String>, scoredTokens: [SentimentScoredObject<Token>], entities: [Entity], trace: SentimentAnalysisResult? = nil) {
        self.scoredDocument = scoredDocument
        self.scoredTokens = scoredTokens
        self.entities = entities
        self.trace = trace
    }
}

extension ReflectionAnalysis {
    static func empty() -> ReflectionAnalysis {
        return ReflectionAnalysis(scoredDocument: SentimentScoredObject(object: "", sentimentScore: SentimentScore(totalScore: 0)), scoredTokens: [], entities: [])
    }
}
