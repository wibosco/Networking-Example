//
//  NetworkingClient.swift
//  Networking
//
//  Created by William Boles on 27/01/2023.
//

import Foundation

public protocol NetworkingClientType {
    func get<T: Decodable>(path: String, queryItems: [URLQueryItem]?, completion: @escaping ((Result<T, Error>) -> ()))
    func put<T: Decodable, B: Encodable>(path: String, body: B, completion: @escaping ((Result<T, Error>) -> ()))
}

public protocol URLSessionDataTaskType {
    func resume()
}

extension URLSessionDataTask: URLSessionDataTaskType { }

public protocol URLSessionType {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskType
}

extension URLSession: URLSessionType {
    public func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskType {
        return dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask
    }
}

public protocol ResponseDecoder {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

extension JSONDecoder: ResponseDecoder { }

public final class HTTPNetworkingClient {
    private let urlSession: URLSessionType
    private let config: HTTPNetworkingConfigurationType
    
    // MARK: - Init
    
    public init(urlSession: URLSessionType,
         config: HTTPNetworkingConfigurationType) {
        self.urlSession = urlSession
        self.config = config
    }
    
    // MARK: - Request
    
    private func makeDataRequest<T: Decodable, D: ResponseDecoder>(path: String,
                                                                   queryItems: [URLQueryItem]? = nil,
                                                                   body: Data? = nil,
                                                                   httpMethod: HTTPMethod,
                                                                   headers: [HTTPHeader]? = nil,
                                                                   decoder: D,
                                                                   completion: @escaping ((Result<T, Error>) -> ())) {
        let url = buildURL(forPath: path, queryItems: queryItems)
        let urlRequest = buildRequest(forURL: url,
                                      httpMethod: httpMethod,
                                      body: body,
                                      headers: headers)
    
        let task = urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            guard let self = self else {
                return
            }
            
            let result: Result<T, Error> = self.decodeResponse(fromData: data,
                                                               response: response,
                                                               error: error,
                                                               decoder: decoder)
            
            completion(result)
        }
        task.resume()
    }

    private func buildURL(forPath path: String,
                          queryItems: [URLQueryItem]? = nil) -> URL {
        var components = URLComponents()
        components.scheme = config.scheme
        components.host = config.host
        components.path = path
        components.queryItems = queryItems
        
        guard let url = components.url else {
            preconditionFailure("Must have a url to make a network request: \(components)")
        }
        
        return url
    }
    
    private func buildRequest(forURL url: URL, httpMethod: HTTPMethod,
                              body: Data?,
                              headers: [HTTPHeader]?) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        
        headers?.forEach({ header in
            urlRequest.addValue(header.value, forHTTPHeaderField: header.field)
        })
        
        if let body = body {
            urlRequest.httpBody = body
        }
        
        return urlRequest
    }
    
    private func decodeResponse<T: Decodable, D: ResponseDecoder>(fromData data: Data?,
                                                                  response: URLResponse?,
                                                                  error: Error?,
                                                                  decoder: D) -> Result<T, Error> {
        guard let data = data,
              let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let retrievalError = NetworkingError.network(underlayingError: error, response: response)
            
            return .failure(retrievalError)
        }
        
        do {
            let decoded = try decoder.decode(T.self, from: data)
            
            return .success(decoded)
        } catch let decodeError {
            let error = NetworkingError.decoding(underlayingError: decodeError)
            
            return .failure(error)
        }
    }
    
    private func encodeBody<T: Encodable>(fromBody body: T) -> Result<Data, Error> {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(body)
            
            return .success(data)
        } catch let encodeError {
            let error = NetworkingError.encoding(underlayingError: encodeError)
            
            return .failure(error)
        }
    }
    
    // MARK: - GET
    
    public func get<T: Decodable, D: ResponseDecoder>(path: String,
                                                      queryItems: [URLQueryItem]?,
                                                      headers: [HTTPHeader]? = nil,
                                                      decoder: D,
                                                      completion: @escaping ((Result<T, Error>) -> ())) {
        makeDataRequest(path: path,
                        queryItems: queryItems,
                        httpMethod: .GET,
                        headers: headers,
                        decoder: decoder,
                        completion: completion)
    }
}
