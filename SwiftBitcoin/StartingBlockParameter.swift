//
//  StartingBlockParameter.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/08/10.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation

let startingBlockHash: String = "0000000000000470cede44606cfcc010b784d45193cc88696bf5f515eedfdd7a"
let startingBlockHeight: Int = 1178246

var latestBlockHash: String {
    let blockChainInfo = BlockChainInfo.loadItem()!
    return blockChainInfo.lastBlockHash
}

var latestBlockHeight: Int {
    let blockChainInfo = BlockChainInfo.loadItem()!
    return blockChainInfo.lastBlockHeight
}
