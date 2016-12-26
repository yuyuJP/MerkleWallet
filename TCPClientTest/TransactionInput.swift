//
//  TransactionInput.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/12/13.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation


public func == (left: Transaction.Input, right: Transaction.Input) -> Bool {
    return left.outPoint == right.outPoint &&
        left.scriptSignature == right.scriptSignature &&
        left.sequence == right.sequence
}

public extension Transaction {
    
    public struct Input: Equatable {
        
        public let outPoint: OutPoint
        
        public let scriptSignature: NSData
        
        public let sequence: UInt32
        
        public init(outPoint: OutPoint, scriptSignature: NSData, sequence: UInt32) {
            self.outPoint = outPoint
            self.scriptSignature = scriptSignature
            self.sequence = sequence
        }
    }
}

extension Transaction.Input: BitcoinSerializable {
    
    public var bitcoinData: NSData {
        let data = NSMutableData()
        data.append(outPoint.bitcoinData as Data)
        data.appendVarInt(scriptSignature.length)
        data.append(scriptSignature as Data)
        data.appendUInt32(sequence)
        return data
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> Transaction.Input? {
        guard let outPoint = Transaction.OutPoint.fromBitcoinStream(stream) else {
            return nil
        }
        
        guard let scriptSignatureLength = stream.readVarInt() else {
            print("Failed to parse scriptSignatureLength in Transaction.Input")
            return nil
        }
        
        guard let scriptSignature = stream.readData(Int(scriptSignatureLength)) else {
            print("Failed to parse scriptSignature in Transaction.Input")
            return nil
        }
        guard let sequence = stream.readUInt32() else {
            print("Failed to parse sequence in Transaction.Input")
            return nil
        }
        
        return Transaction.Input(outPoint: outPoint, scriptSignature: scriptSignature, sequence: sequence)
        
    }
}
