//
//  SHA256Hash.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/11/06.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public func ==(left: SHA256Hash, right: SHA256Hash) -> Bool {
    return left.data == right.data
}

public struct SHA256Hash: Equatable {
    
    public let data: NSData
    
    public init() {
        self.data = NSMutableData(length: 32)!
    }
    
    public init(_ data: NSData) {
        assert(data.length == 32, "Invalid data length. It should be 32 bytes long")
        self.data = data
    }
    
    public init(_ bytes: [UInt8]) {
        assert(bytes.count == 32, "Invalid bytes count. It should be 32 items in this array")
        self.data = NSData(bytes: bytes, length: bytes.count)
    }
}

extension SHA256Hash: BitcoinSerializable {
    public var bitcoinData: NSData {
        return data.reversedData
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> SHA256Hash? {
        let hashData = stream.readData(32)
        if hashData == nil {
            print("Failed to parse hashData from SHA256Hash")
            return nil
        }
        
        return SHA256Hash(hashData!.reversedData)
    }
}
