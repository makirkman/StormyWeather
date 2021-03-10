//
//  AcceptedWeather.swift
//  StormyWeather
//
//  Created by Kirkman, Max on 7/3/21.
//

import Foundation

/// Weather types which our app is interested in finding
enum AcceptedWeather: String, CaseIterable {
    case Rain ;
    case Storm ;

    /// Returns the equivalent of allCases but as their respective String representation
    static var allStrings: [String] {
        var strings: [String] = []
        for c in Self.allCases {
            strings.append(c.rawValue)
        }
        return strings
    }
}
