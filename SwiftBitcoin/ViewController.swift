//
//  ViewController.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/10/15.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {

    private var con : CFController!
    private var key : BitcoinTestnet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userKey = UserKeyInfo.loadAll().first {
            /*for txInfo in TransactionInfo.loadAll() {
                let output = txInfo.outputs[0]
                print(output.inverse_tx ?? "no value")
            }*/
            
            key = BitcoinTestnet(privateKeyHex: userKey.privateKey, publicKeyHex: userKey.uncompressedPublicKey)
            print(key.publicAddress)
        
        } else {
            print("No user info. Generating a new key.")
            key = BitcoinTestnet(privateKeyHex: "33260783e40b16731673622ac8a5b045fc3ea4af70f727f3f9e92bdd3a1ddc42")
            let newUserKeyInfo = UserKeyInfo.create(key: key)
            newUserKeyInfo.save()
        }
        
        bloomFilterSet(publicKeyHex: key.publicKeyHexString, publicKeyHashHex: key.publicKeyHashHex)
        
        //establishConnection()
        
        //dbTest()
    }
    
    func bloomFilterSet(publicKeyHex: String, publicKeyHashHex: String) {
        let hash_funcs : UInt32 = 10
        let tweak : UInt32 = 0
        BloomFilter.sharedFilter = BloomFilter(length: 512, hash_funcs: hash_funcs, tweak: tweak)
        
        let bloomFilter = BloomFilter.sharedFilter!
        bloomFilter.add(data: publicKeyHex.hexStringToNSData())
        bloomFilter.add(data: publicKeyHashHex.hexStringToNSData())
    }
    
    func establishConnection() {
        //con = CFController(hostname: "testnet-seed.bitcoin.schildbach.de", port: 18333, network: NetworkMagicBytes.magicBytes())
        con = CFController(hostname: "seed.tbtc.petertodd.org", port: 18333, network: NetworkMagicBytes.magicBytes())
        //con = CFController(hostname: "192.168.0.12", port: 18333, network: NetworkMagicBytes.magicBytes())
        
        con.start()
    }
    
    func dbTest() {
        /*if let userKey = UserKeyInfo.loadAll().first {
            let realm = UserKeyInfo.realm
            realm.beginWrite()
            
            let testTxoutput = TransactionOutputInfo()
            //let txInfo : [String : Any] = ["txHash" : "", "value" : 100000000, "index" : 1]
            testTxoutput.txHash = "0112728a4a1ef8052e75ac4d0d4f1804077c9554c5d1f8a728a1d3f57d48741e"
            testTxoutput.value = 100000000
            testTxoutput.index = 1
            
            userKey.txoutputs.add(testTxoutput)
            
            try! realm.commitWrite()
            
        } else {
            print("no key")
        }*/
    }
    
        
    func transactionMessageConstructTest() -> TransactionMessage {
        
        let txHash = SHA256Hash("0112728a4a1ef8052e75ac4d0d4f1804077c9554c5d1f8a728a1d3f57d48741e".hexStringToNSData())
    
        let testInputScript = "76a91432e741f1bf3264643ea5821ff9b01cad4074ab0d88ac".hexStringToNSData()
        let testOutputScriptData1 = "007a3dba76e82373a9bc545f8951863c28f84221".hexStringToNSData().reversedData
        let testOutputScriptData2 = "90b2e2241ff5ee6b60a65ec5729a773eefa3ad5f".hexStringToNSData().reversedData
        let testOutputScript1 = P2PKH_OutputScript(hash160: RIPEMD160HASH(testOutputScriptData1))
        let testOutputScript2 = P2PKH_OutputScript(hash160: RIPEMD160HASH(testOutputScriptData2))
        
        
        let outpoint = Transaction.OutPoint(transactionHash: txHash, index: 0x01)
        let input = Transaction.Input(outPoint: outpoint, scriptSignature: testInputScript, sequence: 0xffffffff)
        let output1 = Transaction.Output(value: 90000000, script: testOutputScript1.bitcoinData)
        let output2 = Transaction.Output(value: 9991801, script: testOutputScript2.bitcoinData)
        
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
    
    
    @IBAction func calculateBalance(_ sender: Any) {
        //let balance = TransactionDataStoreManager.calculateBalance()
        //print(balance)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

