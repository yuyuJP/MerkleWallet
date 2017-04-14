//
//  TransactionBuilder.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/12/29.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation


public class TransactionBuilder {
    public let transactionMessage: TransactionMessage
    public let key: ECKey
    
    public init(transactionMessage: TransactionMessage, key: ECKey) {
        self.transactionMessage = transactionMessage
        self.key = key
    }
    
    public var transaction: Transaction {
        var inputs : [Transaction.Input] = []
        for input in transactionMessage.inputs {
            let transactionInput = Transaction.Input(outPoint: input.outPoint, scriptSignature: scriptSignature, sequence: input.sequence)
            inputs.append(transactionInput)
        }
        let transaction = Transaction(version: transactionMessage.version, inputs: inputs, outputs: transactionMessage.outputs)
        return transaction
    }
    
    private var scriptSignature: NSData {
        let signature = produceDERSignature()
        let data = NSMutableData()
        data.appendUInt8(UInt8(signature.length + 1))
        data.appendNSData(signature)
        data.appendUInt8(0x01) //SIGHASH
        
        //let publicKey = key.publicKeyPoint.toData
        let publicKey = key.publicKeyHexString.hexStringToNSData()
        data.appendUInt8(UInt8(publicKey.length))
        data.appendNSData(publicKey)
        return data
    }
    
    //
    private var transactionMessageHash: SHA256Hash {
        let sha256Data = Hash256.digest(transactionMessage.bitcoinData)
        return SHA256Hash(sha256Data)
    }
    
    private func produceDERSignature() -> NSData {
        let hash = self.transactionMessageHash
        let digest = BigUInt(hash.data as Data)
        let (r, s) = key.sign(digest)
        
        return ECKey.der(r, s)
    }
}

