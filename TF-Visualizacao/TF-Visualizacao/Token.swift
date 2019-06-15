//
//  Structs.swift
//  Reflection
//
//  Created by Max Zorzetti on 22/05/19.
//  Copyright © 2019 Alice Wiener. All rights reserved.
//

import NaturalLanguage

class Token: Codable {
    let raw: String
    var lemma: String
    let partOfSpeechTag: LexicalCategory
    
    init(raw: String, lemma: String, partOfSpeechTag: LexicalCategory) {
        self.raw = raw
        self.lemma = lemma
        self.partOfSpeechTag = partOfSpeechTag
    }
}

extension Token: Hashable {
    var hashValue: Int { return lemma.hashValue }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(lemma)
    }
    
    static func == (lhs: Token, rhs: Token) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

enum LexicalCategory: String, Codable {
    case noun, verb, adjective, adverb, pronoun, determiner, particle, preposition, number, conjunction, interjection, classifier, idiom, unknown
    
    init(from tag: NLTag?) {
        guard let tag = tag else {
            self = .unknown
            return
        }
        
        switch tag.rawValue {
        case "Noun": self = .noun
        case "Verb": self = .verb
        case "Adjective": self = .adjective
        case "Adverb": self = .adverb
        case "Pronoun": self = .pronoun
        case "Determiner": self = .determiner
        case "Particle": self = .particle
        case "Preposition": self = .preposition
        case "Number": self = .number
        case "Conjunction": self = .conjunction
        case "Interjection": self = .interjection
        case "Classifier": self = .classifier
        case "Idiom": self = .idiom
        default: self = .unknown
        }
    }
}
