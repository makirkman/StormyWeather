//
//  StormFinderTests.swift
//  StormyWeatherTests
//
//  Created by Kirkman, Max on 7/3/21.
//

import XCTest
@testable import StormyWeather

class StormFinderTests: XCTestCase {

    let stormFinder = StormFinder() ;

    func testFindNearestStorm() throws {
        let expectation = XCTestExpectation(description: "Find rain around a point") ;

        try stormFinder.findStormFull(near: Coordinate(lat: -37.840935, lon: 144.946457)) { weather in
            // verify we received an area with rain
            XCTAssert(AcceptedWeather.allStrings.contains(weather.type), "expected rainy or stormy weather, but core weather was \(weather.type)") ;
            print(weather)

            expectation.fulfill() ;
        } ;

        wait(for: [expectation], timeout: 3.0) ;
    }


    // works but the function is private
    func testGrowBoxes() {

        let expectedBoxSizes = [1, 9, 25, 49] ;

        let point = Coordinate(lat: 0.0, lon: 0.0)
        var boxes = [BoundingBox(around: point)] ;
        var reachedMaxBoxes = false ;

        while (!reachedMaxBoxes) {
            XCTAssert(expectedBoxSizes.contains(boxes.count), "growBoxes grew to a number of boxes which was not expected based on the growing algorithm, which anticipates 1 -> 9 -> 25 -> 49 - the number of boxes is currently \(boxes.count)") ;
            if let newBoxes = stormFinder.growBoxes(around: point, from: boxes) {
                boxes = newBoxes ;
            } else {
                XCTAssert(boxes.count == expectedBoxSizes.last, "growBoxes refused to grow any larger, but did not reach the expected final box number (49) - box size stopped at \(boxes.count)")
                reachedMaxBoxes = true ;
            }
        }
    }

//    func testLookForStorm () throws {
//
//        let decoder = JSONDecoder() ;
//        var groupWeather: GroupWeather? ;
//
//        if let path = Bundle.main.path(forResource: "TestCitiesSquareResWithRain", ofType: "json") {
//            print(path)
//            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe) ;
//            groupWeather = try decoder.decode(GroupWeather.self, from: data) ;
//        } else {
//
//            print("fail")
//        }
//
//        let stormFinder = StormFinder() ;
//        let foundStorm = stormFinder.runLookForStorm(near: Coordinate(lat: -37.840935, lon: 144.946457), in: groupWeather!) ;
//
//        print(foundStorm) ;
//
//
//    }
}
