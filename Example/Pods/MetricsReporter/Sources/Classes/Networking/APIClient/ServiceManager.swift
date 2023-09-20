//
//  ServiceManager.swift
//  MetricsReporter
//
//  Created by Pallab Maiti on 27/06/23.
//

import Foundation
import RudderKit

typealias Handler<T> = (HandlerResult<T, NSError>) -> Void

enum HandlerResult<Success, Failure> {
    case success(Success)
    case failure(Failure)
}

enum ErrorCode: Int {
    case UNKNOWN = -1
    case WRONG_WRITE_KEY = 0
    case DECODING_FAILED = 1
    case SERVER_ERROR = 500
}

struct ServiceManager: ServiceType {
    private let urlSession: URLSession
    private let configuration: Configuration
    
    init(urlSession: URLSession, configuration: Configuration) {
        self.urlSession = urlSession
        self.configuration = configuration
    }
    
    func sdkMetrics(params: String, _ completion: @escaping Handler<Bool>) {
        request(.sdkMetrics(params: params), completion)
    }
}

extension ServiceManager {
    func request<T: Codable>(_ api: API, _ completion: @escaping Handler<T>) {
        let urlString = [baseURL(api), path(api)].joined().addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        Logger.logDebug("URL: \(urlString ?? "")")
        var request = URLRequest(url: URL(string: urlString ?? "")!)
        request.httpMethod = method(api).value
        if let headers = headers(api) {
            request.allHTTPHeaderFields = headers
            Logger.logDebug("HTTPHeaderFields: \(headers)")
        }
        if let httpBody = httpBody(api) {
            request.httpBody = httpBody
            Logger.logDebug("HTTPBody: \(httpBody)")
        }
        let dataTask = urlSession.dataTask(with: request, completionHandler: { (data, response, error) in
            if error != nil {
                completion(.failure(NSError(code: .SERVER_ERROR)))
                return
            }
            let response = response as? HTTPURLResponse
            if let statusCode = response?.statusCode {
                let apiClientStatus = APIClientStatus(statusCode)
                switch apiClientStatus {
                case .success:
                    switch api {
                    case .sdkMetrics:
                        completion(.success(true as! T)) // swiftlint:disable:this force_cast
                    }
                default:
                    let errorCode = handleCustomError(data: data ?? Data())
                    completion(.failure(NSError(code: errorCode)))
                }
            } else {
                completion(.failure(NSError(code: .SERVER_ERROR)))
            }
        })
        dataTask.resume()
    }
    
    func handleCustomError(data: Data) -> ErrorCode {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                return .SERVER_ERROR
            }
            if let message: String = json["message"] as? String, message == "Invalid write key" {
                return .WRONG_WRITE_KEY
            }
            return .SERVER_ERROR
        } catch {
            return .SERVER_ERROR
        }
    }
}

extension ServiceManager {
    func headers(_ api: API) -> [String: String]? {
        var headers = ["Content-Type": "Application/json"]
        switch api {
        case .sdkMetrics:
            headers["Content-Encoding"] = "gzip"
        }
        return headers
    }
    
    func baseURL(_ api: API) -> String {
        switch api {
        case .sdkMetrics:
            return configuration.sdkMetricsUrl
        }
    }
    
    func httpBody(_ api: API) -> Data? {
        switch api {
        case .sdkMetrics(let params):
            return try? params.data(using: .utf8)?.gzipped()
        }
    }
    
    func method(_ api: API) -> Method {
        switch api {
        case .sdkMetrics:
            return .post
        }
    }
    
    func path(_ api: API) -> String {
        switch api {
        case .sdkMetrics:
            return "/sdkmetrics"
        }
    }
}

enum Method {
    case post
    case get
    case put
    case delete
    
    var value: String {
        switch self {
        case .post:
            return "POST"
        case .get:
            return "GET"
        case .put:
            return "PUT"
        case .delete:
            return "DELETE"
        }
    }
}

extension NSError {
    convenience init(code: ErrorCode) {
        self.init(domain: "MetricError", code: code.rawValue, userInfo: nil)
    }
}
