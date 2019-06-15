//
//  NeuralSentimentAnalysisPhase.swift
//  Reflection
//
//  Created by Max Zorzetti on 06/06/19.
//  Copyright © 2019 Alice Wiener. All rights reserved.
//

import NaturalLanguage

class NeuralSentimentAnalysisPhase: SentimentAnalysisPhase {
    
    let tagger: NLTagger = NLTagger(tagSchemes: [.sentimentScore])
    
    override func process(input: OntologyResult) -> SentimentAnalysisResult {
        let preProcessResult = input.trace!
        let text = preProcessResult.trace!
        
        tagger.string = text
        
        NLTagger.requestAssets(for: .english, tagScheme: .sentimentScore) { (results, error) in
            print(results.rawValue)
        }
        tagger.setLanguage(.portuguese, range: text.startIndex..<text.endIndex)
        //NLTagger automatically detects the language the text in written in
		//tagger.setLanguage(.english, range: text.startIndex..<text.endIndex)
        
        let eligibleTags = tagger.tags(in: text.startIndex..<text.endIndex, unit: .paragraph, scheme: .sentimentScore).compactMap({ $0.0 != nil ? ($0.0!, $0.1) : nil })
        
        let tokens: [SentimentScoredObject<Token>] = eligibleTags.map { tag in
            let token = Token(raw: "", lemma: "", partOfSpeechTag: .idiom, trace: tag.1)
            let score = SentimentScore(totalScore: Double(tag.0.rawValue) ?? 0)
            let scoredToken = SentimentScoredObject<Token>(object: token, sentimentScore: score)
            
			return scoredToken
        }
        
        let totalSentimentScore = tokens.map({ $0.sentimentScore.totalScore }).reduce(0, +)
        let averageSentimentScore = totalSentimentScore / Double(tokens.count)
        
        let documentScore = SentimentScore(totalScore: averageSentimentScore)
        let document = SentimentScoredObject(object: text, sentimentScore: documentScore)
        
        let result = SentimentAnalysisResult(scoredDocument: document, scoredTokens: tokens, trace: input)
    
        return result
    }
}
