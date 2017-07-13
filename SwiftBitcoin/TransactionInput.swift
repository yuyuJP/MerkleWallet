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
        
        public var scriptSignature: NSData
        //public let scriptSignature: TransactionInputScriptSignature
        
        public let sequence: UInt32
        
        public init(outPoint: OutPoint, scriptSignature: NSData, sequence: UInt32) {
            self.outPoint = outPoint
            self.scriptSignature = scriptSignature
            self.sequence = sequence
        }
        
        //Use this instance for tx inputs that you received.
        public var parsedScript: InputScriptSig? {
            if let scriptSig = InputScriptSig(data: scriptSignature) {
                return scriptSig
            } else {
                return nil
            }
        }
        
        public var userKey: CoinKey? = nil
        
        /*
        public var scriptSignatureDetail: TransactionInputScriptSignature? {
            let scriptSigStream = InputStream(data: scriptSignature as Data)
            scriptSigStream.open()
            
            guard let scriptSignature = TransactionInputScriptSignature.fromBitcoinStream(scriptSigStream) else {
                return nil
            }
            
            scriptSigStream.close()
            
            return scriptSignature
        }
         */
    }
}

extension Transaction.Input: BitcoinSerializable {
    
    public var bitcoinData: NSData {
        let data = NSMutableData()
        data.appendNSData(outPoint.bitcoinData)
        data.appendVarInt(scriptSignature.length)
        data.appendNSData(scriptSignature)
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
        
        if scriptSignatureLength == 0 {
            guard let sequence = stream.readUInt32() else {
                print("Failed to parse sequence in Transaction.Input")
                return nil
            }
            
            return Transaction.Input(outPoint: outPoint, scriptSignature: NSData(), sequence: sequence)
        }
        
        guard let scriptSignatureData = stream.readData(Int(scriptSignatureLength)) else {
            print("Failed to parse scriptSignature in Transaction.Input")
            return nil
        }
        
        guard let sequence = stream.readUInt32() else {
            print("Failed to parse sequence in Transaction.Input")
            return nil
        }
        
        return Transaction.Input(outPoint: outPoint, scriptSignature: scriptSignatureData, sequence: sequence)
        
    }
}
