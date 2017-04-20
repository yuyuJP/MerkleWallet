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
        
        let outputs = TransactionDetail.extractOutputs(tx, isSpentTx: self.isSpentTransaction)
        
        var toAddr: [String] = []
        
        var calculatedAmount: Int64 = 0
        
        for output in outputs {
            toAddr.append(output.pubKeyHash.publicKeyHashToPublicAddress(pubKeyPrefix))
            calculatedAmount += output.value
        }
        
        self.toAddresses = toAddr
        
        //Calculate fee
        if isSpentTransaction {
            if let fee = tx.fee {
                calculatedAmount += fee
                print(fee)
            } else {
                print("Failed to calculate fee in TransactionDetail.swift")
            }
        }
        
        self.amount = calculatedAmount
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
    
    private static func extractOutputs(_ tx: TransactionInfo, isSpentTx: Bool) -> [TransactionOutputInfo] {
        var myOutputs: [TransactionOutputInfo] = []
        var othersOutputs: [TransactionOutputInfo] = []
        
        for key in UserKeyInfo.loadAll() {
            
            for output in tx.outputs {
                if key.publicKeyHash == output.pubKeyHash {
                    myOutputs.append(output)
                } else {
                    othersOutputs.append(output)
                }
            }
        }
        
        if isSpentTx {
            return othersOutputs
        } else {
            return myOutputs
        }
    }
}
