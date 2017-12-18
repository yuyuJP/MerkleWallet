//
//  BitcoinTestnetNodes.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/08/23.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation

public class BitcoinTestnetNodes {
   
    public static var randomNode: String {
        let random = arc4random() % 4
        return nodes[Int(random)]
    }
    
    
    private static var nodes: [String] {
        return ["testnet-seed.bluematt.me", "testnet-seed.bitcoin.schildbach.de", "seed.tbtc.petertodd.org", "testnet-seed.bitcoin.jonasschnelli.ch"]
    }
    
}

