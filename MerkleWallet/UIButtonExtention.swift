//
//  UIButtonExtention.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/07/01.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation
import UIKit

fileprivate func createImageFromUIColor(_ color: UIColor) -> UIImage {
    
    let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    
    context!.setFillColor(color.cgColor)
    context!.fill(rect)
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
}

extension UIButton {
    
    func setBackgroundColorForBothState(_ color: UIColor) {
        self.backgroundColor = .black
        
        let selectedColor = color.withAlphaComponent(0.8)
        
        self.setBackgroundImage(createImageFromUIColor(color), for: .normal)
        self.setBackgroundImage(createImageFromUIColor(selectedColor), for: .highlighted)
    }
    
}
