//
//  BitcoinTestnet.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/12/08.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public class BitcoinTestnet : CoinKey {
    public init() {
        super.init(privateKeyPrefix: 0xef, publicKeyPrefix: 0x6f)
    }
    
    public init(privateKeyHex: String) {
        super.init(privateKeyHex: privateKeyHex, privateKeyPrefix: 0xef, publicKeyPrefix: 0x6f, skipPublicKeyGeneration: false, isCompressedPublicKeyAddress: true)
    }
    
    public init(privateKeyHex: String, publicKeyHex: String) {
        super.init(privateKeyHex: privateKeyHex, publicKeyHex: publicKeyHex, privateKeyPrefix: 0xef, publicKeyPrefix: 0x6f, isCompressedPublicKeyAddress: true)
    }
    
    public init?(wif: String) {
        
        let wif_candidate = Wif(privateKeyPrefix: 0xef)
        if wif_candidate.importWif(wif) {
            super.init(privateKeyHex: wif_candidate.privateKeyHexString, privateKeyPrefix: 0xef, publicKeyPrefix: 0x6f, skipPublicKeyGeneration: false, isCompressedPublicKeyAddress: wif_candidate.isCompressedPublicKey)
        
        } else {
            return nil
        }
    }
}
