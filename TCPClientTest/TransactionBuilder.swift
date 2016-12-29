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
    public let key: BitcoinTestnet
    
    public init(transactionMessage: TransactionMessage, key: BitcoinTestnet) {
        self.transactionMessage = transactionMessage
        self.key = key
    }
    
    public var scriptSignature: NSData {
        let signature = produceDERSignature()
        let data = NSMutableData()
        print("length")
        print(UInt8(signature.length + 1))
        data.appendUInt8(UInt8(signature.length + 1))
        data.append(signature as Data)
        data.appendUInt8(0x01) //SIGHASH
        
        let publicKey = key.publicKeyPoint.toData
        data.appendUInt8(UInt8(publicKey.length))
        data.append(publicKey as Data)
        return data
    }
    
    private var transactionMessageHash: SHA256Hash {
        let sha256Data = Hash256.digest(transactionMessage.bitcoinData)
        return SHA256Hash(sha256Data)
    }
    
    private func produceDERSignature() -> NSData {
        let hash = transactionMessageHash
        let digest = BigUInt(hash.data as Data)
        let (r, s) = key.sign(digest)
        return BitcoinTestnet.der(r, s)
    }
    
}

