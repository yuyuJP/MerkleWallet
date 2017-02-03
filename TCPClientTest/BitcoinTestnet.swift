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
}
