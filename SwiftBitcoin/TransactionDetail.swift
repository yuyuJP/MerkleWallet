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
    public let fee: Int64
    public let txId: String
    public let timestamp: NSDate?
    
    //Set this value later when displaying transaction detail.
    public var confirmation: Int
    
    public init(tx: TransactionInfo, pubKeyPrefix: UInt8, scriptHashPrefix: UInt8) {
        
        let (relevantInputs, relevantOutputs) = TransactionDetail.extractRelevantInputsAndOutputs(tx)
        if relevantInputs.count != 0 && relevantOutputs.count == 0 {
            self.isSpentTransaction = true
            
            var inputValue: Int64 = 0
            for input in relevantInputs {
                if let outpointTx = TransactionInfo.fetch(txHash: input.outPoint!.txHash) {
                    let spentOutput = outpointTx.outputs[input.outPoint!.index]
                    inputValue += spentOutput.value
                }
            }
            self.amount = inputValue
            
        } else if relevantInputs.count == 0 && relevantOutputs.count != 0 {
            self.isSpentTransaction = false
            
            var outputVaue: Int64 = 0
            for output in relevantOutputs {
                outputVaue += output.value
            }
            self.amount = outputVaue
            
        } else {
            var inputValue: Int64 = 0
            for input in relevantInputs {
                if let outpointTx = TransactionInfo.fetch(txHash: input.outPoint!.txHash) {
                    let spentOutput = outpointTx.outputs[input.outPoint!.index]
                    inputValue += spentOutput.value
                }
            }
            
            var outputVaue: Int64 = 0
            for output in relevantOutputs {
                outputVaue += output.value
            }
            
            let diff = inputValue - outputVaue
            self.isSpentTransaction = diff > 0
            
            if self.isSpentTransaction {
                self.amount = diff
            } else {
                self.amount = -diff
            }
        }
        
        var fromAddr: [String] = []
        for input in tx.inputs {
            print(input)
            if input.type == "P2PKH" {
                fromAddr.append(input.hash160.publicKeyHashToPublicAddress(pubKeyPrefix))
            } else if input.type == "P2SH"{
                fromAddr.append(input.hash160.publicKeyHashToPublicAddress(scriptHashPrefix))
            } else {
                fromAddr.append("")
            }
        }
        
        self.fromAddresses = fromAddr
        
        var toAddr: [String] = []
        let outputs = TransactionDetail.extractOutputs(tx, isSpentTx: self.isSpentTransaction)

        for output in outputs {
            if output.type == "P2PKH" {
                toAddr.append(output.pubKeyHash.publicKeyHashToPublicAddress(pubKeyPrefix))
            } else if output.type == "P2SH" {
                toAddr.append(output.pubKeyHash.publicKeyHashToPublicAddress(scriptHashPrefix))
            } else {
                toAddr.append("")
            }
        }
        
        self.toAddresses = toAddr
        
        //Calculate fee
        var calculatedFee: Int64 = 0
        if isSpentTransaction {
            if let fee_ = tx.fee {
                calculatedFee += fee_
                
            } else {
                print("Failed to calculate fee in TransactionDetail.swift")
                calculatedFee = -1
            }
        } else {
            calculatedFee = -1
        }

        self.fee = calculatedFee
        self.txId = tx.txHash
        self.timestamp = MatchingTransactionHashInfo.timestamp(txId)
        self.confirmation = 0
        
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
    
    
    private static func extractRelevantInputsAndOutputs(_ tx: TransactionInfo) -> ([TransactionInputInfo], [TransactionOutputInfo]) {
        var inputs: [TransactionInputInfo] = []
        var outputs: [TransactionOutputInfo] = []
        
        for key in UserKeyInfo.loadAll() {
            
            for input in tx.inputs {
                if key.publicKeyHash == input.hash160 {
                    inputs.append(input)
                }
            }
            
            for output in tx.outputs {
                if key.publicKeyHash == output.pubKeyHash {
                    outputs.append(output)
                }
            }
        }
        
        return(inputs, outputs)
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
