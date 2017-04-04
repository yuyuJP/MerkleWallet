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
            self.value = value
            self.script = script
        }
        
        public var parsedScript: OutputScript? {
            if let script = OutputScript(data: script) {
                return script
            } else {
                return nil
            }
        }
        
        /*
        public var hash160: RIPEMD160HASH? {
            let stream = InputStream(data: script as Data)
            stream.open()
            
            //Extract hash160 from output script.
            if let P2PKH_script = P2PKH_OutputScript.fromBitcoinStream(stream) {
                return P2PKH_script.hash160
            }
            stream.close()
            
            let stream_ = InputStream(data: script as Data)
            stream_.open()
            
            if let P2SH_script = P2SH_OutputScript.fromBitcoinStream(stream_) {
                return P2SH_script.hash160
            }
            stream_.close()
            
            return nil
        }
         */
    }
}

extension Transaction.Output: BitcoinSerializable {
    public var bitcoinData: NSData {
        let data = NSMutableData()
        data.appendInt64(value)
        data.appendVarInt(script.length)
        data.appendNSData(script)
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
        
        /*
        if scriptLength != 25 {
            print("Not Supported Script. Script Length must be 25. P2PKH Script is currently only supported")
            return nil
        }
        */
        
        guard let script = stream.readData(Int(scriptLength)) else {
            print("Failed to parse scriptLength from Transaction.Output")
            return nil
        }
        
        /*
        guard let script = OutputScript.P2PKHScript.fromBitcoinStream(stream) else {
            print("Failed to parse P2PKH Script from Transaction.Output")
            return nil
        }
         */
        
        return Transaction.Output(value: value, script: script)
        
    }
}
