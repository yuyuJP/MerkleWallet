//
//  TransactionDataStoreManager.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/02/20.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation
import RealmSwift

public class TransactionDataStoreManager {
    //This method must be called after validaing Merkle Block.
    public static func add(tx: Transaction) {
        
        //Check if the tx is already received and stored in the local-DB.
        if let _ = TransactionInfo.fetch(txHash: tx.hash.data.toHexString()) {
            return
        }
        
        let txInfo = TransactionInfo.create(tx)
        txInfo.save()
        
        let extractedInputs = extractRelevantInputs(tx)
        if extractedInputs.count != 0 {
            incomingInputCheck(extractedInputs)
        }
        
        updateUTXOInfo()
        
        let balance = calculateBalance()
        print(balance)
    }
    
    public static func calculateBalance() -> Int64 {
        var balance: Int64 = 0
        
        for userkey in UserKeyInfo.loadAll() {
            balance += userkey.balance
        }
        
        return balance
    }
    
    //Set relevant UTXO's isSpent flag to true and update UTXO info.
    private static func incomingInputCheck(_ inputs: [Transaction.Input]) {
        for input in inputs {
            
            let txHash = input.outPoint.transactionHash.data.toHexString()
            guard let outpointTx = TransactionInfo.fetch(txHash: txHash) else {
                continue
            }
            
            let outputIndex = input.outPoint.index
            let targetOutput = outpointTx.outputs[Int(outputIndex)]
            
            targetOutput.update {
                targetOutput.isSpent = true
            }
        }
    }
    
    private static func updateUTXOInfo() {
        
        for userkey in UserKeyInfo.loadAll() {
            
            userkey.update {
                //Delete all old chached UTXOs first.
                userkey.UTXOs.removeAll()
            }
            
            let txs = TransactionInfo.loadAll()
            for tx in txs {
                for output in tx.outputs {
                    if userkey.publicKeyHash == output.pubKeyHash && !output.isSpent {
                        userkey.update {
                            userkey.UTXOs.append(output)
                        }
                    }
                }
            }
        }
    }
    
    private static func extractRelevantInputs(_ tx: Transaction) -> [Transaction.Input] {
        var inputs_res: [Transaction.Input] = []
    
        for key in UserKeyInfo.loadAll() {
            
            for input in tx.inputs {
                if let extractedKeyHash = input.parsedScript?.hash160.data.toHexString() {
                    if key.publicKeyHash == extractedKeyHash {
                        inputs_res.append(input)
                    }
                }
            }
        }
        
        return inputs_res
    }
    
    
}
