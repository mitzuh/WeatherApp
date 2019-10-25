//
//  ForecastViewController.swift
//  WeatherApp
//
//  Created by Jimi Savola on 09/10/2019.
//  Copyright © 2019 Jimi Savola. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreGraphics

class ForecastViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var forecastTable: UITableView!
    var locationManager : CLLocationManager?
    
    var weatherData: WeatherData = WeatherData()
    
    var forecasts: [List] = [List]()
    var iconList: [UIImage] = [UIImage]()
    var previousCity: String?
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Location manager
        self.locationManager = CLLocationManager()
        self.locationManager!.delegate = self
        locationManager!.requestAlwaysAuthorization()
        self.locationManager!.startUpdatingLocation()
        
        // Register the table view cell class and its reuse id
        self.forecastTable.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // Remove the extra empty cells
        self.forecastTable.tableFooterView = UIView()
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        forecastTable.delegate = self
        forecastTable.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (self.weatherData.selectedCity != nil) {
            if (self.previousCity != self.weatherData.selectedCity) {
                updateCity()
            }
            self.previousCity = self.weatherData.selectedCity
        }
    }
    
    func updateCity() {
        fetchUrl(url: "https://api.openweathermap.org/data/2.5/forecast?q=\(self.weatherData.selectedCity!)&APPID=6cc50f5db6907d1dd672bac2c944928c&&units=metric")
    }
    
    // Return number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.forecasts.count
    }
    
    // Create tableview cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create a new cell if needed or reuse an old one
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        // Set text to tableview cells
        let upperText = self.forecasts[indexPath.row].weather[0].description + " " + String(self.forecasts[indexPath.row].main.temp) + "°C"
        let lowerText = self.forecasts[indexPath.row].dt_txt
        
        // Tableview cell image
        if (cell.imageView?.image == nil) {
            DispatchQueue.main.async() {
                cell.imageView?.image = self.iconList[indexPath.row]
            }
        }
        
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.text = upperText + "\n" + lowerText
        
        return cell
    }
    
    // Print tapped row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(self.forecasts[indexPath.row])
    }
    
    // Get data from url
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    // Get user location using GPS
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lon = locationManager?.location?.coordinate.longitude
        let lat = locationManager?.location?.coordinate.latitude
        
        self.locationManager!.stopUpdatingLocation()
        fetchUrl(url: "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat!)&lon=\(lon!)&APPID=6cc50f5db6907d1dd672bac2c944928c&units=metric")
    }
    
    // Fetch passed url
    func fetchUrl(url : String) {
        let config = URLSessionConfiguration.default
        
        let session = URLSession(configuration: config)
        
        let url : URL? = URL(string: url)
        
        let task = session.dataTask(with: url!, completionHandler: doneFetching);
        
        // Starts the task, spawns a new thread and calls the callback function
        task.resume();
    }
    
    // Update desired data after fetching is complete
    func doneFetching(data: Data?, response: URLResponse?, error: Error?) {
        let forecastInfoModel = try! JSONDecoder().decode(ForecastInfoModel.self, from: data!)
        let dataList = forecastInfoModel.list
        forecasts = [List]()
        for data in dataList {
            forecasts.append(data)
            
            let iconcode = data.weather[0].icon
            let iconUrl = URL(string: "https://api.openweathermap.org//img/w/\(iconcode).png")!
            
            self.getData(from: iconUrl) { data, response, error in
                guard let data = data, error == nil else { return }
                self.iconList.append(UIImage(data: data)!)
            }
        }
        DispatchQueue.main.async {
            self.forecastTable.reloadData()
        }
    }
}
