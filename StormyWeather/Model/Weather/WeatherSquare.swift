//
//  WeatherSquare.swift
//  StormyWeather
//
//  Created by Kirkman, Max on 8/3/21.
//

import Foundation

struct WeatherSquare: WeatherGroup {
    let weathers: [Weather] ;
    let centrePoint: Coordinate ;
    let boundingBox: BoundingBox ;

    private init(
        _ groupWeather: GroupWeatherRes,
        _ centrePoint: Coordinate,
        _ boundingBox: BoundingBox
    ) {
        self.weathers = Self.convertEntries(from: groupWeather) ;
        self.centrePoint = centrePoint ;
        self.boundingBox = boundingBox ;
    }

    init(from groupWeather: GroupWeatherRes, around centrePoint: Coordinate) {
        self.init(groupWeather, centrePoint, BoundingBox(around: centrePoint)) ;
    }
    init(from groupWeather: GroupWeatherRes, in boundingBox: BoundingBox) {
        self.init(groupWeather, boundingBox.centrePoint, boundingBox) ;
    }
}
