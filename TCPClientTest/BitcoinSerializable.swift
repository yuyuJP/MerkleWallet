//
//  BitcoinSerializable.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/11/01.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public protocol BitcoinSerializable {
    var bitcoinData: NSData { get }
    
    static func fromBitcoinStream(_ stream: InputStream) -> Self?
}
