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

    lazy var projects: [Project] = { return Array(projectStore.values).sorted(by: { $0.name < $1.name}) }()
    
    lazy var reports: [Report] = { return projects.flatMap({ $0.reports }) }()
    lazy var earliestReportDate: Date = { return reports.reduce(Date(), { $1.date < $0 ? $1.date : $0 }) }()
    lazy var latestReportDate: Date = { return reports.reduce(Date.zero, { $1.date > $0 ? $1.date : $0 }) }()
    
    lazy var commits: [Commit] = { return projects.flatMap({ $0.students.values }).flatMap({ $0.commits }) }()
    lazy var earliestCommitDate: Date = { return commits.reduce(Date(), { $1.date < $0 ? $1.date : $0 }) }()
    lazy var latestCommitDate: Date = { return commits.reduce(Date.zero, { $1.date > $0 ? $1.date : $0 }) }()
    
    
    
    // MARK: - Project
    class Project: Codable, CustomStringConvertible, Hashable {

        var description: String { "\(name)\(students.values.reduce("", {"\($0)\n\t\($1)"}))" }
        
        let name: String
        var students: [Email: Student] = [:]
        
        lazy var reports: [Report] = { students.values.flatMap({ $0.reports }) }()
        
        init(name: String) {
            self.name = name
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }
        
        static func == (lhs: AGESData.Project, rhs: AGESData.Project) -> Bool {
            lhs.name == rhs.name
        }
    }
    
    
    
    // MAKK: - Student
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
    
    
    
    // MAKK: - Report
    class Report: Codable, CustomStringConvertible {
        var description: String { type.description }
        
        let content: String
        let projectName: String
        let type: ReportType
        let date: Date
        let sentimentScore: Double
        
        let tokens: [Token]
        
        init(content: String, projectName: String, type: ReportType, date: Date) {
            self.content = content
            self.type = type
            self.date = date
            self.projectName = projectName
            
            self.tokens = Tokenizer.shared.process(input: content)
            self.sentimentScore = NeuralSentimentAnalysis.shared.process(input: content)
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
    
    
    
    // MAKK: - Commit
    struct Commit: Codable {
        let date: Date
        let authorEmail: Email
        let projectName: Name
    }
}

