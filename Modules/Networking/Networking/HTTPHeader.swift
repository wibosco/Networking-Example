//
//  HTTPHeaders.swift
//  Networking
//
//  Created by William Boles on 31/01/2023.
//

import Foundation

public struct HTTPHeader {
    let field: String
    let value: String
    
    // MARK: - Init
    
    public init(field: String, value: String) {
        self.field = field
        self.value = value
    }
}

public extension HTTPHeader {
    static func userAgentHeader(_ value: String) -> HTTPHeader {
        return HTTPHeader(field: "User-Agent", value: value)
    }
    
    static func defaultUserAgentHeader() -> HTTPHeader {
        let info = Bundle.main.infoDictionary
        
        let appName = info?["CFBundleName"] as? String ?? "Unknown"
        let appVersion = info?["CFBundleShortVersionString"] as? String ?? "Unknown"
        
        let version = ProcessInfo.processInfo.operatingSystemVersion
        
        let userAgent = "\(appName)/\(appVersion) (iOS \(version.majorVersion).\(version.minorVersion).\(version.patchVersion))"
        
        return userAgentHeader(userAgent)
    }
    
    static func acceptHeader(_ value: String) -> HTTPHeader {
        return HTTPHeader(field: "Accept", value: value)
    }
        
    static func jsonAcceptHeader() -> HTTPHeader {
        return acceptHeader("application/json")
    }
    
    static func contentTypeHeader(_ value: String) -> HTTPHeader {
        return HTTPHeader(field: "Content-Type", value: value)
    }
    
    static func jsonContentTypeHeader() -> HTTPHeader {
        return contentTypeHeader("application/json")
    }
    
    static func acceptEncodingHeader(_ values: [String]) -> HTTPHeader {
        let qualityEncodedValues = values.qualityEncodedHeaderValue()
        
        return HTTPHeader(field: "Accept-Encoding", value: qualityEncodedValues)
    }
    
    static func defaultAcceptEncodingHeader() -> HTTPHeader {
        return acceptEncodingHeader(["gzip", "deflate", "br"])
    }
    
    static func acceptLanguageHeader(_ values: [String]) -> HTTPHeader {
        let qualityEncodedValues = values.qualityEncodedHeaderValue()
        
        return HTTPHeader(field: "Accept-Language", value: qualityEncodedValues)
    }
    
    static func defaultUserAcceptLanguageHeader() -> HTTPHeader {
        let preferredLanguages = Array(Locale.preferredLanguages.prefix(10))
        
        return acceptLanguageHeader(preferredLanguages)
    }
}

public extension HTTPHeader {
    static func defaultHeaders() -> [HTTPHeader] {
        let headers = [defaultUserAgentHeader(), defaultAcceptEncodingHeader(), defaultUserAcceptLanguageHeader()]
        
        return headers
    }
    
    static func jsonHeaders() -> [HTTPHeader] {
        let headers = [jsonAcceptHeader(), jsonContentTypeHeader()]
        
        return headers
    }
}

private extension Array where Element == String {
    func qualityEncodedHeaderValue() -> String {
        let encodings = enumerated().map { index, encoding in
            let quality = Swift.max((1.0 - (Double(index) * 0.1)), 0.0)
            return "\(encoding);q=\(quality)"
        }
        
        let joined = encodings.joined(separator: ", ")
        
        return joined
    }
}
