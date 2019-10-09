//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Jimi Savola on 09/10/2019.
//  Copyright © 2019 Jimi Savola. All rights reserved.
//

import Foundation
import UIKit

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var desc: UILabel!
    
    var weatherInfoModel: WeatherInfoModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateCurrentWeather(){
        DispatchQueue.main.async {
            self.cityName.text = self.weatherInfoModel?.name
            self.temperature.text = String(self.weatherInfoModel!.main.temp) + " °C"
            self.desc.text = self.weatherInfoModel?.weather[0].description
            
            print("Begin of code")
            let iconcode = self.weatherInfoModel?.weather[0].icon
            let url = URL(string: "https://api.openweathermap.org//img/w/\(iconcode).png")!
            self.downloadImage(from: url)
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.imageView.image = UIImage(data: data)
            }
        }
    }
}
