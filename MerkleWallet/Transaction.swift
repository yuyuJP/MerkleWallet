//
//  Transaction.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/12/13.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation


public func == (left: Transaction, right: Transaction) -> Bool {
    return left.version == right.version &&
        left.inputs == right.inputs &&
        left.outputs == right.outputs &&
        left.lockTime == right.lockTime
}

public protocol TransactionParameters {
    var transactionVersion: UInt32 { get }
}


public struct Transaction: Equatable {
    
    public let version: UInt32
    public let inputs: [Input]
    public let outputs: [Output]
    public let lockTime: LockTime
    
    public init(version: UInt32, inputs: [Input], outputs: [Output], lockTime: LockTime = .AlwaysLocked) {
        assert(outputs.count > 0, "tx message must have at least one output")
        self.version = version
        self.inputs = inputs
        self.outputs = outputs
        self.lockTime = lockTime
    }
    
    public init(params: TransactionParameters, inputs: [Input], outputs: [Output], lockTime: LockTime = .AlwaysLocked) {
        self.init(version: params.transactionVersion,inputs: inputs,outputs: outputs,lockTime: lockTime)
    }
    
    public var hash: SHA256Hash {
        let data = Hash256.digest(bitcoinData)
        return SHA256Hash(data.reversedData)
    }
}

extension Transaction: MessagePayload {
    
    public var command: Message.Command {
        return Message.Command.Transaction
    }
    
    public var bitcoinData: NSData {
        let data = NSMutableData()
        data.appendUInt32(version)
        data.appendVarInt(inputs.count)
        for input in inputs {
            data.appendNSData(input.bitcoinData)
        }
        data.appendVarInt(outputs.count)
        for output in outputs {
            data.appendNSData(output.bitcoinData)
        }
        data.appendUInt32(lockTime.rawValue)
        return data
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> Transaction? {
        guard let version = stream.readUInt32() else {
            print("Failed to parse version in Transaction")
            return nil
        }
        guard let inputCount = stream.readVarInt() else {
            print("Failed to parse inputCount in Transaction")
            return nil
        }
        var inputs: [Input] = []
        for i in 0 ..< inputCount {
            guard let input = Input.fromBitcoinStream(stream) else {
                print("Failed to parse input at index \(i) in Transaction")
                return nil
            }
            inputs.append(input)
        }
        if inputs.count == 0 {
            print("Failed to parse inputs. No inputs found")
            return nil
        }
        
        guard let outputCount = stream.readVarInt() else {
            print("Failed to parse outputCount in Transaction")
            return nil
        }
        var outputs: [Output] = []
        for i in 0 ..< outputCount {
            guard let output = Output.fromBitcoinStream(stream) else {
                print("Failed to parse output at index \(i) in Transaction")
                return nil
            }
            outputs.append(output)
        }
        if outputs.count == 0 {
            print("Failed to parse outputs. No outputs found")
            return nil
        }
        guard let lockTimeRaw = stream.readUInt32() else {
            print("Failed to parse lockTime in Transaction")
            return nil
        }
        guard let lockTime = LockTime.fromRaw(lockTimeRaw) else {
            print("Invalid LockTime \(lockTimeRaw) in Transaction")
            return nil
        }
        
        return Transaction(version: version, inputs: inputs, outputs: outputs, lockTime: lockTime)
    }
}
