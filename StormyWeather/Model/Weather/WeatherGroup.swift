//
//  WeatherGroup.swift
//  StormyWeather
//
//  Created by Kirkman, Max on 8/3/21.
//

import Foundation

protocol WeatherGroup {
    var weathers: [Weather] { get } ;
    var centrePoint: Coordinate { get } ;

    static func convertEntries(from groupWeather: GroupWeatherRes) -> [Weather] ;
}

extension WeatherGroup {

    static func convertEntries(from groupWeather: GroupWeatherRes) -> [Weather] {
        // gather all entries for weather in the group
        var weatherEntries: [Weather] = [] ;
        for weatherRes in groupWeather.list {
            for i in 0..<weatherRes.core.count {
                weatherEntries.append(Weather(from: weatherRes, at: i)) ;
            }
        }
        return weatherEntries
    }
}
