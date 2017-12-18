//
//  NSData+HexString.swift
//  RIPEMD-160
//
//  Created by Yusuke Asai on 2016/10/09.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation
import BigInt

extension NSData {
    internal func toHexString() -> String {
        let sha256description = self.description as String
        
        // TODO: more elegant way to convert NSData to a hex string
        
        var result: String = ""
        
        for char in sha256description.characters {
            switch char {
            case "0", "1", "2", "3", "4", "5", "6", "7","8","9", "a", "b", "c", "d", "e", "f":
                result.append(char)
            default:
                result += String("")
            }
        }
        
        return result

    }
    
   internal class func fromHexString(_ string: String) -> NSData {
        let num = BigUInt(string, radix: 16)!
        return num.serialize() as NSData
    }
}
