//
//  SingleLocWeather.swift
//  StormyWeather
//
//  Created by Kirkman, Max on 6/3/21.
//

import Foundation

struct SingleLocWeatherRes: Decodable {
    // location details
    let name: String ;
    let coord: Coordinate ;
    let sys: WeatherSys? ;
    let timezone: String? ;

    // weather details
    let core: [WeatherCore] ;
    let main: WeatherMain ;
    let wind: Wind ;

    // metadata
    let timeRetrieved: Int? ;

    enum CodingKeys: String, CodingKey {
        case name = "name" ;
        case coord = "coord" ;
        case sys = "sys" ;
        case timezone = "timezone" ;
        case core = "weather" ;
        case main = "main" ;
        case wind = "wind" ;
        case timeRetrieved = "dt" ;
    }

    // internal data structures
    struct WeatherCore: Decodable {
        let id: Int ;
        let main: String ;
        let description: String ;
        let icon: String ;
    }
    struct WeatherMain: Decodable {
        let temp: Double ;
        let feels_like: Double ;
        let temp_min: Double ;
        let pressure: Double ;
        let humidity: Double ;
        let sea_level: Double? ;
        let grnd_level: Double? ;
    }
    struct Wind: Decodable {
        let speed: Double ;
        let deg: Int ;
    }
    struct WeatherSys: Decodable {
        let type: Int? ;
        let message: Double? ;
        let country: String? ;
        let sunrise: Int? ;
        let sunset: Int? ;
    }
}
