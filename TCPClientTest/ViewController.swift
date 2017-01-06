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
        
        
        key = BitcoinTestnet(privateKeyHex: "2ab9b2aa6a4be7ad2ab9b2aa1c6b6a292163af6b2ab9b2aad868844dd3d22c39")
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
        let txHash = SHA256Hash("8adea22e56cab8dd8bffff9494af3ba9b36240aec10d2be4b47922843b6246dc".hexStringToNSData())
        //let txHash = SHA256Hash("faedecd95900c87c78ede096ea3527f42467fbfd32c85fcf92caa82bb8d27bd7".hexStringToNSData())
        //let txHash = SHA256Hash("fe7744dcd9ae47549273b32fa94ec87f2418c70e07039ed203e7ecf381fe10d4".hexStringToNSData())
        
        let testInputScript = "76a914a8151c512572e9cbdcf6b042f259e0b74462012e88ac".hexStringToNSData()
        let testOutputScriptData2 = "a8151c512572e9cbdcf6b042f259e0b74462012e".hexStringToNSData().reversedData
        let testOutputScriptData1 = "007a3dba76e82373a9bc545f8951863c28f84221".hexStringToNSData().reversedData
        let testOutputScript1 = OutputScript.P2PKHScript(hash160: RIPEMD160HASH(testOutputScriptData1))
        let testOutputScript2 = OutputScript.P2PKHScript(hash160: RIPEMD160HASH(testOutputScriptData2))
        
        let outpoint = Transaction.OutPoint(transactionHash: txHash, index: 0x00)
        let input = Transaction.Input(outPoint: outpoint, scriptSignature: testInputScript, sequence: 0xffffffff)
        let output1 = Transaction.Output(value: 90000000, script: testOutputScript1)
        let output2 = Transaction.Output(value: 9991800, script: testOutputScript2)
        
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

