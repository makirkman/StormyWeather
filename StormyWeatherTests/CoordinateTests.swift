//
//  CoordinateTests.swift
//  StormyWeatherTests
//
//  Created by Kirkman, Max on 7/3/21.
//

import XCTest
@testable import StormyWeather

class CoordinateTests: XCTestCase {

    func testCoordinateDistance() throws {
        let pointOne = Coordinate(lat: 0, lon: 20) ;
        let pointTwo = Coordinate(lat: 1, lon: 20) ;
        let distanceOne = pointOne.findDistance(from: pointTwo) ;
        XCTAssert(distanceOne == 1, "\(distanceOne)") ;

        // test functionality for crossing 180 degree line
        let pointThree = Coordinate(lat: 160, lon: 0) ;
        let pointFour = Coordinate(lat: -160, lon: 0) ;
        let distanceTwo = pointThree.findDistance(from: pointFour)
        XCTAssert(distanceTwo == 40, "\(distanceTwo)") ;
    }
}
