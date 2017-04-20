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
            //print(key.publicKeyHashHex)
        
        } else {
            print("No user info. Generating a new key.")
            //key = BitcoinTestnet(privateKeyHex: "33260783e40b16731673622ac8a5b045fc3ea4af70f727f3f9e92bdd3a1ddc42")
            key = BitcoinTestnet()
            
            let newUserKeyInfo = UserKeyInfo.create(key: key)
            newUserKeyInfo.save()
        }
        
        print(key.publicAddress)
        
        bloomFilterSet(publicKeyHex: key.publicKeyHexString, publicKeyHashHex: key.publicKeyHashHex)
        
        //establishConnection()
        //txGenerateFromLocalDBTest()
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
    
    func txGenerateFromLocalDBTest() {
        if let addressHash160 = "mfZUjWuPJ4j7PvnNKSPvVuq5NWNUoPx3Pq".publicAddressToPubKeyHash(key.publicKeyPrefix) {
            let txConstructor = TransactionDBConstructor(privateKeyPrefix: 0xef, publicKeyPrefix: 0x6f, sendAmount: 50000000, to: RIPEMD160HASH(addressHash160.hexStringToNSData().reversedData), fee: 9000)
            print(txConstructor.transaction?.bitcoinData.toHexString())
        }
        
    }
    
    
    @IBAction func transactionTest(_ sender: Any) {
        
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

