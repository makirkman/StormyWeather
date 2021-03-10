//
//  StormFinder.swift
//  StormyWeather
//
//  Created by Kirkman, Max on 7/3/21.
//

import Foundation

class StormFinder {
    let MAX_API_CALLS = 60 ;

    typealias StormSearchCompletionHandler = (Weather) -> Void

    let client = OpenWeatherAPIClient()

    /// Find the nearest storm (defined according to the AcceptedWeather enum) and pass it to the completion handler
    public func findStormFull(
        near centrePoint: Coordinate,
        completionHandler completion: @escaping StormSearchCompletionHandler
    ) throws {

        /* get the biggest box around the user we can */
        var boxes = [BoundingBox(around: centrePoint)] ;
        var reachedMaxBoxes = false ;

        while (!reachedMaxBoxes) {
            if let newBoxes = self.growBoxes(around: centrePoint, from: boxes) {
                boxes = newBoxes ;
            } else {
                reachedMaxBoxes = true ;
            }
        }
        /* ------------------------------------------ */

        // get the weather for each box and check them for storms

        /* // Finds definitively the closest storm
        var weatherSquares: [WeatherSquare] = [] ;
        var finalBox = false ;

        var foundStorm: Weather? ;

        for i in 0..<boxes.count {
            let curBox = boxes[i] ;
            let isFinalBox = finalBox.centrePoint == curBox.centrePoint ;

            try client.getWeather(inBox: boxes[i]) { weatherGroupRes, error in
                if weatherGroupRes != nil {
                    // check the weather group response for a storm
                    let weatherGroup = WeatherSquare(from: weatherGroupRes!, in: curBox) ;
                    let newStorm = self.lookForStorm(near: centrePoint, in: weatherGroup) ;
                    // if there is a storm, check if it's closer than others
                    if (newStorm != nil) {
                        let lastDist = foundStorm?.coord.findDistance(from: centrePoint) ;
                        let newDist = newStorm!.coord.findDistance(from: centrePoint) ;

                        if (lastDist == nil || newDist < lastDist!) {
                            foundStorm = newStorm ;
                        }
                    }

                } else {
                    print("Error received: \(error)") ;
                }

                if (isLastBox) {
                    group.leave() ;
                }
            }
        }
         */

        // finds the probable closest, and stops API calls once found
        var foundStorm: Weather? ;
        var i = 0

        while foundStorm == nil && i < boxes.count {
            let curBox = boxes[i] ;

            try client.getWeather(inBox: curBox) { weatherGroupRes, error in
                if weatherGroupRes != nil {
                    // check the weather group response for a storm
                    let weatherGroup = WeatherSquare(from: weatherGroupRes!, in: curBox) ;
                    foundStorm = self.lookForStorm(near: centrePoint, in: weatherGroup) ;
                    // if there is a storm, check if it's closer than others
                    if (foundStorm != nil) {
                        completion(foundStorm!) ;
                    }
                } else {
                    print("Error received: \(error!)") ;
                }
            }

            i += 1 ;
        }
    }

    /// Make calls to the weather API and search responses for a storm, then pass it to the completion handler
    private func findStorm(
        near centrePoint: Coordinate,
        completionHandler completion: @escaping StormSearchCompletionHandler
    ) throws {

        // start with a square around a point
        // if it's less than 50 cities, try the circle around a point

        // start with a square around a point
        var weatherSquares: [WeatherSquare] = [] ;
        var weatherCircle: WeatherCircle? ;
        let firstSquare = BoundingBox(around: centrePoint) ;

        let group = DispatchGroup() ;
        group.enter() ;

        // check the immediate square around the point
        try client.getWeather(inBox: firstSquare) { weatherGroup, error in
            if weatherGroup != nil {
                weatherSquares.append(WeatherSquare(from: weatherGroup!, in: firstSquare)) ;
            }

            // if this was our last call, finish processing
            if (weatherCircle != nil) {
                group.leave() ;
            }
        }

        // while waiting for that, ask for a circle as well
        try client.getWeather(aroundPoint: centrePoint) { weatherGroup, error in
            if weatherGroup != nil {
                weatherCircle = WeatherCircle(from: weatherGroup!, around: centrePoint) ;
            } ;

            // if this was our last call, finish processing
            if (!weatherSquares.isEmpty) {
                group.leave() ;
            }
        }


        // send through the square & circle we found
        group.notify(queue: .main) {
            print() ;

            // start by checking the biggest of the square or circle lists
            let firstCheck: WeatherGroup ;
            if (weatherSquares[0].weathers.count > weatherCircle!.weathers.count) {
                firstCheck = weatherSquares[0] ;
            } else {
                firstCheck = weatherCircle! ;
            }
            var foundStorm = self.lookForStorm(near: centrePoint, in: firstCheck) ;
            if foundStorm != nil {
                completion(foundStorm!) ;
                return ;
            }

            // if the biggest list didn't contain a storm, we need to expand our search
        }
    }

    /// Expands a list of bounding boxes to one more layer of squares, and returns the result, which
    ///  makes a larger square (so 1 box will make a new square of 9 smaller boxes, 9 will make 25 and so on)
    // TODO: Re-order boxes in order of proximity to point
    private func growBoxes(
        around point: Coordinate,
        from boxes: [BoundingBox]
    ) -> [BoundingBox]? {

        var newBoxes: [BoundingBox] = boxes ;

        // add 8 * i each time
        // 1 + 8 + 16 + 24 -> 49
        let n = boxes.count ;
        let d = Direction.allCases.count ;
        let newBoxTotal = n + d * Int(ceil(Double(n) / Double(d))) ;

        // don't continue if we're at the number where the API will refuse calls
        if newBoxTotal > MAX_API_CALLS {
            return nil ;
        }

        // if we're good to expand, add one box to the list in each direction
        for box in boxes {
            for j in 0..<Direction.allCases.count {
                let direction = Direction.allCases[j] ;
                // get a new box
                let newBox = BoundingBox(from: box, in: direction) ;

                // make sure there isn't already a box with the same centrePoint in the list
                if ( !(newBoxes.map() { $0.centrePoint }).contains(newBox.centrePoint) ) {
                    newBoxes.append(newBox) ;
                }
            }
        }
        return newBoxes
    }


    /**
     Looks through a given GroupWeather object for the closest storm to a given point.
     Returns a SingleLocWeather object with a storm if found, or nil if there were no storms in the group.
     */
    private func lookForStorm(near point: Coordinate, in groupWeather: WeatherGroup) -> Weather? {
        var foundRain: Weather?
        for weather in groupWeather.weathers {
            // check for rain
            if ((AcceptedWeather.allStrings).contains(weather.type)) {

                // check if it's closer than the last found rain
                if (foundRain == nil) {
                    foundRain = weather ;
                } else {
                    let prevDist = foundRain!.coord.findDistance(from: point) ;
                    let curDist = weather.coord.findDistance(from: point) ;

                    if curDist < prevDist {
                        foundRain = weather ;
                    }
                }
            }
        }
        return foundRain ;
    }




}






#if DEBUG
// add functionality to test the look for storm function, which is complex and should
//  be tested directly, but is best not exposed publicly.
//extension StormFinder {
//    internal func runLookForStorm(near point: Coordinate, in groupWeather: GroupWeatherRes) -> SingleLocWeatherRes? {
//        self.lookForStorm(near: point, in: groupWeather) ;
//    }
//}

#endif
