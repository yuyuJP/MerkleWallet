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
    //This method must be called after validaing Merkle Block and confirming the tx is really mine.
    public static func add(tx: Transaction) {

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
    
    //Set relevent UTXO's isSpent flag to true and update UTXO info.
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
    
    
    //TODO: Only P2PKH script supported. Other types of script must be supported in the near future.
    private static func extractRelevantInputs(_ tx: Transaction) -> [Transaction.Input] {
        var inputs_res: [Transaction.Input] = []
    
        for key in UserKeyInfo.loadAll() {
            
            for input in tx.inputs {
                if let extractedKey = input.scriptSignatureDetail?.publicKey.toHexString() {
                    if key.publicKey == extractedKey {
                        inputs_res.append(input)
                    }
                } 
            }
        }
        
        return inputs_res
    }
    
    /*
    private static func extractRelevantOutputs(_ tx: Transaction) -> [Transaction.Output] {
        var outputs_res: [Transaction.Output] = []
        for key in UserKeyInfo.loadAll() {
            for output in tx.outputs {
                if key.publicKeyHash == output.script.hash160.bitcoinData.toHexString() {
                    outputs_res.append(output)
                }
            }
        }
        
        return outputs_res
    }
    
    private static func extractRelevantInputsAndOutputs(_ tx: Transaction) -> ([Transaction.Input], [Transaction.Output]) {
        
        return (extractRelevantInputs(tx), extractRelevantOutputs(tx))
    }
    */
}
