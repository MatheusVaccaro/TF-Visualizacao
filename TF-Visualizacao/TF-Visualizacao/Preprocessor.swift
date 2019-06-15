//
//  PreprocessPhase.swift
//  Reflection
//
//  Created by Max Zorzetti on 21/05/19.
//  Copyright © 2019 Alice Wiener. All rights reserved.
//

import Foundation
import NaturalLanguage

class Preprocessor {
    
    static let shared = Preprocessor()
    
    private typealias Word = (text: String, trace: Range<String.Index>)
    private typealias LemmatizedWord = (word: Word, lemma: String)
    private typealias POSTaggedWord = (word: Word, lexicalCategory: LexicalCategory)
    
    private let tagger = NLTagger(tagSchemes: [.lexicalClass, .lemma])
    private let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation, .omitOther]
    
    func process(input: String) -> [Token] {
        let tokens = tokenizeText(input.lowercased())
        
        return tokens
    }
    
    private func tokenizeText(_ text: String) -> [Token] {
        
        tagger.string = text
        
        let lemmatization = lemmatize(text)
        let posTagging = partOfSpeechTagging(text)
        
        var tokens: [Token] = []
        for index in 0..<posTagging.count {
            let posTag = posTagging[index].lexicalCategory
            guard posTag == .noun else { continue }
            
            let rawText = posTagging[index].word.text
            let lemma = filterWord(rawText) ?? lemmatization[index].lemma
            
            let token = Token(raw: rawText, lemma: lemma, partOfSpeechTag: posTag)
            tokens.append(token)
        }
        
        return tokens
    }
    
    private func lemmatize(_ text: String) -> [LemmatizedWord] {
        var lemmatization: [LemmatizedWord] = []
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lemma, options: options) { tag, tokenRange in
            let word = (text: String(text[tokenRange].lowercased()), trace: tokenRange)
            let lemma = (tag?.rawValue ?? word.text)
            lemmatization.append((word, lemma))
            
            return true
        }
        
        // It's not clear what happened. 👎 ['s -> 's]
        // Cats don't like water. 👍 [n't -> not]
        
        return lemmatization
    }
    
    private func partOfSpeechTagging(_ text: String) -> [POSTaggedWord] {
        
        // Pen Treebank: https://www.ling.upenn.edu/courses/Fall_2003/ling001/penn_treebank_pos.html
        // C5 Tagset: http://www.natcorp.ox.ac.uk/docs/c5spec.html
        var posTagging: [POSTaggedWord] = []
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            let word = (text: String(text[tokenRange]), trace: tokenRange)
            
            let lexicalCategory = LexicalCategory(from: tag)
            posTagging.append((word, lexicalCategory))
            
            return true
        }
        
        // It's not clear what happened. 👍 ['s -> verb]
        // Cats don't like water. 👍 [do -> verb, n't -> adverb]
        // John saw the saw. 👍 [1.saw -> verb, 2. saw -> noun]
        // Time flies like an arrow. 👍 [like -> preposition]
        
        return posTagging
    }
    
    private let filter: [String:String] =
        ["ages":"AGES",
         "java": "Java",
         "javascript": "JavaScript",
    	 "js": "JavaScript",
         "stakeholders": "stakeholder",
         "react": "React",
         "api": "API",
         "mockups": "mockup",
         "css": "CSS",
         "back": "backend",
         "front": "frontend",
         "stories": "story"]
    
    private func filterWord(_ word: String) -> String? {
        return filter[word]
    }
}
