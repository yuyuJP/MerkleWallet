//
//  MessagePrinter.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/10/21.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation
import UIKit

func printUInt8ArrayToHex(data : [UInt8]) {
    for byte in data {
        var str = String(byte, radix: 16)
        if str.characters.count < 2 {
            str = "0" + str
        }
        print(str, terminator: " ")
    }
}
