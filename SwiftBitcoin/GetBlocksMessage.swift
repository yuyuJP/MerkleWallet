//
//  GetBlocksMessage.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/12/14.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public func == (left: GetBlocksMessage, right: GetBlocksMessage) -> Bool {
    return left.protocolVersion == right.protocolVersion &&
        left.blockLocatorHashes == right.blockLocatorHashes &&
        left.blockHashStop == right.blockHashStop
}

public struct GetBlocksMessage: Equatable {
    
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

extension GetBlocksMessage: MessagePayload {
    
    public var command: Message.Command {
        return Message.Command.GetBlocks
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
    
    public static func fromBitcoinStream(_ stream: InputStream) -> GetBlocksMessage? {
        
        guard let protocolVersion = stream.readUInt32() else {
            print("Failed to parse protocolVersion from GetBlocksMessage")
            return nil
        }
        
        guard let hashCount = stream.readVarInt() else {
            print("Failed to parse hashCount from GetBlocksMessage")
            return nil
        }
        
        var blockLocatorHashes: [SHA256Hash] = []
        for i in 0 ..< hashCount {
            guard let blockLocatorHash = SHA256Hash.fromBitcoinStream(stream) else {
                print("Failed to parse blockLocatorHash \(i) from GetBlocksMessage")
                return nil
            }
            blockLocatorHashes.append(blockLocatorHash)
        }
        
        var blockHashStop = SHA256Hash.fromBitcoinStream(stream)
        
        if blockHashStop == nil {
            print("Failed to parse blockHashStop from GetBlocksMessage")
            return nil
        }
        
        if blockHashStop == SHA256Hash() {
            blockHashStop = nil
        }
        return GetBlocksMessage(protocolVersion: protocolVersion, blockLocatorHashes: blockLocatorHashes, blockHashStop: blockHashStop)
    }
}
