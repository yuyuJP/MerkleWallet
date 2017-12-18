//
//  RIPEMD160Hash.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/12/24.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public func == (left: RIPEMD160HASH, right: RIPEMD160HASH) -> Bool {
    return left.data == right.data
}

public struct RIPEMD160HASH: Equatable {
    
    public let data: NSData
    
    public init() {
        self.data = NSMutableData(length: 20)!
    }
    
    public init(_ data: NSData) {
        assert(data.length == 20, "Invalid data length. It should be 20 bytes long")
        self.data = data
    }
    
    public init(_ bytes: [UInt8]) {
        assert(bytes.count == 20, "Invalid bytes count. It should be 20 bytes long")
        self.data = NSData(bytes: bytes, length: bytes.count)

    }
    
}

extension RIPEMD160HASH: BitcoinSerializable {
    public var bitcoinData: NSData {
        return data.reversedData
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> RIPEMD160HASH? {
        
        guard let hashData = stream.readData(20) else {
            print("Failed to parse hashData from RIPEMD160Hash")
            return nil
        }
        
        return RIPEMD160HASH(hashData.reversedData)
    }
}
