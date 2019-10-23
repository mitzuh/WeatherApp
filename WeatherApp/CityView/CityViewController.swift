//
//  CityViewController.swift
//  WeatherApp
//
//  Created by Jimi Savola on 09/10/2019.
//  Copyright © 2019 Jimi Savola. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class CityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var cityTable: UITableView!
    
    var weatherData: WeatherData = WeatherData()
    
    var locationManager: CLLocationManager?
    var clGeocoder: CLGeocoder?

    var longitude: Double?
    var latitude: Double?
    
    var cities: [String] = ["Use GPS", "Helsinki", "Tampere", "Turku"]
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clGeocoder = CLGeocoder()
        
        // Register the table view cell class and its reuse id
        self.cityTable.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // Remove the extra empty cells
        self.cityTable.tableFooterView = UIView()
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        cityTable.delegate = self
        cityTable.dataSource = self
    }
    
    // Return number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cities.count
    }
    
    // Create tableview cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Create a new cell if needed or reuse an old one
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        // Set text to tableview cells
        cell.textLabel?.text = self.cities[indexPath.row]
        
        return cell
    }
    
    // Check if GPS was clicked, and switch city if different city was clicked.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let i = Int(indexPath.row)
        if(i == 0){
            locationManager = CLLocationManager()
            self.locationManager!.delegate = self
            locationManager!.requestAlwaysAuthorization()
            self.locationManager!.startUpdatingLocation()
        }
        else {
            let city = self.cities[indexPath.row]
            let trimmedCity = city.replacingOccurrences(of: " ", with: "+")
            self.weatherData.selectedCity = trimmedCity
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.latitude = locationManager!.location!.coordinate.latitude
        self.longitude = locationManager!.location!.coordinate.longitude
        self.locationManager!.stopUpdatingLocation()
        getGeolocation()
    }
    
    func getGeolocation() {
        let location = CLLocation(latitude: latitude!, longitude: longitude!)
        
        clGeocoder!.reverseGeocodeLocation(location) {(placemarks, error) in
            var placemark : CLPlacemark!
            placemark = placemarks? [0]
            let city =  placemark.locality
            
            if (!self.cities.contains(city!)) {
                self.cities.append(city!)
                self.cityTable.reloadData()
            }
        }
    }
}
