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
    
    @IBOutlet weak var questionDescription: UILabel!
    @IBOutlet weak var questionTitle: UILabel!
    
    @IBOutlet weak var noNbr: UILabel!
    @IBOutlet weak var yesNbr: UILabel!
    
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
        var nbrAnswers = [0.0, 0.0]
        
        do {
            try QuestionsApiController.sharedInstance.getQuestionDetails(questionId) { (details: [String:AnyObject]?, err: ApiError?) in
                if (err == nil && details != nil) {
                    if let q = details!["question"] as? Question {
                        self.questionTitle.text = q.title
                        self.questionDescription?.text = q.description
                    }
                    if let answers = details!["answers"] as? [Answer] {
                        for answer in answers {
                            if answer.answer == "YES" {
                                nbrAnswers[0] += 1;
                            } else {
                                nbrAnswers[1] += 1;
                            }
                        }
                    }
                    self.yesNbr.text = "(" + String(Int(nbrAnswers[0])) + ")"
                    self.noNbr.text = "(" + String(Int(nbrAnswers[1])) + ")"
                    self.setChart(self.answers, values: nbrAnswers)
                }
                else {
                    print("err: \(err)")
                }
            }
            
        } catch let error as ApiError {
            print("error: \(error)")
        } catch {
            print("Unexpected error")
        }
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
        barChartView.animate(xAxisDuration: 1.5, yAxisDuration: 1.5)
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
