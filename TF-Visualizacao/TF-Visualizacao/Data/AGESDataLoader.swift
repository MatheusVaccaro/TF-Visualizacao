//
//  AGESDataParser.swift
//  TF-Visualizacao
//
//  Created by Max Zorzetti on 14/06/19.
//  Copyright © 2019 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CSV

class AGESDataLoader {
    
    static let agesDataFilename = "ages-weekly_reports"
    static let commitDataFilename = "ages-student_commits"
    static let dataFiletype = "csv"
    
    static func parseAGESData() -> AGESData {
        let agesData = retrieveDataFromDisk() ?? processRawData()
//        let agesData = processRawData()
        
        print("Loaded the following data:\n\(agesData)")
        
        return agesData
    }
    
    static func processRawData() -> AGESData {
        let agesData = AGESData()

        processWeeklyReportData(into: agesData)
        processCommitData(into: agesData)
        
        writeToDisk(agesData)
        
        return agesData
    }
    
    private static func processWeeklyReportData(into agesData: AGESData) {
        print("Attempting to parse and process AGES data from CSV file.")
        guard let path = Bundle.main.path(forResource: AGESDataLoader.agesDataFilename,
                                          ofType: AGESDataLoader.dataFiletype) else {
                                            fatalError("AGESData file not found.")
        }
        
        guard let rawData = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            fatalError("Failed to load AGES data.")
        }
        
        guard let csv = try? CSVReader(stream: InputStream(data: rawData),
                                       hasHeaderRow: true, trimFields: false, delimiter: ",") else {
                                        fatalError("Error parsing AGES data.")
        }
        
        print("Began parsing weekly report data.")
        print("Reports are being tokenized and having their sentiment analyzed.")
        
        while csv.next() != nil {
            // Create or find existing project by name
            let projectName = csv["project_name"]!
            let project = agesData.projectStore[projectName] ?? AGESData.Project(name: projectName)
            agesData.projectStore[projectName] = project
            
            // Create or find existing student by name
            let studentName = csv["name"]!
            let studentEmail = csv["email"]!
            let student = project.students[studentEmail]
                ?? AGESData.Student(name: studentName, email: studentEmail)
            project.students[studentEmail] = student
            
            // Parse content type
            let content = csv["content"]!
            let contentType = AGESData.Report.ReportType.from(csv["title"]!)
            let turnInDate = Date.from(string: csv["turn_in_date"]!)
            
            let report = AGESData.Report(content: content, projectName: projectName, type: contentType, date: turnInDate)
            student.reports.append(report)
        }
        
        print("Finished weekly report parsing data")
    }
    
    private static func processCommitData(into agesData: AGESData) {
        print("Attempting to parse and process commit data from CSV file.")
        guard let path = Bundle.main.path(forResource: AGESDataLoader.commitDataFilename,
                                          ofType: AGESDataLoader.dataFiletype) else {
                                            fatalError("Commit data file not found.")
        }
        
        guard let rawData = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            fatalError("Failed to load commit data.")
        }
        
        guard let csv = try? CSVReader(stream: InputStream(data: rawData),
                                       hasHeaderRow: true, trimFields: true, delimiter: ",") else {
                                        fatalError("Error parsing commit data.")
        }
        
        // Building one huge dic of students
        let students = agesData.projects.reduce([:]) { (students, project) -> [Name: AGESData.Student] in
        	students.merging(project.students, uniquingKeysWith: { $1 })
        }
        
        print("Began parsing commit data.")
        
        while csv.next() != nil {
            
            let email = csv["email"]!
            let date = Date.from(altString: csv["date"]!)
            let project = csv["project_name"]!
            
            let commit = AGESData.Commit(date: date, authorEmail: email, projectName: project)
            
            if let student = students[email] {
                student.commits.append(commit)
            }
        }
    }
    
    /// Disk Storage
    
    static let processedAGESDataFile = "processedAGESData.json"
    
    private static func writeToDisk(_ data: AGESData) {
        print("Writing processed AGES data to disk as JSON.")
        
        let jsonEncoder = JSONEncoder()
        let agesJSON = try! jsonEncoder.encode(data)
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(processedAGESDataFile)
            
            // Writing
            do {
                try agesJSON.write(to: fileURL, options: .atomicWrite)
            }
            catch {/* error handling here */}
        }
    }
    
    private static let jsonError = "Failed to retrieve processed JSON AGES data from disk."
    
    private static func retrieveDataFromDisk() -> AGESData? {
        print("Retrieving JSON AGES data from disk.")
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(processedAGESDataFile)
            
            do {
                let agesJSON = try Data(contentsOf: fileURL)
                let agesData = try JSONDecoder().decode(AGESData.self, from: agesJSON)
                
                return agesData
            } catch {
                print(jsonError)
                print(error.localizedDescription)
                return nil
            }
        }
		print(jsonError)
        
        return nil
    }
}
