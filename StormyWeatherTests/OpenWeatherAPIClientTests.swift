//
//  OpenWeatherAPIClientTests.swift
//  StormyWeatherTests
//
//  Created by Kirkman, Max on 5/3/21.
//

import XCTest
@testable import StormyWeather

class OpenWeatherAPIClientTests: XCTestCase {

    let client = OpenWeatherAPIClient() ;

    // MARK: - Test Data
    let testCoordinate = Coordinate(lat: 55.5, lon: 37) ;

    // MARK: - Get Weather Around Function
    /// Test all basic functionality of the getWeather(around) function
    func testGetWeatherAround() throws {
        // Expected Failures
        XCTAssertNoThrow(try testGWACityNumOutOfBounds(cityNum: -5)) ;
        XCTAssertNoThrow(try testGWACityNumOutOfBounds(cityNum: 55)) ;

        // Successful Execution
        // test basic successful requests for an increasing number of cities
        XCTAssertNoThrow(try testGetWeatherAround(cityNum: 5)) ;
        XCTAssertNoThrow(try testGetWeatherAround(cityNum: 15)) ;
        XCTAssertNoThrow(try testGetWeatherAround(cityNum: 35)) ;
        XCTAssertNoThrow(try testGetWeatherAround(cityNum: 50)) ;
        }
    func testGetWeatherAround(cityNum: Int) throws {

        let expectation = XCTestExpectation(description: "Get Weather for \(cityNum) cities around a location") ;

        XCTAssertNoThrow(try client.getWeather(aroundPoint: testCoordinate, forCities: cityNum) { res, error in
            // verify the request was successful & provides a weatherAround object
            guard let weatherAround = res else {
                XCTAssert(res != nil, "expected successful response but res was nil\nerror was: \(String(describing: error))") ;
                return
            } ;
            XCTAssert(error == nil, "expected successful response but also received an error\nres was: \(res!)\nerror was:\n\(error!)") ;

            // verify the right number of cities were returned
            XCTAssert(weatherAround.count == cityNum) ;
            XCTAssert(weatherAround.list.count == cityNum) ;

            expectation.fulfill() ;
        }) ;

        wait(for: [expectation], timeout: 3.0) ;
    }
    func testGWACityNumOutOfBounds(cityNum: Int) throws {

        var thrownError: Error?
        XCTAssertThrowsError(try client.getWeather(aroundPoint: testCoordinate, forCities: cityNum) { _,_ in }) {
            thrownError = $0 ;
        }
        XCTAssertTrue(
            thrownError is NetworkError,
            "testCityNumOutOfBounds Expected invalidParams error for \(cityNum) cities but received \(String(describing: thrownError))"
        ) ;
    }

    // MARK: - Get Weather in Box Function
    /// Test all basic functionality of the getWeather(inBox) function
    func testGetWeatherInBox() throws {

        let a: GroupWeatherRes ;

        /* create test data */
        // manual boxes for coordinates outside bounds
        let failBoxes: [BoundingBox] = [
            BoundingBox(from: (Coordinate(lat: 28, lon: 12), Coordinate(lat: 55, lon: 13))),
            BoundingBox(from: (Coordinate(lat: 12, lon: 28), Coordinate(lat: 13, lon: 55)))
        ] ;

        // generate random boxes with an appropriate size for successful testing
        var successBoxes: [BoundingBox] = [
            // add one box we know has cities just in case
            BoundingBox(from: (Coordinate(lat: 30, lon: 12), Coordinate(lat: 55, lon: 13)))
        ]
        for _ in 0...6 {
            // keep track of how many degrees we have left to fill the box
            let totalSquareDegrees: Double = 24.9 ;

            // create two latitudes within 23 degrees of each other
            let latBottom = Double.random(in: -180...180) ;
            let latTop = Double.random(in: latBottom+1...latBottom+totalSquareDegrees-1) ;

            // take note of how much space we have left for our longitudes
            let squareDegreesLeft = (
                totalSquareDegrees / (abs(latTop-latBottom))
            ) ;

            // create two longitudes within the remaining degrees of each other
            let lonLeft = Double.random(in: -180...180) ;
            let lonRight = lonLeft + squareDegreesLeft ;

            let box = BoundingBox(lonLeft: lonLeft, latBottom: latBottom, lonRight: lonRight, latTop: latTop) ;
            successBoxes.append(box) ;
        }
        /* ---------------- */

        // run tests
        // Expected Failures
        for box in failBoxes {
            XCTAssertNoThrow(try testGWSBoundingBoxDegrees(bBox: box)) ;
        }
        // Expected Successes
        for box in successBoxes {
            XCTAssertNoThrow(try testGetWeatherInSquare(bBox: box)) ;
        }
    }

    func testGetWeatherInSquare(bBox: BoundingBox) throws {
        let expectation = XCTestExpectation(description: "Get Weather in square \(bBox)") ;

        XCTAssertNoThrow(try client.getWeather(inBox: bBox) { res, error in
            // verify the request was successful & provides a weatherAround object
            guard let weatherInSquare = res else {
                XCTAssert(res != nil, "expected successful response but res was nil\nerror was: \(error!)") ;
                return ;
            } ;
            XCTAssert(error == nil, "expected successful response but also received an error\nres was: \(res!)\nerror was:\n\(error!)") ;

            // verify a consistent number of cities were returned
            XCTAssert(weatherInSquare.count >= 0) ;
            XCTAssert(weatherInSquare.list.count == weatherInSquare.count) ;

            expectation.fulfill() ;
        }) ;

        wait(for: [expectation], timeout: 3.0) ;
    }

    func testGWSBoundingBoxDegrees(bBox: BoundingBox) throws {
        var thrownError: Error?
        XCTAssertThrowsError(try client.getWeather(inBox: bBox) { _,_ in }) {
            thrownError = $0 ;
        }
        XCTAssertTrue(
            thrownError is NetworkError,
            "testCityNumOutOfBounds Expected invalidParams error for boundingBox \(bBox) but received \(String(describing: thrownError))"
        ) ;
    }
}
