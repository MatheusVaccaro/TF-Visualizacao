//
//  OntologyPhase.swift
//  Reflection
//
//  Created by Max Zorzetti on 22/05/19.
//  Copyright © 2019 Alice Wiener. All rights reserved.
//

import NaturalLanguage

class OntologyPhase: NLPPhase {
    
    private let tagger = NLTagger(tagSchemes: [.nameType])
    
    func process(input: PreprocessResult) -> OntologyResult {
        guard let rawText = input.trace else { fatalError("No input string.") }
        
        tagger.string = rawText
        
        var entities = [Entity]()
        
        let entityTypes: [NLTag] = [.personalName, .placeName, .organizationName]
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        
        tagger.enumerateTags(in: rawText.startIndex..<rawText.endIndex, unit: .word, scheme: .nameType, options: options) { (tag, range) -> Bool in
            if let tag = tag, entityTypes.contains(tag) {
                let entityName = String(rawText[range])
                let entity = Entity(name: entityName, trace: range)
                entities.append(entity)
            }
            return true
        }
        
        let ontologyResult = OntologyResult(entities: entities, trace: input)
        
        return ontologyResult
    }
}

class OntologyResult: Traceable {
    let trace: PreprocessResult?
    
    let entities: [Entity]
    
    init(entities: [Entity], trace: PreprocessResult? = nil) {
        self.trace = trace
        self.entities = entities
    }
}

class Entity: Traceable {
    let trace: Range<String.Index>?
    
    let name: String
    
    init(name: String, trace: Range<String.Index>? = nil) {
        self.trace = trace
        self.name = name
    }
}

extension Entity: CustomStringConvertible {
    var description: String { return name }
}
