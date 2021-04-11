//
//  Coordinate.swift
//  StormyWeather
//
//  Created by Kirkman, Max on 5/3/21.
//

import Foundation

struct Coordinate: Decodable, Equatable {
    let lat: Double ;
    let lon: Double ;

    init(lat: Double, lon: Double) {
        self.lat = lat ;
        self.lon = lon ;
    }

    var asString: String {
        return "\(lat),\(lon)" ;
    }

    enum CodingKeys: String, CodingKey {
        case lat ;
        case lon ;
        case Lat ;
        case Lon ;
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        // try to decode lat & lon, throw only if neither captalisation is successful
        do {
            lat = try values.decode(Double.self, forKey: .lat) ;
        } catch DecodingError.keyNotFound {
            lat = try values.decode(Double.self, forKey: .Lat) ;
        }
        do {
            lon = try values.decode(Double.self, forKey: .lon) ;
        } catch DecodingError.keyNotFound {
            lon = try values.decode(Double.self, forKey: .Lon) ;
        }
    }

    /// Return the absolute distance between this point and another point
    public func findDistance(from point: Coordinate) -> Double {
        let maxDist = 180.0 ;
        let worldSize = 360.0 ;

        // simple differences
        var latDist = abs(point.lat - self.lat) ;
        var lonDist = abs(point.lon - self.lon) ;

        // if a difference is higher than 180 correct for the fact that it's a globe
        if latDist > maxDist { latDist = abs(latDist - worldSize) }
        if lonDist > maxDist { lonDist = abs(lonDist - worldSize) }

        return latDist + lonDist ;
    }

    public static func == (lhs: Coordinate, rhs: Coordinate) -> Bool {

        // for this app, coordinates are the same if they are very close
        let latsVeryClose = abs(lhs.lat - rhs.lat) < 0.0001
        let lonsVeryClose = abs(lhs.lon - rhs.lon) < 0.0001

        return latsVeryClose && lonsVeryClose ;
    }
}
