//
//  UIColorExtention.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/07/01.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func themeColor() -> UIColor {
        return UIColor(colorLiteralRed: 166 / 255, green: 198 / 255, blue: 117 / 255, alpha: 1.0)
    }
    
    static func boarderGray() -> UIColor {
        return UIColor(colorLiteralRed: 207 / 255, green: 209 / 255, blue: 216 / 255, alpha: 1.0)
    }
    
    static func backgroundWhite() -> UIColor {
        return UIColor(colorLiteralRed: 250 / 255, green: 250 / 255, blue: 250 / 255, alpha: 1.0)
    }
    
    static func sentRed() -> UIColor {
        return UIColor(colorLiteralRed: 227 / 255, green: 83 / 255, blue: 84 / 255, alpha: 1.0)
    }
    
    static func receivedGreen() -> UIColor {
        return UIColor(colorLiteralRed: 98 / 255, green: 236 / 255, blue: 131 / 255, alpha: 1.0)
    }
    
}
