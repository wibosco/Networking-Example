//
//  Bundle+Load.swift
//  NetworkingTestHelpers
//
//  Created by William Boles on 28/02/2023.
//

import Foundation

private class EmptyClass {}

public extension Bundle {
    static func loadBundleFile(_ filename: String, fileExtension: String) -> Data {
        let bundle = Bundle(for: EmptyClass.self)
        guard let url = bundle.url(forResource: filename, withExtension: fileExtension) else {
            fatalError("File does not exist")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Data can't be loaded from: \(url)")
        }
        
        return data
    }
    
    static func loadJSONBundleFile(_ filename: String) -> Data {
        return loadBundleFile(filename, fileExtension: "json")
    }
}
