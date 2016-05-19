//
//  AnswerDetailsViewController.swift
//  yn
//
//  Created by Julie FRANEL on 5/18/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import UIKit
import Charts

class AnswerDetailsViewController: UIViewController {
    
    @IBOutlet weak var barChartView: BarChartView!
    var questionId = Int()
    var answers = ["Yes", "No"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadData() {
        // get question details
        let nbrAnswers = [20.0, 4.0]
        setChart(answers, values: nbrAnswers)
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        barChartView.noDataText = "You need to provide data for the chart."
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Asked person")
        //chartDataSet.colors = ChartColorTemplates.joyful()
        chartDataSet.colors = [UIColor(red: 121/255, green: 181/255, blue: 145/255, alpha: 1), UIColor(red: 214/255, green: 96/255, blue: 96/255, alpha: 1)]
        
        let chartData = BarChartData(xVals: answers, dataSet: chartDataSet)
        chartData.setDrawValues(false)
        
        barChartView.data = chartData
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        barChartView.descriptionText = ""
        
        barChartView.leftAxis.drawGridLinesEnabled = false
        barChartView.leftAxis.drawAxisLineEnabled = false
        barChartView.leftAxis.drawLabelsEnabled = false
        
        barChartView.rightAxis.drawGridLinesEnabled = false
        barChartView.rightAxis.drawAxisLineEnabled = false
        barChartView.rightAxis.drawLabelsEnabled = false
        
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.drawAxisLineEnabled = false
        barChartView.xAxis.drawLabelsEnabled = false
        
        barChartView.drawValueAboveBarEnabled = false
        
        barChartView.legend.enabled = false
    }

}
