//
//  StartingBlockParameter.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/08/10.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation

let startingBlockHash: String = "000000007d9d710d666a904ff06411228df4b909f3399861acfcb7433bd21e56"
let startingBlockHeight: Int = 1180928

var latestBlockHash: String {
    let blockChainInfo = BlockChainInfo.loadItem()!
    return blockChainInfo.lastBlockHash
}

var latestBlockHeight: Int {
    let blockChainInfo = BlockChainInfo.loadItem()!
    return blockChainInfo.lastBlockHeight
}
