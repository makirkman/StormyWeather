//
//  BoundingBox.swift
//  StormyWeather
//
//  Created by Kirkman, Max on 7/3/21.
//

import Foundation

struct BoundingBox {
    private(set) var lonLeft: Double ;
    private(set) var latBottom: Double ;
    private(set) var lonRight: Double ;
    private(set) var latTop: Double ;

    var centrePoint: Coordinate {
        let lat = self.latBottom + (boxSide/2) ;
        let lon = self.lonLeft + (boxSide/2) ;
        return Coordinate(lat: lat, lon: lon) ;
    } ;
    var squareDegrees: Double {
        return abs(self.latTop - self.latBottom) * abs(self.lonRight - self.lonLeft) ;
    }

    private let boxSide = 5.0 ;

    private init(_ lonLeft: Double, _ latBottom: Double, _ lonRight: Double, _ latTop: Double) {
        self.lonLeft = lonLeft ;
        self.latBottom = latBottom ;
        self.lonRight = lonRight ;
        self.latTop = latTop ;
    }

    init(lonLeft: Double, latBottom: Double, lonRight: Double, latTop: Double) {
        self.init(lonLeft, latBottom, lonRight, latTop) ;
    }
    init(from coordinates: (bottomLeft: Coordinate, topRight: Coordinate)) {
        self.init(
            coordinates.bottomLeft.lon, coordinates.bottomLeft.lat,
            coordinates.topRight.lon, coordinates.topRight.lat
        ) ;
    }

    init(around point: Coordinate) {
        // we want a 5*5 square, so go 1/2 of box side size in each direction
        self.init(point.lon, point.lat, point.lon, point.lat) ;
        self.lonLeft -= (self.boxSide / 2) ;
        self.latBottom -= (self.boxSide / 2) ;
        self.lonRight += (self.boxSide / 2) ;
        self.latTop += (self.boxSide / 2) ;
    }

    /// Create a new BoundingBox by moving one box-size in a given direction, from a given coordinate.
    ///  from: (0,0), in: .North will create a box at ((0,0), (5,5))
    // assumes non-specified movement is up and to the right, so e.g. 'East' means
    //  a new box between the original given point and +5lon +5lat, 'West' means
    //  -5lon +5lat
    init(from point: Coordinate, in direction: Direction) {
        // initialise a 0-width box at the point as our default
        self.init(point.lon, point.lat, point.lon, point.lat) ;

        // move two edges out in the given direction to create a second point
        switch direction {
        case .North, .NorthEast, .East :
            self.lonRight += boxSide ;
            self.latTop += boxSide ;
        case .South, .SouthEast :
            self.lonRight += boxSide ;
            self.latBottom -= boxSide ;
        case .SouthWest :
            self.lonLeft -= boxSide ;
            self.latBottom -= boxSide ;
        case .West, .NorthWest :
            self.lonLeft -= boxSide ;
            self.latTop += boxSide ;
        }
    }

    /// Create a new BoundingBox by moving one box-size in a given direction, from a given pre-existing box.
    ///  from: ((0,0), (0,0)), in: .North will create a box at ((0,0), (5,5))
    init(from box: BoundingBox, in direction: Direction) {
        // the direction determines which point to start building the box from
        let point: Coordinate ;
        switch direction {
        case .North, .NorthWest :
            point = Coordinate(lat: box.latTop, lon: box.lonLeft) ;
        case .NorthEast :
            point = Coordinate(lat: box.latTop, lon: box.lonRight) ;
        case .East, .SouthEast :
            point = Coordinate(lat: box.latBottom, lon: box.lonRight) ;
        case .South, .SouthWest, .West :
            point = Coordinate(lat: box.latBottom, lon: box.lonLeft) ;
        }

        // create a box from the point determined by the direction
        self.init(from: point, in: direction) ;
    }
}
