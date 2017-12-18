//
//  UIColorExtention.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/07/01.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import UIKit

extension UIColor {
    
    
    //#a6c675
    static func themeColor() -> UIColor {
        return UIColor(displayP3Red: 166 / 255, green: 198 / 255, blue: 117 / 255, alpha: 1.0)
        
    }
    
    static func boarderGray() -> UIColor {
        return UIColor(displayP3Red: 207 / 255, green: 209 / 255, blue: 216 / 255, alpha: 1.0)
    }
    
    static func backgroundWhite() -> UIColor {
        return UIColor(displayP3Red: 250 / 255, green: 250 / 255, blue: 250 / 255, alpha: 1.0)
    }
    
    static func sentRed() -> UIColor {
        return UIColor(displayP3Red: 227 / 255, green: 83 / 255, blue: 84 / 255, alpha: 1.0)
    }
    
    static func receivedGreen() -> UIColor {
        return UIColor(displayP3Red: 98 / 255, green: 236 / 255, blue: 131 / 255, alpha: 1.0)
    }
    
}
