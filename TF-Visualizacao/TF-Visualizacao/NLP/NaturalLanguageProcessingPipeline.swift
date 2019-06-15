//
//  NaturalLanguageProcessingPipeline.swift
//  Reflection
//
//  Created by Max Zorzetti on 21/05/19.
//  Copyright © 2019 Alice Wiener. All rights reserved.
//

import Foundation

protocol NaturalLanguageProcessingPipeline {
    associatedtype NLPInput
    associatedtype NLPOutput
    func process(input: NLPInput) -> NLPOutput
}

protocol NLPPhase {
    associatedtype NLPPhaseInput: Traceable
    associatedtype NLPPhaseOutput: Traceable
    func process(input: NLPPhaseInput) -> NLPPhaseOutput
}

extension NLPPhase {
    func process(input: NLPPhaseInput) -> NLPPhaseOutput {
        fatalError()
    }
}
//
//protocol NLPInput {
//
//}
//
//protocol NLPOutput {
//
//}
//
//protocol NLPPhaseInput {
//
//}
//
//protocol NLPPhaseOutput {
//
//}
