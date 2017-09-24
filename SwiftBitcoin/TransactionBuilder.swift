//
//  TransactionBuilder.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/12/29.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation
import BigInt

public class TransactionBuilder {
    public let transactionMessage: TransactionMessage
    //public let key: ECKey
    
    public init(transactionMessage: TransactionMessage) {
        self.transactionMessage = transactionMessage
    }
    
    public var transaction: Transaction {
        var inputs : [Transaction.Input] = []
        for input in transactionMessage.inputs {
            
            let transactionInput = Transaction.Input(outPoint: input.outPoint, scriptSignature: scriptSignature(input: input), sequence: input.sequence)
            inputs.append(transactionInput)
        }
        let transaction = Transaction(version: transactionMessage.version, inputs: inputs, outputs: transactionMessage.outputs)
        return transaction
    }
    
    private func scriptSignature(input: Transaction.Input) -> NSData {
        let signature = produceDERSignature(input: input)
        let data = NSMutableData()
        data.appendUInt8(UInt8(signature.length + 1))
        data.appendNSData(signature)
        data.appendUInt8(0x01) //SIGHASH
        
        let publicKey = input.userKey!.publicKeyHexString.hexStringToNSData()
        data.appendUInt8(UInt8(publicKey.length))
        data.appendNSData(publicKey)
        return data
    }
    
    //
    private func transactionMessageHash(input: Transaction.Input) ->  SHA256Hash {
        
        var txTmp = transactionMessage
        
        for i in 0 ..< txTmp.inputs.count {
            if txTmp.inputs[i] != input {
                txTmp.inputs[i].scriptSignature = NSData()
            }
        }
        
        let sha256Data = Hash256.digest(txTmp.bitcoinData)
        return SHA256Hash(sha256Data)
    }
    
    
    private func produceDERSignature(input: Transaction.Input) -> NSData {
        
        let hash = self.transactionMessageHash(input: input)
        let digest = BigUInt(hash.data as Data)
        let (r, s) = input.userKey!.sign(digest)
        
        return ECKey.der(r, s)
    }
}

