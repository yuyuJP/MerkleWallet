//
//  ViewController.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/10/15.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    private var con : CFController!
    private var key : BitcoinTestnet!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //key = BitcoinTestnet(privateKeyHex: "2ab9b2aa6a4be7ad2ab9b2aa1c6b6a292163af6b2ab9b2aad868844dd3d22c39")
        //key = BitcoinTestnet(privateKeyHex: "16260783e40b16731673622ac8a5b045fc3ea4af70f727f3f9e92bdd3a1ddc42")
        key = BitcoinTestnet(privateKeyHex: "33260783e40b16731673622ac8a5b045fc3ea4af70f727f3f9e92bdd3a1ddc42")
        print(key.publicAddress)
        print(key.publicKeyHexString)
        //key = BitcoinTestnet(privateKeyHex: "a0dc65ffca799873cbea0ac274015b9526505daaaed385155425f7337704883e")
        //let pubKeyData = "n3TLeMCT6vQy4QoyqCp9nPbN9s8KS86Kmk".base58StringToNSData()
        
        var pubKeyData = key.publicAddress.base58StringToNSData().toBytes()
        for _ in 0 ..< 4 {
            pubKeyData.removeLast()
        }
        
        pubKeyData.removeFirst()
        
        let data = NSData(bytes: pubKeyData, length: pubKeyData.count)
        
        let hash_funcs : UInt32 = 10
        let tweak : UInt32 = 0
        BloomFilter.sharedFilter = BloomFilter(length: 512, hash_funcs: hash_funcs, tweak: tweak)
        
        let bloomFilter = BloomFilter.sharedFilter!
        bloomFilter.add(data: data)
        bloomFilter.add(data: key.publicKeyHexString.hexStringToNSData())
        
        con = CFController(hostname: "testnet-seed.bitcoin.schildbach.de", port: 18333, network: NetworkMagicBytes.magicBytes())
        //con = CFController(hostname: "192.168.0.12", port: 18333, network: NetworkMagicBytes.magicBytes())
        
        //con.start()
        
    }
    
    func transactionMessageConstructTest() -> TransactionMessage {
        //let txHash = SHA256Hash("8adea22e56cab8dd8bffff9494af3ba9b36240aec10d2be4b47922843b6246dc".hexStringToNSData())
        //let txHash_ = SHA256Hash("ed8dea3271fca5e1bf448c8551dca826dd1b297c3139c5c263d41647082b7b08".hexStringToNSData())
        let txHash = SHA256Hash("0112728a4a1ef8052e75ac4d0d4f1804077c9554c5d1f8a728a1d3f57d48741e".hexStringToNSData())
        //print(txHash_)
        //print(txHash)
        //let testInputScript = "76a914a8151c512572e9cbdcf6b042f259e0b74462012e88ac".hexStringToNSData()
        let testInputScript = "76a91432e741f1bf3264643ea5821ff9b01cad4074ab0d88ac".hexStringToNSData()
        let testOutputScriptData1 = "007a3dba76e82373a9bc545f8951863c28f84221".hexStringToNSData().reversedData
        let testOutputScriptData2 = "90b2e2241ff5ee6b60a65ec5729a773eefa3ad5f".hexStringToNSData().reversedData
        let testOutputScript1 = OutputScript.P2PKHScript(hash160: RIPEMD160HASH(testOutputScriptData1))
        let testOutputScript2 = OutputScript.P2PKHScript(hash160: RIPEMD160HASH(testOutputScriptData2))
        
        
        let outpoint = Transaction.OutPoint(transactionHash: txHash, index: 0x01)
        let input = Transaction.Input(outPoint: outpoint, scriptSignature: testInputScript, sequence: 0xffffffff)
        let output1 = Transaction.Output(value: 90000000, script: testOutputScript1)
        let output2 = Transaction.Output(value: 9991801, script: testOutputScript2)
        
        let transactionMessage = TransactionMessage(version: 0x01, inputs: [input], outputs: [output1, output2], lockTime: Transaction.LockTime.AlwaysLocked, sigHash: 0x01)
        
        return transactionMessage
    }
    
    
    @IBAction func transactionTest(_ sender: Any) {
        //if czon.connectionStatus() == .Connected {
            
            let transactionBulider = TransactionBuilder(transactionMessage: transactionMessageConstructTest(), key: key)
            //print(transactionBulider.transactionMessageHash)
            print(transactionBulider.transaction.bitcoinData.toHexString())
            //con.sendTransaction(transaction: transactionBulider.transaction)
        //}
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

