//
//  GroupWeatherRes.swift
//  StormyWeather
//
//  Created by Kirkman, Max on 6/3/21.
//

import Foundation

struct GroupWeatherRes: WeatherRes, Decodable {
    let count: Int ;
    let list: [SingleLocWeatherRes] ;

    // allow empty creation for empty responses
    private init(count: Int, list: [SingleLocWeatherRes]) {
        self.count = count ;
        self.list = list ;
    }
    static func getEmpty() -> GroupWeatherRes {
        return GroupWeatherRes.init(count: 0, list: []) ;
    }

    enum CodingKeys: String, CodingKey {
        case count ;
        case cnt ;
        case list ;
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        // try to decode count, throw only if neither is successful
        do {
            self.count = try values.decode(Int.self, forKey: .count) ;
        } catch DecodingError.keyNotFound {
            self.count = try values.decode(Int.self, forKey: .cnt) ;
        }

        self.list = try values.decode([SingleLocWeatherRes].self, forKey: .list) ;
    }
}
