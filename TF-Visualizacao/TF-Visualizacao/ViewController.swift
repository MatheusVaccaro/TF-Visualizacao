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
import RangeSeekSlider

class ViewController: UIViewController {
    
    private let wordSizer = WordSizer()
    private var agesData: AGESData!
    
    // Data selection
    private var selectedProjects: [Name] = []
    private var selectionEarlyDate: Date!
    private var selectionLateDate: Date!

    @IBOutlet weak var radarChartView: RadarChartView!
    @IBOutlet weak var lineChart: Chart!
    
    var lessonsLearnedWordCloudVC: WordCloudViewController!
    @IBOutlet weak var lessonsLearnedWordCloudContainerView: UIView!
    
    var problemsEncounteredWordCloudVC: WordCloudViewController!
    @IBOutlet weak var problemsEncounteredWordCloudContainerView: UIView!
    
    @IBOutlet weak var slider: RangeSeekSlider!
    
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
    // MARK: - Data
    @objc func refreshData() {
        let projects = agesData.projects.filter({ selectedProjects.contains($0.name) })
        
        let selectedReports = projects
            .flatMap({ $0.students.values }).flatMap({ $0.reports })
            .filter({ selectionEarlyDate <= $0.date && $0.date <= selectionLateDate })
        
        let selectedCommits = projects
        	.flatMap({ $0.students.values }).flatMap({ $0.commits })
            .filter({ selectionEarlyDate <= $0.date && $0.date <= selectionLateDate })
        
        setRadarChartData(reports: selectedReports)
        setWordCloudData(reports: selectedReports)
        setLineChartData(commits: selectedCommits)
    }
    
    func setupData() {
        self.agesData = AGESDataLoader.parseAGESData()
        
        selectionEarlyDate = agesData.earliestReportDate
        selectionLateDate = agesData.latestReportDate
        selectedProjects = agesData.projects.map({ $0.name })
    }
    
    // MARK: - Slider
    func setupSlider() {
		slider.delegate = self
        slider.minValue = CGFloat(agesData.earliestReportDate.timeIntervalSince1970)
        slider.maxValue = CGFloat(agesData.latestReportDate.timeIntervalSince1970)
        slider.selectedMinValue = slider.minValue
        slider.selectedMaxValue = slider.maxValue
        
        slider.tintColor = .gray
        
        let baseColor = App.detailColor
        slider.minLabelColor = baseColor
        slider.maxLabelColor = baseColor
        slider.colorBetweenHandles = baseColor
        slider.handleColor = baseColor
        
        slider.numberFormatter = NumberDateFormatter()
        
        slider.addTarget(self, action: #selector(refreshData), for: .touchCancel)
        slider.addTarget(self, action: #selector(refreshData), for: .touchUpOutside)
        slider.addTarget(self, action: #selector(refreshData), for: .touchUpInside)
    }
    
    // MARK: - Line Chart
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
    
    func configureLineChart() {
        lineChart.maxY = 60
        lineChart.lineWidth = 2
        lineChart.labelFont = UIFont.systemFont(ofSize: 10)
        lineChart.xLabels = (32...48).map({ Double($0) })
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM"
        
        lineChart.xLabelsFormatter = {
            let components = DateComponents(weekOfYear: Int($1), yearForWeekOfYear: 2019)
            let date = Calendar.current.date(from: components)
            let weekString = dateFormatter.string(from: date!)
            
            return weekString
        }
    }

    /// Aggregate commit records into weeks, categorized by projects.
    /// - Parameter commits: commits to be aggregated
    private func aggregate(commits: [AGESData.Commit]) -> [Name: [Week: Count]] {
        var aggregatedCommits: [Name: [Week: Count]] = [:]
        commits.forEach({ aggregatedCommits[$0.projectName] = [:] }) // Initialize dics
        
        for commit in commits {
            let week = Calendar.current.component(.weekOfYear, from: commit.date)
            aggregatedCommits[commit.projectName]![week] = 1 + (aggregatedCommits[commit.projectName]![week] ?? 1)
        }
        
        return aggregatedCommits
    }
    typealias Week = Int
    typealias Count = Int
    
    // MARK: - Word clouds
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
    
    func setWordCloudData(reports: [AGESData.Report]) {
        wordSizer.reset()
        wordSizer.count(tokens: reports.filter({ $0.type == .lessonsLearned }).flatMap({ $0.tokens }))
        lessonsLearnedWordCloudVC.setWords(wordSizer.spit())
        lessonsLearnedWordCloudVC.drawCloud()
        
        wordSizer.reset()
        wordSizer.count(tokens: reports.filter({ $0.type == .problemsEncountered }).flatMap({ $0.tokens }))
        problemsEncounteredWordCloudVC.setWords(wordSizer.spit())
        problemsEncounteredWordCloudVC.drawCloud()
    }
    
    // MARK: - Radar Chart
    func setRadarChartData(reports: [AGESData.Report]) {
        var aggregatedReports: [Name: [AGESData.Report]] = [:]
        reports.forEach({ aggregatedReports[$0.projectName] = [] })
        reports.forEach({ aggregatedReports[$0.projectName]!.append($0) })
        
        var entries = [RadarChartDataEntry]()
        for (_, reports) in aggregatedReports {
            let score = reports.map({ $0.sentimentScore }).reduce(0, +) / Double(reports.count)
            let adjustedScore = pow(score, 2) * 2
            entries.append(RadarChartDataEntry(value: adjustedScore))
        }
        
        let set1 = RadarChartDataSet(entries: entries, label: "Escore de Sentimento")
        set1.setColor(App.detailColor.lighter())
        set1.fillColor = App.detailColor
        set1.drawFilledEnabled = true
        set1.fillAlpha = 0.7
        set1.lineWidth = 2
        set1.drawHighlightCircleEnabled = true
        set1.setDrawHighlightIndicators(false)
        
        let data = RadarChartData(dataSets: [set1])
        data.setValueFont(.systemFont(ofSize: 8, weight: .light))
        data.setDrawValues(false)
        data.setValueTextColor(.white)
        
        radarChartView.yAxis.axisMinimum = -1
        radarChartView.yAxis.axisMaximum = 1
        radarChartView.yAxis.drawTopYLabelEntryEnabled = false
        
        radarChartView.data = data
        
        radarChartView.animate(xAxisDuration: 1.4, yAxisDuration: 1.4, easingOption: .easeOutBack)
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
//        radarChartView.chartYMax = 1
        
        let xAxis = radarChartView.xAxis
        xAxis.labelFont = .systemFont(ofSize: 9, weight: .light)
        xAxis.xOffset = 0
        xAxis.yOffset = 0
        xAxis.valueFormatter = self
        //        xAxis.labelTextColor = .white
        
        let yAxis = radarChartView.yAxis
        yAxis.labelFont = .systemFont(ofSize: 9, weight: .light)
        yAxis.labelCount = 3
        yAxis.axisMinimum = -1
        yAxis.axisMaximum = 1
        yAxis.drawLabelsEnabled = true
        yAxis.maxWidth = 500
        
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

extension ViewController: RangeSeekSliderDelegate {
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        selectionEarlyDate = Date(timeIntervalSince1970: Double(slider.selectedMinValue))
        selectionLateDate = Date(timeIntervalSince1970: Double(slider.selectedMaxValue))
    }
}

extension ViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return agesData.projects[Int(value) % agesData.projects.count].name
    }
}

extension ViewController: ChartViewDelegate {
    
}
