//
//  ViewController.swift
//  ExamFinalios
//
//  Created by Amandeep Bhatia on 2020-04-18.
//  Copyright © 2020 Amandeep Bhatia. All rights reserved.
//

import UIKit
import Charts
import CoreLocation
import TinyConstraints

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var deathCases: UILabel!
    @IBOutlet weak var recoveredCases: UILabel!
    @IBOutlet weak var totalCases: UILabel!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var percentRecovered: UILabel!
    @IBOutlet weak var percentDeaths: UILabel!
    @IBOutlet weak var CurrentLocationTextView: UITextView!
    @IBOutlet weak var userLocationTotalCasesCount: UILabel!
    @IBOutlet weak var userLocationRecoveredCasesCount: UILabel!
    @IBOutlet weak var userLocationTotalDeathCount: UILabel!
    @IBOutlet weak var userLocationCountryName: UILabel!

    var apiResponseData: CovidAPISchema! = nil
    var locationManager = CLLocationManager()
    var currentLattitude = 0.0 // Default location to begin with, will be replaced with user's location on app launch
    var currentLongitude = 0.0 // Default location to begin with, will be replaced with user's location on app launch
    var currentLocation : CLLocation?
    var userNearestCountry = ""
    var userNearestCountryTotal = 0
    var userNearestCountryRecoveredTotal = 0
    var userNearestCountryDeathsTotal = 0
    var searchCountry : String = "";
    var totalConfirmed: Int = 0
    var totalRecovered: Int = 0
    var totalDeaths: Int = 0
    var pctRecovered: Double = 0.0
    var pctDeaths: Double = 0.0

    // Defined structure to match with the Covid API response
    // Here is the API https://www.bing.com/covid/data
    struct CovidAPISchema:Codable {
        let displayName: String
        let totalConfirmed: Int
        let totalRecovered: Int
        let totalDeaths: Int
        let areas: Array<CovidAPISchemaAreas>
    }

    struct CovidAPISchemaAreas:Codable {
        let displayName: String
        let id: String
        let lat: Double
        let long: Double
        let areas: Array<CovidAPISchemaCountryArea>
        let totalRecovered: Int?
        let totalDeaths: Int?
        let totalConfirmed: Int?
    }

    struct CovidAPISchemaCountryArea:Codable {
        let lat: Double
        let long: Double
        let displayName: String
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        currentLattitude = locValue.latitude
        currentLongitude = locValue.longitude
        if let location = locations.last {
            currentLocation = location
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting User location:  \(error)")
    }

    func locateUserCountryByDistance(lat: Double, long: Double) -> Bool {
        let location = CLLocation(latitude: lat, longitude: long)
        let distance = (currentLocation?.distance(from: location))! / 1000
        if( distance > 0 && distance < 100.00) {
            return true
        }
        return false
    }

    @IBAction func updateCurrentLocationData(_ sender: Any) {
            let urlAppString = "https://www.bing.com/covid/data"
            getCovidApiDataFromBing(urlString: urlAppString)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

        let urlAppString = "https://www.bing.com/covid/data"
        getCovidApiDataFromBing(urlString: urlAppString)
    }

    func getCovidApiDataFromBing(urlString: String) {
        // Establish a session with the API endpoint to start getting API data
        let urlSession = URLSession(configuration: .default)
        let url = URL(string: urlString)
        if let url = url {
            let dataTask = urlSession.dataTask(with: url) {
                (data, response, error) in if let data = data {
                    if let httpResponse = response as? HTTPURLResponse
                    {
                        if(httpResponse.statusCode == 401){
                            if let data = self.getData(filename: "covid_data") {
                                do {
                                    let jsonDecoder = JSONDecoder()
                                    self.apiResponseData = try jsonDecoder.decode(CovidAPISchema.self, from: data)
                                    if (self.apiResponseData != nil) // Only set the data when API response is not nil
                                    {
                                        self.totalConfirmed = self.apiResponseData.totalConfirmed
                                        self.totalDeaths = self.apiResponseData.totalDeaths
                                        self.totalRecovered = self.apiResponseData.totalRecovered

                                        self.pctRecovered = Double(self.totalRecovered)/Double(self.totalConfirmed) * 100
                                        self.pctDeaths = Double(self.totalDeaths)/Double(self.totalConfirmed) * 100

                                        if (self.currentLocation == nil) {
                                            self.showLocationPermissionMessage()}
                                        else {
                                            self.searchCountry = self.getUserCountry(apiResponseData: self.apiResponseData)}
                                    self.userNearestCountry = self.searchCountry
                                    }
                                    else{ // Ask the user to press update button to re trigger the API call and try again to get data
                                        self.userNearestCountry = "Please update using button below"
                                    }
                                } catch {
                                    print("Cannot decode your data")
                                    print(error)
                                }
                            }
                        }
                    }
                    else {
                        let jsonDecoder = JSONDecoder()
                        do {
                            self.apiResponseData = try jsonDecoder.decode(CovidAPISchema.self, from: data)
                            if (self.apiResponseData != nil) // Only set the data when API response is not nil
                            {
                                self.totalConfirmed = self.apiResponseData.totalConfirmed
                                self.totalDeaths = self.apiResponseData.totalDeaths
                                self.totalRecovered = self.apiResponseData.totalRecovered

                                self.pctRecovered = Double(self.totalRecovered)/Double(self.totalConfirmed) * 100
                                self.pctDeaths = Double(self.totalDeaths)/Double(self.totalConfirmed) * 100

                                if (self.currentLocation == nil) {
                                    self.showLocationPermissionMessage()}
                                else {
                                    self.searchCountry = self.getUserCountry(apiResponseData: self.apiResponseData)}
                            self.userNearestCountry = self.searchCountry
                            }
                            else{ // Ask the user to press update button to re trigger the API call and try again to get data
                                self.userNearestCountry = "Please update using button below"
                            }
                        }
                    catch {
                        print("Unable to fetch the API data, retrying again")
                        DispatchQueue.main.async {
                            self.view.layoutIfNeeded()}
                        }
                    }
                    DispatchQueue.main.async {
                        // Requirement#1- Logo for the app
                        // Requirement#2- Show Total Cases, Recovered cases and death counts from the bing api data
                        // Requirement#3- Compute % Recovered and % Deaths and show on view
                        // This will set all the Text Data in the App that has been retrieved from the API
                        self.setTextDataInTheApp(totalConfirmed: self.totalConfirmed,
                                                 totalDeaths: self.totalDeaths,
                                                 totalRecovered: self.totalRecovered,
                                                 pctRecovered: self.pctRecovered,
                                                 pctDeaths: self.pctDeaths)

                        // Requirement#4- Show pie chart to display Total Cases, Recovered cases and death counts
                        // This is graph for data as fetched in Requirement#2 above
                        self.setPieChartData(totalConfirmed: self.totalConfirmed,
                                             totalDeaths: self.totalDeaths,
                                             totalRecovered: self.totalRecovered)

                        self.setUserLocationData(userNearestCountry: self.userNearestCountry,
                                                 userNearestCountryTotal: self.userNearestCountryTotal,
                                                 closestsRecovered: self.userNearestCountryRecoveredTotal,
                                                 userNearestCountryDeathsTotals: self.userNearestCountryDeathsTotal)
                    }
                }
            }
            dataTask.resume()
        }
    }

    func setTextDataInTheApp(totalConfirmed: Int, totalDeaths: Int, totalRecovered: Int, pctRecovered: Double, pctDeaths: Double) {
        // Set the UI elements for the text data to be displayed on the screen
        self.totalCases.text = String(totalConfirmed)
        self.deathCases.text = String(totalDeaths)
        self.recoveredCases.text = String(totalRecovered)

        self.percentRecovered.text = "\(String(format:"%.2f", pctRecovered)) %"
        self.percentDeaths.text = "\(String(format:"%.2f",pctDeaths)) %"
    }

    func setPieChartData(totalConfirmed: Int, totalDeaths: Int, totalRecovered: Int) {

        let dataEntries: [ChartDataEntry] = [
            PieChartDataEntry(value: Double(totalConfirmed), label: "Total Confirmed"),
            PieChartDataEntry(value: Double(totalDeaths), label: "Total Deaths"),
            PieChartDataEntry(value: Double(totalRecovered), label: "Total Recovered")
        ]

        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "World Wide Covid19 Data")
        pieChartDataSet.colors = ChartColorTemplates.material()
        pieChartDataSet.sliceSpace = 1
        pieChartDataSet.selectionShift = 0
        pieChartDataSet.xValuePosition = .outsideSlice
        pieChartDataSet.yValuePosition = .outsideSlice
        pieChartDataSet.valueTextColor = .black
        pieChartDataSet.valueLineWidth = 0.5
        pieChartDataSet.valueLinePart1Length = 0.1
        pieChartDataSet.valueLinePart2Length = 0.4
        pieChartDataSet.drawValuesEnabled = true
        let pieChartData = PieChartData(dataSet: pieChartDataSet)

        pieChart.animate(yAxisDuration: 1.0)
        pieChart.entryLabelColor = UIColor.black
        pieChart.legend.textColor = UIColor.black
        pieChart.legend.font = UIFont(name: "Futura", size: 12)!
        pieChart.data = pieChartData
        pieChart.noDataText = "API not reachable, please reload the app"
        pieChart.isUserInteractionEnabled = true
        pieChartDataSet.colors = [UIColor.lightGray, UIColor.systemPink, UIColor.systemGreen]
        pieChart.notifyDataSetChanged()
        let legend = pieChart.legend
        legend.horizontalAlignment = .center
        legend.verticalAlignment = .bottom
        legend.orientation = .horizontal

        pieChart.data?.setValueFont(UIFont(name: "Futura", size: 15)!)
        pieChart.data?.setValueTextColor(UIColor.black)
    }

    func setUserLocationData(userNearestCountry: String, userNearestCountryTotal: Int, closestsRecovered: Int, userNearestCountryDeathsTotals: Int) {
        DispatchQueue.main.async {
            self.userLocationCountryName.text = "Your nearest Country : \(self.userNearestCountry)"
            self.userLocationTotalCasesCount.text = String(userNearestCountryTotal)
            self.userLocationRecoveredCasesCount.text = String(closestsRecovered)
            self.userLocationTotalDeathCount.text = String(userNearestCountryDeathsTotals)
        }
    }

    func showLocationPermissionMessage() {
        DispatchQueue.main.async {
            self.userLocationCountryName.text = "Allow Location permission and then refresh"
        }
    }

    func getUserCountry(apiResponseData: CovidAPISchema) -> String {
        for item in apiResponseData.areas {
            if(item.areas.count > 0) {
                for i in item.areas {
                    if(self.locateUserCountryByDistance(lat: i.lat, long: i.long)) {
                        self.searchCountry = item.displayName
                        self.userNearestCountryTotal = item.totalConfirmed ?? 0
                        self.userNearestCountryRecoveredTotal = item.totalRecovered ?? 0
                        self.userNearestCountryDeathsTotal = item.totalDeaths ?? 0
                    }
                    else {
                        print("Currently searching country \(item.displayName) does not match with User's nearest country")
                    }
                }
            }
            else {
                if(self.locateUserCountryByDistance(lat: item.lat, long: item.long)) {
                    self.searchCountry = item.id
                }
            }
        }
        return self.searchCountry
    }

    func getData(filename fileName: String) -> Data? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                return data
            } catch {
                print("I can not read your file \(fileName).json")
                print(error)
            }
        }
        print("I can not read the file \(fileName).json")
        return nil
    }
}
