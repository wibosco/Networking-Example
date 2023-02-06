//
//  NetworkingClient.swift
//  Networking
//
//  Created by William Boles on 27/01/2023.
//

import Foundation

public protocol HTTPNetworkingClientType {
    func get<T: Decodable>(path: String, queryItems: [URLQueryItem]?, headers: [HTTPHeader]?, decoder: ResponseDecoder) async throws -> T
    func getJSON<T: Decodable>(path: String, queryItems: [URLQueryItem]?, headers: [HTTPHeader]?) async throws -> T
    func downloadData(url: URL, progressUpdateHandler: ((Double) -> ())?) async throws -> Data
}

public protocol URLSessionType {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
    func bytes(for request: URLRequest) async throws -> (URLSession.AsyncBytes, URLResponse)
}

extension URLSession: URLSessionType {
    public func bytes(for request: URLRequest) async throws -> (AsyncBytes, URLResponse) {
       return try await bytes(for: request, delegate: nil)
    }
}

public protocol ResponseDecoder {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

extension JSONDecoder: ResponseDecoder { }

public final class HTTPNetworkingClient: HTTPNetworkingClientType {
    private let urlSession: URLSessionType
    private let config: HTTPNetworkingConfigurationType
    
    // MARK: - Init
    
    public init(urlSession: URLSessionType,
                config: HTTPNetworkingConfigurationType) {
        self.urlSession = urlSession
        self.config = config
    }
    
    // MARK: - Request
    
    private func makeDataRequest<T: Decodable>(path: String,
                                               queryItems: [URLQueryItem]?,
                                               body: Data?,
                                               httpMethod: HTTPMethod,
                                               headers: [HTTPHeader]?,
                                               decoder: ResponseDecoder) async throws -> T {
        let url = buildURL(forPath: path,
                           queryItems: queryItems)
        
        let urlRequest = buildRequest(forURL: url,
                                      httpMethod: httpMethod,
                                      body: body,
                                      headers: headers)
        
        do {
            let (data, response) = try await urlSession.data(for: urlRequest)
            
            let decoded: T = try self.decodeResponse(fromData: data,
                                                     response: response,
                                                     decoder: decoder)
            
            return decoded
        } catch let error as HTTPNetworkingError {
            throw error
        } catch let underlyingError {
            let error = HTTPNetworkingError.network(underlyingError: underlyingError)
            
            throw error
        }
    }
    
    private func makeDownloadRequest(url: URL,
                                     progressUpdateHandler: ((Double) -> ())?) async throws -> Data {
        let request = buildRequest(forURL: url,
                                   httpMethod: .GET,
                                   body: nil,
                                   headers: nil)
        
        let (asyncBytes, urlResponse) = try await urlSession.bytes(for: request)
        
        let length = Int(urlResponse.expectedContentLength)
        
        var data = Data()
        data.reserveCapacity(length) //avoid too many resizes by reserving what we should need

        var existingProgress: Double = 0
        
        for try await byte in asyncBytes {
            data.append(byte)
            let currentProgress = Double(data.count) / Double(length)

            if Int(existingProgress) != Int(currentProgress * 100) { //use fuzzy comparison here instead of convertng to int?
                progressUpdateHandler?(currentProgress)
                existingProgress = (currentProgress * 100)
            }
        }
        
        return data
    }
    
    // MARK: - URL
    
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
    
    private func buildRequest(forURL url: URL,
                              httpMethod: HTTPMethod,
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
    
    private func decodeResponse<T: Decodable>(fromData data: Data,
                                              response: URLResponse,
                                              decoder: ResponseDecoder) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let error = HTTPNetworkingError.response(response: response)
            
            throw error
        }
        
        do {
            let decoded = try decoder.decode(T.self, from: data)
            
            return decoded
        } catch let decodeError {
            let error = HTTPNetworkingError.decoding(underlyingError: decodeError)
            
            throw error
        }
    }
    
    // MARK: - GET
    
    public func get<T: Decodable>(path: String,
                                  queryItems: [URLQueryItem]?,
                                  headers: [HTTPHeader]?,
                                  decoder: ResponseDecoder) async throws -> T {
        let result: T = try await makeDataRequest(path: path,
                                                  queryItems: queryItems,
                                                  body: nil,
                                                  httpMethod: .GET,
                                                  headers: headers,
                                                  decoder: decoder)
        
        return result
    }
    
    public func getJSON<T: Decodable>(path: String,
                                      queryItems: [URLQueryItem]?,
                                      headers: [HTTPHeader]?) async throws -> T {
        
        var headers = headers ?? []
        headers += HTTPHeader.jsonHeaders()
        
        return try await get(path: path,
                             queryItems: queryItems,
                             headers: headers,
                             decoder: JSONDecoder())
    }
    
    public func downloadData(url: URL,
                             progressUpdateHandler: ((Double) -> ())?) async throws -> Data {
        let data  = try await makeDownloadRequest(url: url,
                                                  progressUpdateHandler: progressUpdateHandler)
            
        return data
    }
}
