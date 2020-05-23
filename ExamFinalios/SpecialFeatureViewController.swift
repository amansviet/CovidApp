//
//  SpecialFeatureViewController.swift
//  ExamFinalios
//
//  Created by Amandeep Bhatia on 2020-04-18.
//  Copyright © 2020 Amandeep Bhatia. All rights reserved.
//

import UIKit
import Charts

class SpecialFeatureViewController: UIViewController {

    @IBOutlet weak var historicalDataSourceLink: UIButton!

    lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        //chartView.backgroundColor = UIColor.lightGray
        return chartView
    }()

    struct HistoricalGraphAPISchema:Codable {
     let cases: [String:Int]
     let deaths: [String:Int]
     let recovered: [String:Int]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(lineChartView)

        // This is an addtional API that will be used for special feature developed for requirement#10
        // API EndPoint to fetch last 7 days of data to fill the graph
        let urlGraphString = "https://corona.lmao.ninja/v2/historical/all?lastdays=7"
        fetchHistoricalGraphData(urlString: urlGraphString)
        historicalDataSourceLink.setTitle("Data Source : \(urlGraphString)", for: .normal)
        historicalDataSourceLink.setTitleColor(UIColor.systemPink, for: .normal)
    }

    @IBAction func historicalDataSourceTapAction(_ sender: Any) {
        if let url = URL(string: "https://corona.lmao.ninja/v2/historical/all?lastdays=7") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func fetchHistoricalGraphData(urlString: String) {
    var casesGraphData: [String:Int] = [:]
    var deathsGraphData: [String:Int] = [:]
    var recoveredGraphData: [String:Int] = [:]

    let urlSession = URLSession(configuration: .default)
    let urlRequest = URL(string: urlString)
    if let urlRequest = urlRequest {
        let dataTask = urlSession.dataTask(with: urlRequest) {
            (data, response, error) in
            if let data = data {
                let jsonDecoder = JSONDecoder()
                do {
                    let apiResponseData = try jsonDecoder.decode(HistoricalGraphAPISchema.self, from: data)
                        DispatchQueue.main.async {
                            casesGraphData = apiResponseData.cases
                            deathsGraphData = apiResponseData.deaths
                            recoveredGraphData = apiResponseData.recovered
                            self.setHistoricalGraphData(cases: casesGraphData, deaths: deathsGraphData, recovered: recoveredGraphData)
                        }
                    }
                    catch {
                        print("Something went wrong with the API request, try again")
                    }
                }
            }
            dataTask.resume()
        }
        else {
           print("Something went wrong with the API request, try again")
        }
    }

    func setHistoricalGraphData(cases: [String:Int], deaths: [String:Int], recovered: [String:Int]) {
        var confirmedCasesData: [ChartDataEntry] = []
        var deathsData: [ChartDataEntry] = []
        var recoveredData: [ChartDataEntry] = []

        var xAxis: Int = 1
        for (_, count) in cases {
            let dataEntry = ChartDataEntry(x: Double(xAxis), y: Double(count/100))
            confirmedCasesData.append(dataEntry)
            xAxis += 1
        }

        xAxis = 1
        for (_, count) in deaths {
            let dataEntry = ChartDataEntry(x: Double(xAxis), y: Double(count/100))
            deathsData.append(dataEntry)
            xAxis += 1
        }

        xAxis = 1
        for (_, count) in recovered {
            let dataEntry = ChartDataEntry(x: Double(xAxis), y: Double(count/100))
            recoveredData.append(dataEntry)
            xAxis += 1
        }

        let setConfirmedCases = LineChartDataSet(entries: confirmedCasesData, label: "Total Cases")
        let setDeaths = LineChartDataSet(entries: deathsData, label: "Total Deaths")
        let setRecovered = LineChartDataSet(entries: recoveredData, label: "Total Recovered")

        // Setup for the graph UI elements
        setConfirmedCases.circleColors = [UIColor.systemGray]
        setConfirmedCases.colors = [NSUIColor.systemGray]

        setDeaths.circleColors = [UIColor.systemPink]
        setDeaths.colors = [NSUIColor.systemPink]

        setRecovered.circleColors = [UIColor.green]
        setRecovered.colors = [NSUIColor.green]

        // Setup the linechart on the screen with UI params
        let data = LineChartData(dataSets: [setConfirmedCases,setDeaths,setRecovered])
        lineChartView.data = data
        lineChartView.legend.textColor = UIColor.black
        lineChartView.legend.font = UIFont(name: "Futura", size: 10)!
        lineChartView.centerInSuperview()
        lineChartView.width(to: view)
        lineChartView.heightToWidth(of: view)
        lineChartView.centerInSuperview()
        lineChartView.width(to: view)
        lineChartView.heightToWidth(of: view)
        lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }
}
