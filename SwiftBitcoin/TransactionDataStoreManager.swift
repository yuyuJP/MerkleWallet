//
//  TransactionDataStoreManager.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/02/20.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation

public class TransactionDataStoreManager {
    
    public static func add(tx: Transaction) {
        //Check if received transaction is related to mine. Bloomfiltered tx is sometimes not mine.
        let (isInputRelevant, isOutputRelevant) = isTransactionRelevant(tx)
        if !isInputRelevant && !isOutputRelevant {
            print("Received Transaction is irrelevant to my addresses")
            return
        }
        
        print("inputs are \(isInputRelevant), outputs are \(isOutputRelevant)")
        
        //If at least one of the received transaction inputs is relevant, there must be at least one output which you've already spent for and it must be already stored in the app's local DB. This method is supposed to find one, otherwise balance calculation may fail.
        if isInputRelevant {
            for input in tx.inputs {
                let txHash = input.outPoint.transactionHash.data.toHexString()
                guard let outpointTx = TransactionInfo.filter(txHash: txHash) else {
                    print("Unable to find tx \(txHash) which is used for input")
                    continue
                }
                
                let outputIndex = input.outPoint.index
                let targetOutput = outpointTx.outputs[Int(outputIndex)]
                
                targetOutput.update {
                    targetOutput.isSpent = true
                }
            }
        }
        
        let txInfo = TransactionInfo.create(tx)
        txInfo.save()
        print("tx successfully saved")
    }
    
    private static func isTransactionRelevant(_ tx: Transaction) -> (Bool, Bool) {
        var isInputMine = false
        var isOutputMine = false
        
        for key in UserKeyInfo.loadAll() {
            
            for input in tx.inputs {
                if key.publicKey == input.scriptSignatureDetail!.publicKey.toHexString() {
                    isInputMine = true
                    break
                }
            }
            
            for output in tx.outputs {
                if key.publicKeyHash == output.script.hash160.bitcoinData.toHexString() {
                    isOutputMine = true
                    break
                }
            }
        }
        
        return (isInputMine, isOutputMine)
    }
}
