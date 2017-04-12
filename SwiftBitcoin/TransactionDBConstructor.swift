//
//  TransactionDBConstructor.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/04/12.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation


public class TransactionDBConstructor {
    
    private let key: CoinKey
    
    private let sendAmount: Int64
    
    //Hash160 of public address.
    private let addressHash160: RIPEMD160HASH

    private let fee: Int64
    
    public init(key: CoinKey, sendAmount: Int64, to: RIPEMD160HASH, fee: Int64 = 0) {
        self.key = key
        self.sendAmount = sendAmount
        self.addressHash160 = to
        self.fee = fee
    }
    
    public var transaction: Transaction? {
        guard let txMessage = generateTransactionMessage(amount: self.sendAmount, fee: self.fee) else {
            return nil
        }
        let txBuilder = TransactionBuilder(transactionMessage: txMessage, key: key)
        
        return txBuilder.transaction
    }
    
    private func generateTransactionMessage(amount: Int64, fee: Int64) -> TransactionMessage? {
        var balance: Int64 = 0
        
        for userkey in UserKeyInfo.loadAll() {
            balance += userkey.balance
        }
        
        if balance < amount {
            print("Unable to build transaction. Insufficient amount.")
            return nil
        }

        guard let (inputs, sum) = inputOfTransactionMessage(amount, fee: fee) else {
            return nil
        }
        
        let change = sum - amount - fee
        
        let outputs = outputOfTransactionMessage(addressHash160, amount: amount, change: change)
        
        let transactionMessage = TransactionMessage(version: 0x01, inputs: inputs, outputs: outputs, lockTime: .AlwaysLocked, sigHash: 0x01)
        return transactionMessage
    }
    
    //Generate inputs for building "signature" transaction(TransactionMessage) and sum amount of inputs for change calculation
    private func inputOfTransactionMessage(_ amount: Int64, fee: Int64) -> ([Transaction.Input], Int64)?  {
        
        var inputs: [Transaction.Input] = []
        var sum: Int64 = 0
        
        for_i: for userkey in UserKeyInfo.loadAll() {
            for utxo in userkey.UTXOs {
                guard let txHashStr = utxo.inverse_tx?.txHash else {
                    print("Unable to find txHash from utxo in TransactionDBConstructor.swift")
                    return nil
                }
                
                let txHash = SHA256Hash(txHashStr.hexStringToNSData())
                
                let index = utxo.getIndex()
                if index == -1 {
                    print("Unable to retrieve index from utxo in TransactionDBConstructor.swift")
                    return nil
                }
                
                let userHash160 = RIPEMD160HASH(userkey.publicKeyHash.hexStringToNSData().reversedData)
                let inputScript = P2PKH_OutputScript(hash160: userHash160)
            
                let outpoint = Transaction.OutPoint(transactionHash: txHash, index: UInt32(index))
                let input = Transaction.Input(outPoint: outpoint, scriptSignature: inputScript.bitcoinData, sequence: 0xffffffff)
                inputs.append(input)
                
                sum += utxo.value
                
                if sum >= amount + fee {
                    break for_i
                }
            }
        }
        
        if inputs.count == 0 {
            assert(false, "Unable to find input, although desired amount is not insufficient.")
        }
        
        return (inputs, sum)
    }
    
    private func outputOfTransactionMessage(_ addressHash160: RIPEMD160HASH, amount: Int64, change: Int64) -> [Transaction.Output] {
        
        var outputs: [Transaction.Output] = []
        
        let outputScript = P2PKH_OutputScript(hash160: addressHash160)
        let output = Transaction.Output(value: amount, script: outputScript.bitcoinData)
        outputs.append(output)
        
        if change > 0 {
            if let userKey = UserKeyInfo.loadAll().first {
                let changeOutputScript = P2PKH_OutputScript(hash160: RIPEMD160HASH(userKey.publicKeyHash.hexStringToNSData().reversedData))
                let changeOutput = Transaction.Output(value: change, script: changeOutputScript.bitcoinData)
                outputs.append(changeOutput)
            }
        }
        
        return outputs
    }
}
