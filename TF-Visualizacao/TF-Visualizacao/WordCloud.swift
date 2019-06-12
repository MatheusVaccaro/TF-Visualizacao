//
//  WordCloud.swift
//  TF-Visualizacao
//
//  Created by Max Zorzetti on 11/06/19.
//  Copyright © 2019 Matheus Vaccaro. All rights reserved.
//

import CoreGraphics

typealias Frequency = Int
typealias SpiralFunction = (Int) -> CGPoint

class WordCloudGenerator {
    
    var spiralFunction: SpiralFunction
    
    init(spiralFunction: @escaping SpiralFunction = SpiralFunctions.archimedes(_:) ) {
        self.spiralFunction = spiralFunction
        
        //𝑥2+𝑦2=𝑘2(arctan(𝑦𝑥)−𝜃𝑜)2
        
    }
    
    func generateWordCloud(using words: [(Word, Frequency)]) -> [(Word, CGPoint)] {
    	var settledWords = [(Word, CGPoint)]()
        
        for (word, frequency) in words {
            var hasSettled: Bool
            var pos: CGPoint
            var iteration = 0
            
            repeat {
                pos = position(for: word, ofFrequency: frequency, andInteration: iteration)
                hasSettled = true
                
                for (settledWord, _) in settledWords {
                    if word.hitTest(settledWord) {
                        hasSettled = false
                        break
                    }
                }
                iteration += 1
                
            } while !hasSettled
            
            settledWords.append((word, pos))
        }
        
        return settledWords
    }
    
    private func position(for word: Word, ofFrequency frequency: Frequency, andInteration: Int) -> CGPoint {
        return .zero
    }
    
    private func settle(word: Word) {
        
    }
    
}

struct SpiralFunctions {
    static func archimedes(_ x: Int) -> CGPoint {
//        let x = CGFloat(x)
//        𝑥2+𝑦2=𝑘2(arctan(𝑦𝑥)−𝜃𝑜)2
//        int pos = margin + i * spacing;
//        int size = w - (2 * margin + i * 2 * spacing);
//        g.drawOval(pos, pos, size, size);
//        
//        double ia = i * angle;
//        int x2 = center + (int) (cos(ia) * (w - 2 * margin) / 2);
//        int y2 = center - (int) (sin(ia) * (w - 2 * margin) / 2);
        
        
        return .zero
    }
}

protocol Word {
    func hitTest(_ word: Word) -> Bool
}
