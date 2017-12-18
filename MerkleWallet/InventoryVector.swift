//
//  InventoryVector.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/12/12.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public func == (left: InventoryVector, right: InventoryVector) -> Bool {
    return left.type == right.type && left.hash == right.hash
}

public struct InventoryVector: Equatable {
    public enum VectorType: UInt32 {
        case Error = 0, Transaction = 1, Block = 2, FilteredBlock = 3, CmpctBlock = 4
    }
    
    public let type: VectorType
    public let hash: SHA256Hash
    
    public init(type: VectorType, hash: SHA256Hash) {
        self.type = type
        self.hash = hash
    }
}

extension InventoryVector: BitcoinSerializable {
    public var bitcoinData: NSData {
        let data = NSMutableData()
        data.appendUInt32(type.rawValue)
        data.appendNSData(hash.bitcoinData)
        return data
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> InventoryVector? {
        guard let rawType = stream.readUInt32() else {
            print("Failed to parse type from InventoryVector")
            return nil
        }
        
        guard let type = VectorType(rawValue: rawType) else {
            print("Invalid type \(rawType) in InventoryVector")
            return nil
        }
        
        guard let hash = SHA256Hash.fromBitcoinStream(stream) else {
            print("Failed to parse hash from InventoryVector")
            return nil
        }
        
        return InventoryVector(type: type, hash: hash)
    }
}

extension InventoryVector: CustomStringConvertible {
    public var description: String {
        switch type {
        case .Error:
            return "ERROR \(hash)"
        case .Block:
            return "BLOCK \(hash)"
        case .Transaction:
            return "TRANSACTION \(hash)"
        case .FilteredBlock:
            return "FILTEREDBLOCK \(hash)"
        case .CmpctBlock:
            return "CMPCTBLOCK \(hash)"
        }
    }
}
