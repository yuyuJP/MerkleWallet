//
//  StartingBlockParameter.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/08/10.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation


let startingBlockHash: String = "000000000000f9562f3dff204aba802eece8d4cb38d17828f3e99bee0a5bb6c4"
let startingBlockHeight: Int = 1249180

//let startingBlockHash: String = "00000000003d04da709df109de75aeff13ff2156f280dd5b20a05d5a7457ed69"
//let startingBlockHeight: Int = 1242085

//let startingBlockHash: String = "000000003d6e2baae124ab7275f76d322d87fec31ab70e3aab54b6102bdd5641"
//let startingBlockHeight: Int = 1209840

//let startingBlockHash: String = "00000000e8ec362c3cca17ed6f7c3bd52f9c905a9a72a10c6e8299cf0736694d"
//let startingBlockHeight: Int = 1156484

var latestBlockHash: String {
    let blockChainInfo = BlockChainInfo.loadItem()!
    return blockChainInfo.lastBlockHash
}

var latestBlockHeight: Int {
    let blockChainInfo = BlockChainInfo.loadItem()!
    return blockChainInfo.lastBlockHeight
}


var firstCreatedBlock: SHA256Hash {
    
    if isBitcoinMainNet {
        return SHA256Hash("00000000839a8e6886ab5951d76f411475428afc90947ee320161bbf18eb6048".hexStringToNSData())
    } else {
        return SHA256Hash("00000000b873e79784647a6c82962c70d228557d24a747ea4d1b8bbe878e1206".hexStringToNSData())
    }

}
