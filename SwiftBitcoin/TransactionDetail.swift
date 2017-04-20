//
//  TransactionDetail.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/04/19.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation

public class TransactionDetail {
    
    public let isSpentTransaction: Bool
    public let fromAddresses: [String]
    public let toAddresses: [String]
    public let amount: Int64
    public let txId: String
    
    
    public init(tx: TransactionInfo, pubKeyPrefix: UInt8) {
        self.isSpentTransaction = TransactionDetail.isSpentCheck(tx)
        var fromAddr: [String] = []
        for input in tx.inputs {
            fromAddr.append(input.hash160.publicKeyHashToPublicAddress(pubKeyPrefix))
        }
        
        self.fromAddresses = fromAddr
        self.toAddresses = ["Empty address"]
        self.amount = 0
        self.txId = tx.txHash
    }
    
    private static func isSpentCheck(_ tx: TransactionInfo) -> Bool {
        
        for key in UserKeyInfo.loadAll() {
            
            for input in tx.inputs {
                if  key.publicKeyHash == input.hash160 {
                    return true
                }
            }
        }
        return false
    }
}
