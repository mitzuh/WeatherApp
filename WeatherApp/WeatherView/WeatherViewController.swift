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
    
    // TEST
    var dataController: DataController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        dataController = DataController()
        dataController?.fetchUrl(url: "https://api.openweathermap.org/data/2.5/forecast?id=524901&APPID=6cc50f5db6907d1dd672bac2c944928c")
    }
    
    
}
