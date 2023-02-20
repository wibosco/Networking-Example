//
//  GridItem+Layout.swift
//  Networking-Example
//
//  Created by William Boles on 20/02/2023.
//

import Foundation
import SwiftUI

extension GridItem {
    
    static func threeFlexibleColumns() -> [GridItem] {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
        ]
        
        return columns
    }
}
