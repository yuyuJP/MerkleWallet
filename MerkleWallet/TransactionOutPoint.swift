//
//  TransactionOutPoint.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/12/13.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public  func == (left: Transaction.OutPoint, right: Transaction.OutPoint) -> Bool {
    return left.transactionHash == right.transactionHash && left.index == right.index
}

public extension Transaction {
    
    public struct OutPoint: Equatable {
        
        public let transactionHash: SHA256Hash
        
        public let index: UInt32
        
        public init(transactionHash: SHA256Hash, index: UInt32) {
            self.transactionHash = transactionHash
            self.index = index
        }
    }
}

extension Transaction.OutPoint: BitcoinSerializable {
    public var bitcoinData: NSData {
        let data = NSMutableData()
        data.appendNSData(transactionHash.bitcoinData)
        data.appendUInt32(index)
        return data
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> Transaction.OutPoint? {
        guard let transactionHash = SHA256Hash.fromBitcoinStream(stream) else {
            print("Failed to parse transactionHash in Transaction.Input.Outpoint")
            return nil
        }
        
        guard let index = stream.readUInt32() else {
            print("Failed to parse index in Transaction.Input.Outpoint")
            return nil
        }
        return Transaction.OutPoint(transactionHash: transactionHash, index: index)
    }
}
