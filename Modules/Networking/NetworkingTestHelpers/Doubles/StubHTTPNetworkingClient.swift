//
//  StubHTTPNetworkingClient.swift
//  NetworkingTestHelpers
//
//  Created by William Boles on 27/02/2023.
//

import Foundation
import Networking
import UIKit

public class StubHTTPNetworkingClient<P: Decodable, T: Encodable>: HTTPNetworkingClientType {
    public var getClosure: ((String, [URLQueryItem]?, [HTTPHeader]?, ResponseDecoder) -> (P))!
    public var getJSONClosure: ((String, [URLQueryItem]?, [HTTPHeader]?) -> (P))!
    
    public var downloadDataClosure: ((URL, ProgressThreshold, ((Double) -> ())?) -> (Data))!
    
    public var postFileClosure: ((String, Data, MimeType, [HTTPHeader]?, ResponseDecoder) -> (P))!
    public var postJSONClosure: ((String, T, [HTTPHeader]?) -> (P))!
    
    public var deleteClosure: ((String, [URLQueryItem]?, [HTTPHeader]?) ->())!
    
    public init() { }
    
    public func get<D>(path: String, queryItems: [URLQueryItem]?, headers: [HTTPHeader]?, decoder: ResponseDecoder) async throws -> D where D : Decodable {
        getClosure(path, queryItems, headers, decoder) as! D
    }
    
    public func getJSON<D>(path: String, queryItems: [URLQueryItem]?, headers: [HTTPHeader]?) async throws -> D where D : Decodable {
        getJSONClosure(path, queryItems, headers) as! D
    }
    
    public func downloadData(url: URL, progressThreshold: ProgressThreshold, progressUpdateHandler: ((Double) -> ())?) async throws -> Data {
        downloadDataClosure(url, progressThreshold, progressUpdateHandler)
    }
    
    public func postFile<D>(path: String, data: Data, mimeType: MimeType, headers: [HTTPHeader]?, decoder: ResponseDecoder) async throws -> D where D : Decodable {
        postFileClosure(path, data, mimeType, headers, decoder) as! D
    }
    
    public func postJSON<D, E>(path: String, body: E, headers: [HTTPHeader]?) async throws -> D where D : Decodable, E : Encodable {
        postJSONClosure(path, (body as! T), headers) as! D
    }
    
    public func delete(path: String, queryItems: [URLQueryItem]?, headers: [HTTPHeader]?) async throws {
        deleteClosure(path, queryItems, headers)
    }
}
