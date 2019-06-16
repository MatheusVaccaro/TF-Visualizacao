//
//  ViewController.swift
//  TF-Visualizacao
//
//  Created by Matheus Vaccaro on 07/06/19.
//  Copyright © 2019 Matheus Vaccaro. All rights reserved.
//

import UIKit
import Charts

class ViewController: UIViewController {
    
    private let wordSizer = WordSizer()
    private var agesData: AGESData!
    
    // Selected date range
    private var earliestDateSelection: Date!
    private var latestDateSelection: Date!

    let activities = ["Burger", "Steak", "Salad", "Pasta", "Pizza"]
    @IBOutlet weak var radarChartView: RadarChartView!
    @IBOutlet weak var barChartView: BarChartView!
    
    var lessonsLearnedWordCloudVC: WordCloudViewController!
    @IBOutlet weak var lessonsLearnedWordCloudContainerView: UIView!
    
    var problemsEncounteredWordCloudVC: WordCloudViewController!
    @IBOutlet weak var problemsEncounteredWordCloudContainerView: UIView!
    
    @IBOutlet weak var horizontalSlider: UISlider!
    
    lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
        
        setupSlider()
        
        configureRadarChart()
        setRadarChartData()
        
        configureBarChart()
        setBarChartData()
    
        setupWordClouds()
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
    
    @objc func refreshData() {
        let selectedReports = agesData.reports.filter { (report) -> Bool in
            return earliestDateSelection <= report.date && report.date <= latestDateSelection
        }
        print(selectedReports.count)
        
        wordSizer.reset()
        wordSizer.count(tokens: selectedReports.filter({ $0.type == .lessonsLearned }).flatMap({ $0.tokens }))
        lessonsLearnedWordCloudVC.setWords(wordSizer.spit())
        lessonsLearnedWordCloudVC.drawCloud()
        
        wordSizer.reset()
        wordSizer.count(tokens: selectedReports.filter({ $0.type == .problemsEncountered }).flatMap({ $0.tokens }))
        problemsEncounteredWordCloudVC.setWords(wordSizer.spit())
        problemsEncounteredWordCloudVC.drawCloud()
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
        let yVals = (0..<10).map { (i) -> BarChartDataEntry in
            let mult = UInt32(3)
            let val1 = Double(arc4random_uniform(mult) + mult / 3)
            let val2 = Double(arc4random_uniform(mult) + mult / 3)
            let val3 = Double(arc4random_uniform(mult) + mult / 3)

            return BarChartDataEntry(x: Double(i), yValues: [val1, val2, val3])
        }
        
//        let dataEntry = BarChartDataEntry(x: 0, yValues: [1, 2, 3])
        let dataSet = BarChartDataSet(entries: yVals, label: nil)
        dataSet.stackLabels = ["Negativo", "Neutro", "Positivo"]
        dataSet.colors = [ChartColorTemplates.material()[2], ChartColorTemplates.material()[1], ChartColorTemplates.material()[0]]
        
        let data = BarChartData(dataSet: dataSet)
        data.setValueFont(.systemFont(ofSize: 7, weight: .light))
        data.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        data.setValueTextColor(.white)
        
        barChartView.fitBars = true
        barChartView.data = data
    }
    
    @IBAction func didChangeSliderValue(_ sender: UISlider) {
		earliestDateSelection = agesData.earliestReportDate
        latestDateSelection = Date(timeIntervalSince1970: Double(sender.value))
    }
    
    
    func setupWordClouds() {
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
    
    func configureBarChart() {
        //        barChartView.delegate = self
        
        barChartView.chartDescription?.enabled = false
        barChartView.pinchZoomEnabled = true
        barChartView.autoScaleMinMaxEnabled = true
        
        barChartView.maxVisibleCount = 40
        barChartView.drawBarShadowEnabled = false
        barChartView.drawValueAboveBarEnabled = false
        barChartView.highlightFullBarEnabled = false
        
        let leftAxis = barChartView.leftAxis
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: formatter)
        leftAxis.axisMinimum = 0
        
        barChartView.rightAxis.enabled = false
        
        let xAxis = barChartView.xAxis
        xAxis.labelPosition = .bottom
        
        let l = barChartView.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .square
        l.formToTextSpace = 4
        l.xEntrySpace = 6
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
