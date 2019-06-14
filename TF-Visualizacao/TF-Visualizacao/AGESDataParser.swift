//
//  AGESDataParser.swift
//  TF-Visualizacao
//
//  Created by Max Zorzetti on 14/06/19.
//  Copyright © 2019 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CSV

class AGESDataParser {
    
    static let agesDataFilename = "ages-weekly_reports"
    static let agesDataFiletype = "csv"
    
    static func parseAGESData() -> AGESData {
        guard let path = Bundle.main.path(forResource: AGESDataParser.agesDataFilename,
                                          ofType: AGESDataParser.agesDataFiletype) else {
            fatalError("AGESData file not found.")
        }
        
        guard let rawData = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            fatalError("Failed to load AGES data.")
        }

        guard let csv = try? CSVReader(stream: InputStream(data: rawData),
                                       hasHeaderRow: true, trimFields: false, delimiter: ",") else {
            fatalError("Error parsing AGES data.")
        }
        
        let agesData = AGESData()
        
        while csv.next() != nil {
            // Create or find existing project by name
            let projectName = csv["project_name"]!
            let project = agesData.projects[projectName] ?? AGESData.Project(name: projectName)
            agesData.projects[projectName] = project
            
            // Create or find existing student by name
            let studentName = csv["name"]!
            let student = project.students[studentName] ?? AGESData.Student(name: studentName)
            project.students[studentName] = student
            
            // Parse content type
            let content = csv["content"]!
            let contentType = AGESData.Report.ReportType.from(csv["type"]!)
            let turnInDate = Date.from(string: csv["turn_in_date"]!)
            
            let report = AGESData.Report(content: content, type: contentType, date: turnInDate)
            student.reports.append(report)
        }
        
        return agesData
    }
}
