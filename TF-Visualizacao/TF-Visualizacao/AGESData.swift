//
//  AGESData.swift
//  TF-Visualizacao
//
//  Created by Max Zorzetti on 14/06/19.
//  Copyright © 2019 Matheus Vaccaro. All rights reserved.
//

import Foundation

typealias Name = String

class AGESData {
    
    var projects: [Name: Project] = [:]
    
    class Project {
        let name: String
        var students: [Name: Student] = [:]
        
        init(name: String) {
            self.name = name
        }
    }
    
    class Student {
        let name: String
        var reports: [Report] = []
        var commits: [Commit] = []
        
        init(name: String) {
            self.name = name
        }
    }
    
    struct Report {
        let content: String
        let type: ReportType
        let date: Date
        
        enum ReportType {
            case problemsEncountered
            case lessonsLearned
            case negligible
            
            static func from(_ type: String) -> ReportType {
                switch type {
                case "Lições aprendidas":		return .lessonsLearned
                case "Problemas Encontrados":	return .problemsEncountered
                default:						return .negligible
                }
            }
        }
    }
    
    struct Commit {
        let date: Date
    }
}

