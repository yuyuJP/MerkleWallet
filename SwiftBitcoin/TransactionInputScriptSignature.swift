//
//  TransactionInputScriptSignature.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/02/19.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation

public func == (left: TransactionInputScriptSignature, right: TransactionInputScriptSignature) -> Bool {
    return left.derSignature == right.derSignature && left.publicKey == right.publicKey
}

public struct TransactionInputScriptSignature: Equatable {
    
    public let derSignature: NSData
    public let publicKey: NSData
    
    public init(derSignature: NSData, publicKey: NSData) {
        self.derSignature = derSignature
        self.publicKey = publicKey
    }
}

extension TransactionInputScriptSignature: BitcoinSerializable {
    public var bitcoinData: NSData {
        let data = NSMutableData()
        data.appendUInt8(UInt8(derSignature.length))
        data.appendNSData(derSignature)
        data.appendUInt8(UInt8(publicKey.length))
        data.appendNSData(publicKey)
        return data
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> TransactionInputScriptSignature? {
        guard let derSignatureLength = stream.readUInt8() else {
            print("Failed to parse derSignatureLength in TransactionInputScriptSignature")
            return nil
        }
        
        guard let derSignature = stream.readData(Int(derSignatureLength)) else {
            print("Failed to parse derSignature in TransactionInputScriptSignature")
            return nil
        }
        
        guard let publicKeyLength = stream.readUInt8() else {
            print("Failed to parse publicKeyLength in TransactionInputScriptSignature")
            return nil
        }
        
        guard let publicKey = stream.readData(Int(publicKeyLength)) else {
            print("Failed to parse publicKey in TransactionInputScriptSignature")
            return nil
        }
        
        return TransactionInputScriptSignature(derSignature: derSignature, publicKey: publicKey)
    }
}
