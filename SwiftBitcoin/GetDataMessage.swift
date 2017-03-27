//
//  GetDataMessage.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/12/15.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public func == (left: GetDataMessage, right: GetDataMessage) -> Bool {
    return left.inventoryVectors == right.inventoryVectors
}

public struct GetDataMessage: Equatable {
    
    public let inventoryVectors: [InventoryVector]
    
    public init(inventoryVectors: [InventoryVector]) {
        assert(inventoryVectors.count > 0 && inventoryVectors.count <= 50000)
        self.inventoryVectors = inventoryVectors
    }
}

extension GetDataMessage: MessagePayload {
    
    public var command: Message.Command {
        return Message.Command.GetData
    }
    
    public var bitcoinData: NSData {
        let data = NSMutableData()
        data.appendVarInt(inventoryVectors.count)
        for inventoryVector in inventoryVectors {
            data.appendNSData(inventoryVector.bitcoinData)
        }
        return data
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> GetDataMessage? {
        guard let inventoryCount = stream.readVarInt() else {
            print("Failed to parse count from GetDataMessage")
            return nil
        }
        if inventoryCount == 0 {
            print("Failed to parse GetDataMessage. Count is zero")
            return nil
        }
        if inventoryCount > 50000 {
            print("Failed to parse GetDataMessage. Count is greater than 50000")
            return nil
        }
        var inventoryVectors: [InventoryVector] = []
        for i in 0 ..< inventoryCount {
            guard let inventoryVector = InventoryVector.fromBitcoinStream(stream) else {
                print("Failed to parse inventory vector \(i) from GetDataMessage")
                return nil
            }
            inventoryVectors.append(inventoryVector)
        }
        return GetDataMessage(inventoryVectors: inventoryVectors)
    }
}
