//
//  SentimentAnalysisPhase.swift
//  Reflection
//
//  Created by Max Zorzetti on 22/05/19.
//  Copyright © 2019 Alice Wiener. All rights reserved.
//

import Foundation

class LexiconSentimentAnalysisPhase: SentimentAnalysisPhase {
    
    let lexicon: Lexicon
    
    init(lexicon: Lexicon) {
        self.lexicon = lexicon
    }
    
    override func process(input: OntologyResult) -> SentimentAnalysisResult {
        let preProcessResult = input.trace!
        
        let scoredTokens = score(tokens: preProcessResult.tokens)
        let scoredDocument = score(document: preProcessResult.trace!, basedOn: scoredTokens)
        
        let sentimentAnalysisResult = SentimentAnalysisResult(scoredDocument: scoredDocument, scoredTokens: scoredTokens, trace: input)
        
        return sentimentAnalysisResult
    }
    
    private func score(tokens: [Token]) -> [SentimentScoredObject<Token>] {
        var scoredTokens = [SentimentScoredObject<Token>]()
        
        for token in tokens {
            if let sentimentScore = lexicon.sentimentScore(for: token.lemma) ?? lexicon.sentimentScore(for: token.raw) {
                let scoredToken = SentimentScoredObject<Token>(object: token, sentimentScore: sentimentScore)
                scoredTokens.append(scoredToken)
            }
        }
        
        return scoredTokens
    }
    
    private func score(document: String, basedOn scoredTokens: [SentimentScoredObject<Token>]) -> SentimentScoredObject<String> {
        let averageTokenScore = scoredTokens.map({ $0.sentimentScore.totalScore }).reduce(0, +) / Double(scoredTokens.count)
        
        let documentScore = SentimentScore(totalScore: averageTokenScore)
        let scoredDocument = SentimentScoredObject<String>(object: document, sentimentScore: documentScore)
        
        return scoredDocument
    }
}

class SentimentAnalysisResult: Traceable {
    let trace: OntologyResult?
    
    let scoredDocument: SentimentScoredObject<String>
    let scoredTokens: [SentimentScoredObject<Token>]
    
    init(scoredDocument: SentimentScoredObject<String>, scoredTokens: [SentimentScoredObject<Token>], trace: OntologyResult? = nil) {
        self.scoredDocument = scoredDocument
        self.scoredTokens = scoredTokens
        self.trace = trace
    }
}
