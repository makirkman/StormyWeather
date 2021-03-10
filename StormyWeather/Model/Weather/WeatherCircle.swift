//
//  WeatherCircle.swift
//  StormyWeather
//
//  Created by Kirkman, Max on 8/3/21.
//

import Foundation

struct WeatherCircle: WeatherGroup {
    let weathers: [Weather] ;
    let centrePoint: Coordinate ;

    init(from groupWeather: GroupWeatherRes, around centrePoint: Coordinate) {
        self.weathers = Self.convertEntries(from: groupWeather) ;
        self.centrePoint = centrePoint ;
    }
}
