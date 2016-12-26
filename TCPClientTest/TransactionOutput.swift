//
//  TransactionOutput.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/12/13.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public func == (left: Transaction.Output, right: Transaction.Output) -> Bool {
    return left.value == right.value && left.script == right.script
}


public extension Transaction {
    
    public struct Output: Equatable {
        
        public let value: Int64
        
        public let script: NSData
        
        public init(value: Int64, script: NSData) {
            // TODO: Validate script!!!!!!!!!
            
            self.value = value
            self.script = script
        }
    }
}

extension Transaction.Output: BitcoinSerializable {
    public var bitcoinData: NSData {
        let data = NSMutableData()
        data.appendInt64(value)
        data.appendVarInt(script.length)
        data.append(script as Data)
        return data
    }
    
    public static func  fromBitcoinStream(_ stream: InputStream) -> Transaction.Output? {
        guard let value = stream.readInt64() else {
            print("Failed to parse value from Transaction.Output")
            return nil
        }
        
        guard let scriptLength = stream.readVarInt() else {
            print("Failed to parse scriptLength from Transaction.Output")
            return nil
        }
        
        guard let script = stream.readData(Int(scriptLength)) else {
            print("Failed to parse scriptLength from Transaction.Output")
            return nil
        }
        
        return Transaction.Output(value: value, script: script)
        
    }
}
