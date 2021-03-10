//
//  StormViewModel.swift
//  StormyWeather
//
//  Created by Kirkman, Max on 9/3/21.
//

import Foundation
import Combine

class StormViewModel: ObservableObject {

    @Published var model: Weather? ;

    init() {
        let stormFinder = StormFinder()
        // TODO: Get user location
        do {
            try stormFinder.findStormFull(near: Coordinate(lat: -37.840935, lon: 144.946457)) { weather in
                self.model = weather ;
            }
        } catch let e {
            print(e) ;
        }
    }
}

extension StormViewModel {
    var location: String { model?.name ?? "" } ;

    var weatherSummary: String {
        guard (model != nil) else { return "..." } ;
        return "\(model!.description), \(model!.temperature)" ;
    }

//    var temperature: Double { model.temperature } ;
//    var weatherType: String { model.type } ;
//    var weatherDescription: String { model.description } ;
}
