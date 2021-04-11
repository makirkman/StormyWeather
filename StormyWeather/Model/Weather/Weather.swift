//
//  Weather.swift
//  StormyWeather
//
//  Created by Kirkman, Max on 8/3/21.
//

import Foundation

struct Weather {

    let name: String ;
    let coord: Coordinate ;
    let weatherId: Int ;
    let type: String ;
    let description: String ;
    let temperature: Double ;

    init(from weatherRes: SingleLocWeatherRes, at coreNum: Int) {
        self.name = weatherRes.name ;
        self.coord = weatherRes.coord ;
        self.weatherId = weatherRes.core[coreNum].id ;
        self.type = weatherRes.core[coreNum].main ;
        self.description = weatherRes.core[coreNum].description ;
        self.temperature = weatherRes.main.temp ;
    }
}
