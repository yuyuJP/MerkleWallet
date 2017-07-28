//
//  BitcoinPrefixes.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/07/28.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation

public class BitcoinPrefixes {
    
    public static var pubKeyPrefix: UInt8 {
        if isBitcoinMainNet {
            return 0x00
        } else {
            return 0x6f
        }
    }
    
}
