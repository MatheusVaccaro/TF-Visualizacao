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
    static let agesDataFiletype = "csv"
    
    static func parseAGESData() -> AGESData {
        let agesData = retrieveDataFromDisk() ?? processRawData()
        
        return agesData
    }
    
    static func processRawData() -> AGESData {
        print("Attempting to parse and process AGES data from CSV file.")
        guard let path = Bundle.main.path(forResource: AGESDataLoader.agesDataFilename,
                                          ofType: AGESDataLoader.agesDataFiletype) else {
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
        print("Began parsing data")
        
        while csv.next() != nil {
            // Create or find existing project by name
            let projectName = csv["project_name"]!
            let project = agesData.projectStore[projectName] ?? AGESData.Project(name: projectName)
            agesData.projectStore[projectName] = project
            
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
        
        print("Finished parsing data")
        
        writeToDisk(agesData)
        
        return agesData
    }
    
    static let processedAGESDataFile = "processedAGESData.json"
    
    static func writeToDisk(_ data: AGESData) {
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
    
    static let jsonError = "Failed to retrieve processed JSON AGES data from disk."
    
    static func retrieveDataFromDisk() -> AGESData? {
        print("Retrieving JSON AGES data from disk.")
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(processedAGESDataFile)
            
            do {
                let agesJSON = try Data(contentsOf: fileURL)
                let agesData = try JSONDecoder().decode(AGESData.self, from: agesJSON)
                
                print("Retrieved the following data:\n\(agesData)")
                
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
