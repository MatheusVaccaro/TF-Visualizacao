//
//  AGESData.swift
//  TF-Visualizacao
//
//  Created by Max Zorzetti on 14/06/19.
//  Copyright © 2019 Matheus Vaccaro. All rights reserved.
//

import Foundation

typealias Name = String
typealias Email = String

class AGESData: Codable, CustomStringConvertible {

    var description: String { projects.reduce("", { "\($0)\n\($1)" }) }
    
    var projectStore: [Name: Project] = [:]

    lazy var projects: [Project] = { return Array(projectStore.values) }()
    lazy var reports: [Report] = { return projectStore.values.flatMap({ $0.students.values }).flatMap({ $0.reports }) }()
    lazy var earliestReportDate: Date = { return reports.reduce(Date(), { $1.date < $0 ? $1.date : $0 }) }()
    lazy var latestReportDate: Date = { return reports.reduce(Date.zero, { $1.date > $0 ? $1.date : $0 }) }()
        
    class Project: Codable, CustomStringConvertible {
        var description: String { "\(name)\(students.values.reduce("", {"\($0)\n\t\($1)"}))" }
        
        let name: String
        var students: [Email: Student] = [:]
        
        init(name: String) {
            self.name = name
        }
    }
    
    class Student: Codable, CustomStringConvertible {
        var description: String { "\(name) - \(reports.count) reports - \(commits.count) commits" }
        let name: String
        let email: String
        var reports: [Report] = []
        var commits: [Commit] = []
        
        init(name: String, email: String) {
            self.name = name
            self.email = email
        }
    }
    
    class Report: Codable, CustomStringConvertible {
        var description: String { type.description }
        let content: String
        let type: ReportType
        let date: Date
        
        let tokens: [Token]
        
        init(content: String, type: ReportType, date: Date) {
            self.content = content
            self.type = type
            self.date = date
            
            self.tokens = Tokenizer.shared.process(input: content)
        }
        
        enum ReportType: String, Codable, CustomStringConvertible {
            var description: String { rawValue }
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
    
    struct Commit: Codable {
        let date: Date
        let authorEmail: String
    }
}

