//
//  ViewController.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/10/15.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        

        let coinkey = CoinKey(privateKeyHex: "2ab9b2aa6a4be7ad2ab9b2aa1c6b6a292163af6b2ab9b2aad868844dd3d22c39", privateKeyPrefix: 0xef, publicKeyPrefix: 0x6f, skipPublicKeyGeneration: false)
    
        //let pubKeyData = "n3TLeMCT6vQy4QoyqCp9nPbN9s8KS86Kmk".base58StringToNSData()
        var pubKeyData = coinkey.publicAddress.base58StringToNSData().toBytes()
        for _ in 0 ..< 4 {
            pubKeyData.removeLast()
        }
        
        pubKeyData.removeFirst()
        
        let data = NSData(bytes: pubKeyData, length: pubKeyData.count)
        
        print(data)
        
        let hash_funcs : UInt32 = 10
        let tweak : UInt32 = 0
        BloomFilter.sharedFilter = BloomFilter(length: 512, hash_funcs: hash_funcs, tweak: tweak)
        
        let bloomFilter = BloomFilter.sharedFilter!
        bloomFilter.add(data: data)
        bloomFilter.add(data: coinkey.publicKeyHexString.hexStringToNSData())
        
        //bloomFilter.add(data: pubKeyHash)
        let con = CFController(hostname: "testnet-seed.bitcoin.schildbach.de", port: 18333, network: NetworkMagicBytes.magicBytes())
        
        con.start()
        
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

