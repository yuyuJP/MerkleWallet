//
//  GetHeadersMessage.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/11/06.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public func == (left: GetHeadersMessage, right: GetHeadersMessage) -> Bool {
    return left.protocolVersion == right.protocolVersion &&
        left.blockLocatorHashes == right.blockLocatorHashes &&
        left.blockHashStop == right.blockHashStop
}

public struct GetHeadersMessage: Equatable {
    public let protocolVersion: UInt32
    public let blockLocatorHashes: [SHA256Hash]
    public let blockHashStop: SHA256Hash?
    
    public init(protocolVersion: UInt32, blockLocatorHashes: [SHA256Hash], blockHashStop: SHA256Hash? = nil) {
        assert(blockLocatorHashes.count > 0, "Must include at least one blockHash")
        self.protocolVersion = protocolVersion
        self.blockLocatorHashes = blockLocatorHashes
        self.blockHashStop = blockHashStop
    }
}

extension GetHeadersMessage: MessagePayload {
    public var command: Message.Command {
        return Message.Command.GetHeaders
    }
    
    public var bitcoinData: NSData {
        let data = NSMutableData()
        data.appendUInt32(protocolVersion)
        data.appendVarInt(blockLocatorHashes.count)
        for blockLocatorHash in blockLocatorHashes {
            data.appendNSData(blockLocatorHash.bitcoinData)
        }
        if let hashStop = blockHashStop {
            data.appendNSData(hashStop.bitcoinData)
        } else {
            data.appendNSData(SHA256Hash().bitcoinData)
        }
        return data
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> GetHeadersMessage? {
        let protocolVersion = stream.readUInt32()
        if protocolVersion == nil {
            print("Failed to parse protocolVersion from GetHeadersMessage")
            return nil
        }
        let hashCount = stream.readVarInt()
        if hashCount == nil {
            print("Failed to parse hashCount from GetHeadersMessage")
            return nil
        }
        var blockLocatorHashes: [SHA256Hash] = []
        for _ in 0 ..< hashCount! {
            let blockLocatorHash = SHA256Hash.fromBitcoinStream(stream)
            if blockLocatorHash == nil {
                print("Failed to parse blockLocatorHash from GetHeadersMessage")
                return nil
            }
            blockLocatorHashes.append(blockLocatorHash!)
        }
        var blockHashStop = SHA256Hash.fromBitcoinStream(stream)
        if blockHashStop == nil {
            print("Failed to parse blockHashStop from GetHeadersMessage")
            return nil
        }
        if blockHashStop == SHA256Hash() {
            blockHashStop = nil
        }
        return GetHeadersMessage(protocolVersion: protocolVersion!, blockLocatorHashes: blockLocatorHashes, blockHashStop: blockHashStop)
    }
}
