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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let coinkey = BitcoinTestnet(privateKeyHex: "2ab9b2aa6a4be7ad2ab9b2aa1c6b6a292163af6b2ab9b2aad868844dd3d22c39")
        
        
        //let pubKeyData = "n3TLeMCT6vQy4QoyqCp9nPbN9s8KS86Kmk".base58StringToNSData()
        var pubKeyData = coinkey.publicAddress.base58StringToNSData().toBytes()
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
        bloomFilter.add(data: coinkey.publicKeyHexString.hexStringToNSData())
        
        con = CFController(hostname: "testnet-seed.bitcoin.schildbach.de", port: 18333, network: NetworkMagicBytes.magicBytes())
        
        con.start()
        
        //transactionMessageConstructTest()
        //testSignatureScriptFromTransactionBuilder()
        
        
    }
    
    func testSignatureScriptFromTransactionBuilder() {
        let key = BitcoinTestnet(privateKeyHex: "2ab9b2aa6a4be7ad2ab9b2aa1c6b6a292163af6b2ab9b2aad868844dd3d22c39")
        
        let transactionBulider = TransactionBuilder(transactionMessage: transactionMessageConstructTest(), key: key)
        print(transactionBulider.transaction)
    }
    
    func transactionMessageConstructTest() -> TransactionMessage {
        //let txHash = SHA256Hash("df366f0c6b64fb2006d7823bbae88bc282ea4d62f713e49831533a9ea73b94c7".hexStringToNSData())
        let txHash = SHA256Hash("fe7744dcd9ae47549273b32fa94ec87f2418c70e07039ed203e7ecf381fe10d4".hexStringToNSData())
        
        let testInputScript = "76a914a8151c512572e9cbdcf6b042f259e0b74462012e88ac".hexStringToNSData()
        let testOutputScriptData1 = "a8151c512572e9cbdcf6b042f259e0b74462012e".hexStringToNSData().reversedData
        let testOutputScriptData2 = "007a3dba76e82373a9bc545f8951863c28f84221".hexStringToNSData().reversedData
        let testOutputScript1 = OutputScript.P2PKHScript(hash160: RIPEMD160HASH(testOutputScriptData1))
        let testOutputScript2 = OutputScript.P2PKHScript(hash160: RIPEMD160HASH(testOutputScriptData2))
        
        let outpoint = Transaction.OutPoint(transactionHash: txHash, index: 0x00)
        let input = Transaction.Input(outPoint: outpoint, scriptSignature: testInputScript, sequence: 0xffffffff)
        let output1 = Transaction.Output(value: 85000000, script: testOutputScript1)
        let output2 = Transaction.Output(value: 10000000, script: testOutputScript2)
        
        let transactionMessage = TransactionMessage(version: 0x01, inputs: [input], outputs: [output1, output2], lockTime: Transaction.LockTime.AlwaysLocked, sigHash: 0x01)
        
        //print(transactionMessage.bitcoinData)
        //let hash256 = Hash256.digest(transactionMessage.bitcoinData)
        //print(hash256)
        
        return transactionMessage
    }
    
    
    @IBAction func transactionTest(_ sender: Any) {
        if con.connectionStatus() == .Connected {
            let key = BitcoinTestnet(privateKeyHex: "2ab9b2aa6a4be7ad2ab9b2aa1c6b6a292163af6b2ab9b2aad868844dd3d22c39")
            
            let transactionBulider = TransactionBuilder(transactionMessage: transactionMessageConstructTest(), key: key)
            con.sendTransaction(transaction: transactionBulider.transaction)
        }
    }
    
    func testWIF() {
        let coinkey = CoinKey(privateKeyHex: "0C28FCA386C7A227600B2FE50B7CAE11EC86D3BF1FBE471BE89827E19D72AA1D", privateKeyPrefix: 0x80, publicKeyPrefix: 0x00, skipPublicKeyGeneration: false)
        
        let wif = "5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ"
        
        print(coinkey.publicAddress)
        print(coinkey.publicKeyHexString)
        
        let result = coinkey.wif
        
        assert(result == wif, result)
        
    }
    
    func testPublicAddress() {
        let coinKey = CoinKey(privateKeyHex: "1184cd2cdd640ca42cfc3a091c51d549b2f016d454b2774019c2b2d2e08529fd", publicKeyHex: "0450863AD64A87AE8A2FE83C1AF1A8403CB53F53E486D8511DAD8A04887E5B23522CD470243453A299FA9E77237716103ABC11A1DF38855ED6F2EE187E9C582BA6", privateKeyPrefix: 0x80, publicKeyPrefix: 0x00)
        
        let result = coinKey.publicAddress
        
        
        
        
        assert(result == "16UwLL9Risc3QfPqBUvKofHmBQ7wMtjvM","")
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    


}

