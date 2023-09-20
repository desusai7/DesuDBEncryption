//
//  API.swift
//  MetricsReporter
//
//  Created by Pallab Maiti on 27/06/23.
//

import Foundation

@frozen enum API {
    case sdkMetrics(params: String)
}

@frozen enum APIClientStatus {
    case success
    case failure
    case serverFailure
    case unknown
    
    init(_ statusCode: Int) {
        switch statusCode {
        case 200..<300:
            self = .success
        case 400..<500:
            self = .failure
        case 500..<600:
            self = .serverFailure
        default:
            self = .unknown
        }
    }
}
