//
//  UIImage+Colors.swift
//  APIServiceTests
//
//  Created by William Boles on 27/02/2023.
//

import UIKit

extension UIImage {
    static func fromColor(_ color: UIColor = .lightGray, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
       
        let image =  UIGraphicsImageRenderer(size: size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
        
        return image
    }
}
