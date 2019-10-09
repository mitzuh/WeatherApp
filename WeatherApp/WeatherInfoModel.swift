//
//  WeatherInfoModel.swift
//  WeatherApp
//
//  Created by Jimi Savola on 09/10/2019.
//  Copyright © 2019 Jimi Savola. All rights reserved.
//

import Foundation

struct WeatherInfoModel: Codable {
    var name: String
    var weather: [Weather]
    var main: Main
}

struct Weather: Codable {
    var description: String
    var icon: String
    var id: Int
}

struct Main: Codable {
    var temp: Double
}
