//
//  BlockDataStoreManager.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/08/10.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation
import RealmSwift

public class BlockDataStoreManager {
    
    public static func add(merkleBlockMsg: MerkleBlockMessage) {
        let blockInfo = BlockInfo.create(merkleBlockMsg)
        blockInfo.save()
        
        if blockInfo.height != 0 {
            let blockChainInfo = BlockChainInfo.loadItem()!
            blockInfo.update {
                blockChainInfo.lastBlockHash = blockInfo.blockHash
                blockChainInfo.lastBlockHeight = blockInfo.height
            }
        }
        
        for orphanBlk in BlockInfo.fetchOrphans() {
            if let previousBlk = BlockInfo.fetch(orphanBlk.previousBlockHash){
                orphanBlk.update {
                    orphanBlk.height = previousBlk.height + 1
                }
            }
        }
        
    }
}
