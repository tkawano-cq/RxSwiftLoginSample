//
//  HttpRequest.swift
//  RxTest
//
//  Created by TOUYA KAWANO on 2020/09/07.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import Foundation
import RxSwift

protocol HttpRequest {
    associatedtype Request: Encodable
    associatedtype Response: Decodable
    
    var baseUrl: String { get }
    
    var path: String { get }
    
    var url: URL? { get }
    
    var method: HttpMethod { get }
    
    var headerFields: [String: String] { get }
    
    var encoder: JSONEncoder { get }
    
    var decoder: JSONDecoder { get }
        
    func request(_ parameters: Request) -> Single<Response>
}

extension HttpRequest {
    
    var url: URL? {
        URL(string: baseUrl + path)
    }
    
    var headerFields: [String: String] {
        [String: String]()
    }
    
    var defaultHeaderFields: [String: String] {
        ["content-type": "application/json"]
    }
    
    var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
    
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
    func request(_ parameters: Request) -> Single<Response> {
        do {
            let data = try encoder.encode(parameters)
            return request(data)
        } catch { return Single.error(error) }
    }
    
    private func request(_ data: Data?) -> Single<Response> {
        return Single.create(subscribe: { observer -> Disposable in
            do {
                guard let url = self.url, var urlRequest = try self.method.urlRequest(url: url, data: data) else {
                    return Disposables.create()
                }
                urlRequest.allHTTPHeaderFields = self.defaultHeaderFields.merging(self.headerFields) { $1 }
                urlRequest.timeoutInterval = 8
                
                let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                    if let error = error {
                        observer(.error(error))
                    }
                    
                    guard let data = data, let response = response as? HTTPURLResponse else {
                        observer(.error(APIError.response))
                        return
                    }
                    
                    guard 200..<300 ~= response.statusCode else {
                        observer(.error(APIError.http(status: response.statusCode, data: data)))
                        return
                    }
                    
                    do {
                        let entity = try self.decoder.decode(Response.self, from: data)
                        observer(.success(entity))
                    } catch {
                        observer(.error(APIError.decode(error)))
                    }
                }
                dataTask.resume()
                return Disposables.create()

            } catch {
                return Disposables.create()
            }
        })
    }
}


enum APIError: Error {
    case request
    case response
    case emptyResponse
    case decode(Error)
    case http(status: Int, data: Data)
}

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
    
    func urlRequest(url: URL, data: Data?) throws -> URLRequest? {
        var request = URLRequest(url: url)
        switch self {
        case .get:
            guard let data = data else {
                request.httpMethod = rawValue
                return request
            }
            
            guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return nil }
            
            components.queryItems = dictionary.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            guard let getUrl = components.url else { return nil }
            var request = URLRequest(url: getUrl)
            request.httpMethod = rawValue
            return request
            
        case .post, .put, .delete, .patch:
            request.httpMethod = rawValue
            request.httpBody = data
            return request
        }
    }
}
