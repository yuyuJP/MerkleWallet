//
//  BIQRCodeGenerator.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/07/01.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation
import UIKit

public class BIQRCodeGenerator {
    
    private let code: String
    
    private let imagesSize: CGFloat
    
    public init(code: String, imageSize: CGFloat) {
        self.code = code
        self.imagesSize = imageSize
    }
    
    public var qrCodeImage: UIImage? {
        let data = code.data(using: .utf8)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            
            guard  let image = filter.outputImage else { return nil }
            
            let scaleX = imagesSize / image.extent.size.width
            let scaleY = imagesSize / image.extent.size.height
            
            let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
}

