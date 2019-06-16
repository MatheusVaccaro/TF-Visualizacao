//
//  ViewController.swift
//  TF-Visualizacao
//
//  Created by Matheus Vaccaro on 07/06/19.
//  Copyright © 2019 Matheus Vaccaro. All rights reserved.
//

import UIKit
import Charts
import SwiftChart

class ViewController: UIViewController {
    
    private let wordSizer = WordSizer()
    private var agesData: AGESData!
    
    // Selected date range
    private var earliestDateSelection: Date!
    private var latestDateSelection: Date!

    let activities = ["Burger", "Steak", "Salad", "Pasta", "Pizza"]
    @IBOutlet weak var radarChartView: RadarChartView!
    @IBOutlet weak var lineChart: Chart!
    
    var lessonsLearnedWordCloudVC: WordCloudViewController!
    @IBOutlet weak var lessonsLearnedWordCloudContainerView: UIView!
    
    var problemsEncounteredWordCloudVC: WordCloudViewController!
    @IBOutlet weak var problemsEncounteredWordCloudContainerView: UIView!
    
    @IBOutlet weak var horizontalSlider: UISlider!
    
    lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
        setupSlider()
        
        configureRadarChart()
        configureLineChart()
        configureWordClouds()
        
        refreshData()
    }
    
    @objc func refreshData() {
        // TODO: Filter by projects
        let selectedReports = agesData.reports.filter { (report) -> Bool in
            return earliestDateSelection <= report.date && report.date <= latestDateSelection
        }
        print("Selected \(selectedReports.count) weekly reports")
        
        wordSizer.reset()
        wordSizer.count(tokens: selectedReports.filter({ $0.type == .lessonsLearned }).flatMap({ $0.tokens }))
        lessonsLearnedWordCloudVC.setWords(wordSizer.spit())
        lessonsLearnedWordCloudVC.drawCloud()
        
        wordSizer.reset()
        wordSizer.count(tokens: selectedReports.filter({ $0.type == .problemsEncountered }).flatMap({ $0.tokens }))
        problemsEncounteredWordCloudVC.setWords(wordSizer.spit())
        problemsEncounteredWordCloudVC.drawCloud()
        
        let selectedCommits = agesData.commits.filter { (commit) -> Bool in
            return earliestDateSelection <= commit.date && commit.date <= latestDateSelection
        }
        print("Selected \(selectedCommits.count) commits")
        setLineChartData(commits: selectedCommits)
    }
    
    func setupData() {
        self.agesData = AGESDataLoader.parseAGESData()
        
    }
    
    func setupSlider() {
        horizontalSlider.minimumValue = Float(agesData.earliestReportDate.timeIntervalSince1970)
        horizontalSlider.maximumValue = Float(agesData.latestReportDate.timeIntervalSince1970)
        
        horizontalSlider.addTarget(self, action: #selector(refreshData), for: .touchCancel)
        horizontalSlider.addTarget(self, action: #selector(refreshData), for: .touchUpOutside)
        horizontalSlider.addTarget(self, action: #selector(refreshData), for: .touchUpInside)
    }
    
    func setLineChartData(commits: [AGESData.Commit]) {
        let aggregatedCommits = aggregate(commits: commits)
        
        var dataset = [ChartSeries]()
        for (_, weeks) in aggregatedCommits {
            let data = weeks.map({ ($0.key, Double($0.value)) }).sorted(by: { $0.0 < $1.0 })
            let series = ChartSeries(data: data)
            series.area = true
            series.color = .random
            
            dataset.append(series)
        }
        
        lineChart.removeAllSeries()
        lineChart.add(dataset)
        
        // Set x axis labels
        let xValues = dataset.flatMap({ $0.data }).map({ $0.x })
        if let min = xValues.min(), let max = xValues.max() {
            lineChart.xLabels = (Int(min)...Int(max)).map({ Double($0) })
        }
    }
    
    typealias Week = Int
    typealias Count = Int
    private func aggregate(commits: [AGESData.Commit]) -> [Name: [Week: Count]] {
        var aggregatedCommits: [Name: [Int: Int]] = [:]
        commits.forEach({ aggregatedCommits[$0.projectName] = [:] })
        for commit in commits {
            let week = Calendar.current.component(.weekOfYear, from: commit.date)
            aggregatedCommits[commit.projectName]![week] = 1 + (aggregatedCommits[commit.projectName]![week] ?? 1)
        }
        return aggregatedCommits
    }
    
    func setRadarChartData() {
        let mult: UInt32 = 80
        let min: UInt32 = 20
        let cnt = 5
        
        let block: (Int) -> RadarChartDataEntry = { _ in return RadarChartDataEntry(value: Double(arc4random_uniform(mult) + min))}
        let entries1 = (0..<cnt).map(block)
        let entries2 = (0..<cnt).map(block)
        
        let set1 = RadarChartDataSet(entries: entries1, label: "Last Week")
        set1.setColor(UIColor(red: 103/255, green: 110/255, blue: 129/255, alpha: 1))
        set1.fillColor = UIColor(red: 103/255, green: 110/255, blue: 129/255, alpha: 1)
        set1.drawFilledEnabled = true
        set1.fillAlpha = 0.7
        set1.lineWidth = 2
        set1.drawHighlightCircleEnabled = true
        set1.setDrawHighlightIndicators(false)
        
        let set2 = RadarChartDataSet(entries: entries2, label: "This Week")
        set2.setColor(UIColor(red: 121/255, green: 162/255, blue: 175/255, alpha: 1))
        set2.fillColor = UIColor(red: 121/255, green: 162/255, blue: 175/255, alpha: 1)
        set2.drawFilledEnabled = true
        set2.fillAlpha = 0.7
        set2.lineWidth = 2
        set2.drawHighlightCircleEnabled = true
        set2.setDrawHighlightIndicators(false)
        
        let data = RadarChartData(dataSets: [set1, set2])
        data.setValueFont(.systemFont(ofSize: 8, weight: .light))
        data.setDrawValues(false)
        data.setValueTextColor(.white)
        
        radarChartView.data = data
    }
    
    func setBarChartData() {
//        let yVals = (0..<10).map { (i) -> BarChartDataEntry in
//            let mult = UInt32(3)
//            let val1 = Double(arc4random_uniform(mult) + mult / 3)
//            let val2 = Double(arc4random_uniform(mult) + mult / 3)
//            let val3 = Double(arc4random_uniform(mult) + mult / 3)
//
//            return BarChartDataEntry(x: Double(i), yValues: [val1, val2, val3])
//        }
//
////        let dataEntry = BarChartDataEntry(x: 0, yValues: [1, 2, 3])
//        let dataSet = BarChartDataSet(entries: yVals, label: nil)
//        dataSet.stackLabels = ["Negativo", "Neutro", "Positivo"]
//        dataSet.colors = [ChartColorTemplates.material()[2], ChartColorTemplates.material()[1], ChartColorTemplates.material()[0]]
//
//        let data = BarChartData(dataSet: dataSet)
//        data.setValueFont(.systemFont(ofSize: 7, weight: .light))
//        data.setValueFormatter(DefaultValueFormatter(formatter: formatter))
//        data.setValueTextColor(.white)
//
//        barChartView.fitBars = true
//        barChartView.data = data
    }
    
    @IBAction func didChangeSliderValue(_ sender: UISlider) {
		earliestDateSelection = agesData.earliestReportDate
        latestDateSelection = Date(timeIntervalSince1970: Double(sender.value))
    }
    
    
    func configureWordClouds() {
        self.lessonsLearnedWordCloudVC = WordCloudViewController()
        addChild(lessonsLearnedWordCloudVC)
        lessonsLearnedWordCloudContainerView.addSubview(lessonsLearnedWordCloudVC.view)
        lessonsLearnedWordCloudVC.view.constrainedExpansion(inside: lessonsLearnedWordCloudContainerView)
        lessonsLearnedWordCloudVC.didMove(toParent: self)
        
        self.problemsEncounteredWordCloudVC = WordCloudViewController()
        problemsEncounteredWordCloudVC.shouldUseRed = true
        addChild(problemsEncounteredWordCloudVC)
        problemsEncounteredWordCloudContainerView.addSubview(problemsEncounteredWordCloudVC.view)
        problemsEncounteredWordCloudVC.view.constrainedExpansion(inside: problemsEncounteredWordCloudContainerView)
        problemsEncounteredWordCloudVC.didMove(toParent: self)
    }
    
    func configureLineChart() {
        lineChart.maxY = 60
        lineChart.lineWidth = 2
        lineChart.labelFont = UIFont.systemFont(ofSize: 10)
        lineChart.xLabels = (32...48).map({ Double($0) })
//        //        barChartView.delegate = self
//
//        barChartView.chartDescription?.enabled = false
//        barChartView.pinchZoomEnabled = true
//        barChartView.autoScaleMinMaxEnabled = true
//
//        barChartView.maxVisibleCount = 40
//        barChartView.drawBarShadowEnabled = false
//        barChartView.drawValueAboveBarEnabled = false
//        barChartView.highlightFullBarEnabled = false
//
//        let leftAxis = barChartView.leftAxis
//        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: formatter)
//        leftAxis.axisMinimum = 0
//
//        barChartView.rightAxis.enabled = false
//
//        let xAxis = barChartView.xAxis
//        xAxis.labelPosition = .bottom
//
//        let l = barChartView.legend
//        l.horizontalAlignment = .right
//        l.verticalAlignment = .bottom
//        l.orientation = .horizontal
//        l.drawInside = false
//        l.form = .square
//        l.formToTextSpace = 4
//        l.xEntrySpace = 6
    }
    
    func configureRadarChart() {
        radarChartView.delegate = self
        
        radarChartView.chartDescription?.enabled = false
        radarChartView.webLineWidth = 1
        radarChartView.innerWebLineWidth = 1
        radarChartView.webColor = .lightGray
        radarChartView.innerWebColor = .lightGray
        radarChartView.webAlpha = 1
        radarChartView.rotationEnabled = false
        
        //        let marker = RadarMarkerView.viewFromXib()!
        //        marker.chartView = chartView
        //        chartView.marker = marker
        
        let xAxis = radarChartView.xAxis
        xAxis.labelFont = .systemFont(ofSize: 9, weight: .light)
        xAxis.xOffset = 0
        xAxis.yOffset = 0
        xAxis.valueFormatter = self
        //        xAxis.labelTextColor = .white
        
        let yAxis = radarChartView.yAxis
        yAxis.labelFont = .systemFont(ofSize: 9, weight: .light)
        yAxis.labelCount = 5
        yAxis.axisMinimum = -80
        yAxis.axisMaximum = 80
        yAxis.drawLabelsEnabled = true
        
        let l = radarChartView.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .top
        l.orientation = .horizontal
        l.drawInside = false
        l.font = .systemFont(ofSize: 10, weight: .light)
        l.xEntrySpace = 7
        l.yEntrySpace = 5
        //        l.textColor = .white
    }
}

extension ViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return activities[Int(value) % activities.count]
    }
}

extension ViewController: ChartViewDelegate {
    
}
