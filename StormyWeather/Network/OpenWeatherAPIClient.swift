//
//  OpenWeatherAPIClient.swift
//  StormyWeather
//
//  Created by Kirkman, Max on 5/3/21.
//

import Foundation

class OpenWeatherAPIClient {

    private let apiKey = NetworkSecrets.apiKey ;
    private let baseUrl = "https://api.openweathermap.org/data/2.5/" ;
    private let session = URLSession(configuration: .default) ;
    private let decoder = JSONDecoder()

    typealias WeatherCompletionHandler<T> = (T?, Error?) -> Void
    typealias GroupWeatherCompletionHandler = WeatherCompletionHandler<GroupWeatherRes>

    /// Get weather data for a list of up to 50 cities around a given coordinate point.
    public func getWeather (
        aroundPoint coord: Coordinate,
        forCities cityNum: Int = 50,
        completionHandler completion: @escaping GroupWeatherCompletionHandler
    ) throws {

        // verify input
        guard (cityNum > 0 && cityNum <= 50) else {
            throw NetworkError.invalidParams("Number of cities to check must be between 0 and 50, but was \(cityNum).") ;
        }

        // construct & send request
        let endpoint = "find" ;
        let params = "lat=\(coord.lat)&lon=\(coord.lon)&cnt=\(cityNum)&appid=\(apiKey)" ;
        getWeather(at: endpoint, with: params, completionHandler: completion) ;
    }

    /// Get weather data for a square of up to 25 square degrees, defined by two coordinate points.
    public func getWeather (
        inBox bBox: BoundingBox,
        zoom: Int=100,
        completionHandler completion: @escaping GroupWeatherCompletionHandler
    ) throws {
        // verify input
        guard (bBox.squareDegrees <= 25) else {
            throw NetworkError.invalidParams("Bounding box exceeded limit of 25 square degrees, with \(bBox.squareDegrees).") ;
        }

        // construct & send request
        let endpoint = "box/city" ;
        let boundingBox = "\(bBox.lonLeft),\(bBox.latBottom),\(bBox.lonRight),\(bBox.latTop)" ;
        let params = "bbox=\(boundingBox),\(zoom)&appid=\(apiKey)" ;
        getWeather(at: endpoint, with: params, completionHandler: completion) ;
    }


    /// Get weather data generically for a given endpoint and parameters
    private func getWeather<T:WeatherRes> (
        at endpoint: String,
        with params: String,
        completionHandler completion: @escaping WeatherCompletionHandler<T>
    ) {
        // prepare the request
        let url = URL(string: "\(baseUrl)\(endpoint)?\(params)&units=metric")! ;
        let request = URLRequest(url: url) ;

        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {

                // make sure we have workable data and response
                guard let data = data else {
                    if let error = error {
                        completion(nil, error) ;
                    } else {
                        completion (nil, NetworkError.failedRequest("Both data and error were nil for request to \(String(describing: url))\n - received response: \(String(describing: response))"))
                    }
                    return ;
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(nil, NetworkError.failedRequest("A response was received but it could not be converted to HTTPURLResponse - response: \(String(describing: response))")) ;
                    return ;
                }

                // if the response was successful, decode & pass it out
                if httpResponse.statusCode >= 200 && httpResponse.statusCode < 400 {

                    // if the response is an empty array, pass through an empty response
                    let emptyRes: Array<T> ;
                    do {
                        emptyRes = try self.decoder.decode(Array<T>.self, from: data) ;
                        if (emptyRes.count == 0) {
                            completion(T.getEmpty(), nil) ;
                            return ;
                        }
                    // if the response couldn't be decoded because it's not an array, we can continue as normal
                    } catch DecodingError.typeMismatch {}
                    // if it threw any other kind of error pass it through
                    catch let e {
                        completion(nil, NetworkError.failedRequest("A successful response was received (response code \(httpResponse.statusCode), but it was an array which could not be decoded from JSON,\nerror stack:\n\(e)\nraw JSON:\n\(String(data: data, encoding: .utf8) ?? "nil")")) ;
                    }

                    // the response is assumed to have some data
                    let weatherRes: T ;
                    do {
                        weatherRes = try self.decoder.decode(T.self, from: data) ;
                        completion(weatherRes, nil) ;
                    } catch let e {
                        completion(nil, NetworkError.failedRequest("A successful response was received (response code \(httpResponse.statusCode), but it could not be decoded from JSON,\nerror stack:\n\(e)\nraw JSON:\n\(String(data: data, encoding: .utf8) ?? "nil")")) ;
                    }
                } else {
                    completion(nil, NetworkError.unexpectedResponseCode("A response was received with an unexpected response code (\(httpResponse.statusCode)\nresponse:\n\(httpResponse)")) ;
                }
            }
        }

        // send the request
        task.resume() ;
    }
}
