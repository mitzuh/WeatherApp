//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Jimi Savola on 09/10/2019.
//  Copyright © 2019 Jimi Savola. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var desc: UILabel!
    
    var weatherInfoModel: WeatherInfoModel?
    var weatherData: WeatherData = WeatherData()
    var previousCity: String?
    
    var locationManager : CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager = CLLocationManager()
        self.locationManager!.delegate = self
        locationManager!.requestAlwaysAuthorization()
        self.locationManager!.startUpdatingLocation()
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
        fetchUrl(url: "https://api.openweathermap.org/data/2.5/weather?q=\(self.weatherData.selectedCity!)&APPID=6cc50f5db6907d1dd672bac2c944928c&&units=metric")
    }
    
    // Get user location using GPS
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lon = locationManager?.location?.coordinate.longitude
        let lat = locationManager?.location?.coordinate.latitude
        
        self.locationManager!.stopUpdatingLocation()
        fetchUrl(url: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat!)&lon=\(lon!)&APPID=6cc50f5db6907d1dd672bac2c944928c&&units=metric")
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
        let weatherInfoModel = try! JSONDecoder().decode(WeatherInfoModel.self, from: data!)
        self.weatherInfoModel = weatherInfoModel
        self.updateCurrentWeather()
    }
    
    // Update labels and image
    func updateCurrentWeather(){
        DispatchQueue.main.async {
            self.cityName.text = self.weatherInfoModel?.name
            self.temperature.text = String(self.weatherInfoModel!.main.temp) + "°C"
            self.desc.text = self.weatherInfoModel?.weather[0].description
            
            let iconcode = self.weatherInfoModel?.weather[0].icon
            let url = URL(string: "https://api.openweathermap.org//img/w/\(iconcode!).png")!
            self.downloadImage(from: url)
        }
    }
    
    // Get data from url
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    // Load and update image
    func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                self.imageView.image = UIImage(data: data)
            }
        }
    }
}
