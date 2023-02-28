//
//  Cats+TestData.swift
//  APIServiceTests
//
//  Created by William Boles on 27/02/2023.
//

import Foundation

@testable import APIService

extension Cat {
    static func testData(id: String = "Meow Meow",
                         url: URL = URL(string: "http://example.test/cat.jpg")!) -> Cat {
        Cat(id: id,
            url: url)
    }
    
    static func testData() -> [Cat] {
        let a = Cat(id: "A",
                    url: URL(string: "http://example.test/catA.jpg")!)
        
        let b = Cat(id: "A",
                    url: URL(string: "http://example.test/catA.jpg")!)
        
        let c = Cat(id: "C",
                    url: URL(string: "http://example.test/catA.jpg")!)
        
        return [a, b, c]
    }
}
