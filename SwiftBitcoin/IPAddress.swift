//
//  IPAddress.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/10/28.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public func == (left: IPAddress, right: IPAddress) -> Bool {
    switch (left, right) {
    case (let .IPV4(leftWord), let .IPV4(rightWord)):
        return leftWord == rightWord
    case (let .IPV6(leftWord0, leftWord1, leftWord2, leftWord3),
          let .IPV6(rightWord0, rightWord1, rightWord2, rightWord3)):
        return leftWord0 == rightWord0 &&
            leftWord1 == rightWord1 &&
            leftWord2 == rightWord2 &&
            leftWord3 == rightWord3
    default:
        return false
    }
}


public enum IPAddress: Equatable {
    case IPV4(UInt32)
    case IPV6(UInt32, UInt32, UInt32, UInt32)
    
    public var addressString: String? {
        switch self {
        case let .IPV4(word):
            let ip = word
            
            let byte1 = UInt8(ip & 0xff)
            let byte2 = UInt8((ip >> 8) & 0xff)
            let byte3 = UInt8((ip >> 16) & 0xff)
            let byte4 = UInt8((ip >> 24) & 0xff)
            
            return "\(byte1).\(byte2).\(byte3).\(byte4)"
            
        default:
            return nil
        }
    }
}

extension IPAddress {
    public var bitcoinData: NSData {
        let data = NSMutableData()
        
        switch self {
        case let .IPV4(word):
            data.appendUInt32(0, endianness: .BigEndian)
            data.appendUInt32(0, endianness: .BigEndian)
            data.appendUInt32(0xffff, endianness: .BigEndian)
            data.appendUInt32(word, endianness: .BigEndian)
        case let .IPV6(word0, word1, word2, word3):
            data.appendUInt32(word0, endianness: .BigEndian)
            data.appendUInt32(word1, endianness: .BigEndian)
            data.appendUInt32(word2, endianness: .BigEndian)
            data.appendUInt32(word3, endianness: .BigEndian)
        }
        
        return data
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> IPAddress? {
     
        let word0 = stream.readUInt32(.BigEndian)
        if word0 == nil {
            print("Failed to parse word0 from IPAddress")
            return nil
        }
        
        let word1 = stream.readUInt32(.BigEndian)
        if word1 == nil {
            print("Failed to parse word1 from IPAddress")
            return nil
        }
        
        let word2 = stream.readUInt32(.BigEndian)
        if word2 == nil {
            print("Failed to parse word2 from IPAddress")
            return nil
        }
        
        let word3 = stream.readUInt32(.BigEndian)
        if word3 == nil {
            print("Failed to parse word3 from IPAddress")
            return nil
        }
        
        if word0! == 0 && word1! == 0 && word2! == 0xffff {
            return IPAddress.IPV4(word3!)
        }
        return IPAddress.IPV6(word0!, word1!, word2!, word3!)
    }
}
