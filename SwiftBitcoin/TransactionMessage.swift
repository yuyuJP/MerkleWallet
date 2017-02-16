//
//  TransactionMessage.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/12/29.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation


public struct TransactionMessage {
    public let version: UInt32
    public let inputs: [Transaction.Input]
    public let outputs: [Transaction.Output]
    public let lockTime: Transaction.LockTime //= .AlwaysLocked
    public let sigHash: UInt32 //= 0x01 //temporary
    
    public init(version: UInt32, inputs: [Transaction.Input], outputs: [Transaction.Output], lockTime: Transaction.LockTime, sigHash: UInt32) {
        self.version = version
        self.inputs = inputs
        self.outputs = outputs
        self.lockTime = lockTime
        self.sigHash = sigHash
    }
    
    public var bitcoinData: NSData {
        let data = NSMutableData()
        data.appendUInt32(version)
        data.appendVarInt(inputs.count)
        for input in inputs {
            data.append(input.bitcoinData as Data)
        }
        data.appendVarInt(outputs.count)
        for output in outputs {
            data.append(output.bitcoinData as Data)
        }
        data.appendUInt32(lockTime.rawValue)
        
        data.appendUInt32(0x01) //SIGHASH
        
        return data
    }
    
}
