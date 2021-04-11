//
//  NetworkError.swift
//  StormyWeather
//
//  Created by Kirkman, Max on 5/3/21.
//

import Foundation

enum NetworkError: Error {
    case invalidParams(String?)
    case failedRequest(String?)
    case unexpectedResponseCode(String?)
    case invalidResponseData(String?)
}
