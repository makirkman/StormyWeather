//
//  WeatherRes.swift
//  StormyWeather
//
//  Created by Kirkman, Max on 7/3/21.
//

import Foundation

protocol WeatherRes: Decodable {
    /// Generate an empty version of the response in case the API returns empty
    static func getEmpty() -> Self
}
