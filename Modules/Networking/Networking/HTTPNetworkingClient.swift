//
//  NetworkingClient.swift
//  Networking
//
//  Created by William Boles on 27/01/2023.
//

import Foundation
import UIKit

public protocol HTTPNetworkingClientType {
    func get<T: Decodable>(path: String, queryItems: [URLQueryItem]?, headers: [HTTPHeader]?, decoder: ResponseDecoder) async throws -> T
    func getJSON<T: Decodable>(path: String, queryItems: [URLQueryItem]?, headers: [HTTPHeader]?) async throws -> T
    
    func downloadData(url: URL, progressThreshold: ProgressThreshold, progressUpdateHandler: ((Double) -> ())?) async throws -> Data
    
    func post<T: Decodable>(path: String, data: Data, mimeType: MimeType, headers: [HTTPHeader]?, decoder: ResponseDecoder) async throws -> T
    func postImage<T: Decodable>(path: String, image: UIImage, headers: [HTTPHeader]?, decoder: ResponseDecoder) async throws -> T
    
    func delete(path: String, queryItems: [URLQueryItem]?, headers: [HTTPHeader]?) async throws
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
    
    // MARK: - Requests
    
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
        
        let combinedHeaders = config.defaultHeaders + (headers ?? [])
        
        combinedHeaders.forEach({ header in
            urlRequest.addValue(header.value, forHTTPHeaderField: header.field)
        })
        
        if let body = body {
            urlRequest.httpBody = body
        }
        
        return urlRequest
    }
    
    // MARK: - Decoding
    
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
        
        let result: T = try await get(path: path,
                                      queryItems: queryItems,
                                      headers: headers,
                                      decoder: JSONDecoder())
        
        return result
    }
    
    // MARK: - Download
    
    private func makeDownloadRequest(url: URL,
                                     progressThreshold: ProgressThreshold,
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
            
            let difference = currentProgress - existingProgress
            
            if difference > progressThreshold.rawValue {
                progressUpdateHandler?(currentProgress)
                existingProgress = min(currentProgress, 1)
            }
        }
        
        return data
    }
    
    public func downloadData(url: URL,
                             progressThreshold: ProgressThreshold = .everyOne,
                             progressUpdateHandler: ((Double) -> ())?) async throws -> Data {
        let data  = try await makeDownloadRequest(url: url,
                                                  progressThreshold: progressThreshold,
                                                  progressUpdateHandler: progressUpdateHandler)
        
        return data
    }
    
    // MARK: - POST
    
    private func makeMultipartReqest<T: Decodable>(path: String,
                                                   data: Data,
                                                   mimeType: MimeType,
                                                   headers: [HTTPHeader]?,
                                                   decoder: ResponseDecoder) async throws -> T {
        let url = buildURL(forPath: path)
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        let multipartHeader = HTTPHeader(field: "Content-Type",
                                         value: "multipart/form-data; boundary=\(boundary)")
        
        var headers = headers ?? []
        headers += [multipartHeader]
        
        var body = Data()
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(UUID().uuidString).jpeg\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.append("\r\n")
        body.append("--\(boundary)--")
        
        let urlRequest = buildRequest(forURL: url,
                                      httpMethod: .POST,
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
    
    public func post<T: Decodable>(path: String,
                                   data: Data,
                                   mimeType: MimeType,
                                   headers: [HTTPHeader]?,
                                   decoder: ResponseDecoder) async throws -> T {
        let result: T =  try await makeMultipartReqest(path: path,
                                                       data: data,
                                                       mimeType: mimeType,
                                                       headers: headers,
                                                       decoder: decoder)
        
        return result
    }
    
    public func postImage<T: Decodable>(path: String,
                                        image: UIImage,
                                        headers: [HTTPHeader]?,
                                        decoder: ResponseDecoder) async throws -> T {
        guard let data = image.jpegData(compressionQuality: 1.0) else {
            //TODO: Handle better
            fatalError("Can not convery image to a jpeg")
        }
        
        let result: T = try await post(path: path,
                                       data: data,
                                       mimeType: .jpeg,
                                       headers: headers,
                                       decoder: decoder)
        
        return result
    }
    
    //MARK: - Delete
    
    public func delete(path: String, queryItems: [URLQueryItem]?, headers: [HTTPHeader]?) async throws {
        let url = buildURL(forPath: path,
                           queryItems: queryItems)
        
        let urlRequest = buildRequest(forURL: url,
                                      httpMethod: .DELETE,
                                      body: nil,
                                      headers: headers)
        
        do {
            let (_, _) = try await urlSession.data(for: urlRequest)
        } catch let error as HTTPNetworkingError {
            throw error
        } catch let underlyingError {
            let error = HTTPNetworkingError.network(underlyingError: underlyingError)
            
            throw error
        }
    }
}
