//
//  ReflectionAnalysisPipeline.swift
//  Reflection
//
//  Created by Max Zorzetti on 21/05/19.
//  Copyright © 2019 Alice Wiener. All rights reserved.
//

import Foundation

class ReflectionAnalysisPipeline: NaturalLanguageProcessingPipeline {
    
    private var isProcessing: Bool = false

    var preProcessPhase: PreprocessPhase
    var ontologyPhase: OntologyPhase
    var sentimentAnalysisPhase: SentimentAnalysisPhase
    var wrapUpPhase: ReflectionWrapUpPhase
    
    init(preProcess: PreprocessPhase, ontology: OntologyPhase, sentiment: SentimentAnalysisPhase, wrapUp: ReflectionWrapUpPhase) {
        self.preProcessPhase = PreprocessPhase()
        self.ontologyPhase = OntologyPhase()
        self.sentimentAnalysisPhase = NeuralSentimentAnalysisPhase()//SentimentAnalysisPhase(lexicon: AFINNLexicon())
        self.wrapUpPhase = ReflectionWrapUpPhase()
    }
    
    convenience init() {
		self.init(preProcess: PreprocessPhase(),
                  ontology: OntologyPhase(),
                  sentiment: NeuralSentimentAnalysisPhase(),
                  wrapUp: ReflectionWrapUpPhase())
    }
	
    func process(input: String) -> ReflectionAnalysis {
        guard !isProcessing else { return ReflectionAnalysis.empty() }
        isProcessing = true
        
        let preProcessOutput = preProcessPhase.process(input: input)
        let ontologyOutput = ontologyPhase.process(input: preProcessOutput)
        let sentimentAnalysisOutput = sentimentAnalysisPhase.process(input: ontologyOutput)
        let wrapUpOutput = wrapUpPhase.process(input: sentimentAnalysisOutput)
        
        isProcessing = false
        
        return wrapUpOutput
    }
}
