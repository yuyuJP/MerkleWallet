//
//  FilterLoadMessage.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/12/06.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public func == (left: FilterLoadMessage, right: FilterLoadMessage) -> Bool {
    return left.filter == right.filter &&
        left.numHashFunctions == right.numHashFunctions &&
        left.tweak == right.tweak &&
        left.flags == right.flags
}

public struct FilterLoadMessage: Equatable {
    public static let maxFilterLength = 36_000
    public static let maxNumHashFunctions: UInt32 = 50
    
    public let filter: NSData
    public let numHashFunctions: UInt32
    public let tweak: UInt32
    public let flags: UInt8
    
    public init(filter: NSData, numHashFunctions: UInt32, tweak: UInt32, flags: UInt8) {
        self.filter = filter
        self.numHashFunctions = numHashFunctions
        self.tweak = tweak
        self.flags = flags
    }
}

extension FilterLoadMessage: MessagePayload {
    
    public var command: Message.Command {
        return Message.Command.FilterLoad
    }
    
    public var bitcoinData: NSData {
        let data = NSMutableData()
        data.appendVarInt(filter.length)
        data.appendNSData(filter)
        data.appendUInt32(numHashFunctions)
        data.appendUInt32(tweak)
        data.appendUInt8(flags)
        return data
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> FilterLoadMessage? {
        guard let filterLength = stream.readVarInt() else {
            print("Failed to parse filterLength from FilterLoadMessage")
            return nil
        }
        
        if filterLength <= UInt64(0) || filterLength > UInt64(FilterLoadMessage.maxFilterLength) {
            print("Invalid filterLength \(filterLength) in FilterLoadMessage")
            return nil
        }
        
        guard let filter = stream.readData(Int(filterLength)) else {
            print("Failed to parse filter from FilterLoadMessage")
            return nil
        }
        
        guard let numHashFunctions = stream.readUInt32() else {
            print("Failed to parse numHashFunctions from FilterLoadMessage")
            return nil
        }
        
        guard let tweak = stream.readUInt32() else {
            print("Failed to parse tweak from FilterLoadMessage")
            return nil
        }
        
        guard let flags = stream.readUInt8() else {
            print("Failed to parse flags from FilterLoadMessage")
            return nil
        }
        
        return FilterLoadMessage(filter: filter, numHashFunctions: numHashFunctions, tweak: tweak, flags: flags)
    }
}
