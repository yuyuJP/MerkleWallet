//
//  BlockInfo.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/08/10.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation
import RealmSwift

public class BlockInfo: Object {
    static let realm = try! Realm()
    
    @objc dynamic var blockHash = ""
    @objc dynamic var previousBlockHash = ""
    
    //Height ZERO means the value is not properly set yet.
    @objc dynamic var height = 0
    
    @objc dynamic var timestamp = NSDate()

    var matchingTxs = List<MatchingTransactionHashInfo>()
    
    public static func createGenesis(_ hash: String, with height: Int) -> BlockInfo {
        let blockChainInfo = BlockChainInfo()
        blockChainInfo.genesisCreated = true
        blockChainInfo.lastBlockHash = startingBlockHash
        blockChainInfo.lastBlockHeight = startingBlockHeight
        blockChainInfo.save()
        
        let blockInfo = BlockInfo()
        blockInfo.blockHash = hash
        blockInfo.height = height
        
        return blockInfo
    }
    
    public static func create(_ merkleBlock: MerkleBlockMessage) -> BlockInfo {
        let blockInfo = BlockInfo()
        blockInfo.blockHash = merkleBlock.header.hash.data.toHexString()
        
        let prevBlkHash = merkleBlock.header.previousBlockHash.data.toHexString()
        blockInfo.previousBlockHash = prevBlkHash
        
        if let previousBlk = fetch(prevBlkHash){
            
            if previousBlk.height != 0 {
                blockInfo.height = previousBlk.height + 1
            }
        } else {
            print("Failed to make a relation with a previous block in BlockInfo.swift")
        }
        
        blockInfo.timestamp = merkleBlock.header.timestamp
        
        for matchingTxHash in merkleBlock.partialMerkleTree.matchingHashes {
            let matchingTxHashStr = matchingTxHash.data.toHexString()
            let matchingBlockHashInfo = MatchingTransactionHashInfo.create(matchingTxHashStr)
            blockInfo.matchingTxs.append(matchingBlockHashInfo)
        }
        
        return blockInfo
    }
    
    public static func loadAll() -> [BlockInfo] {
        let blockInfos = realm.objects(BlockInfo.self).sorted(byKeyPath: "height")
        var ret: [BlockInfo] = []
        for blockInfo in blockInfos {
            ret.append(blockInfo)
        }
        return ret
    }
    
    public func save() {
        try! BlockInfo.realm.write {
            BlockInfo.realm.add(self)
        }
    }
    
    public func update(_ method: (() -> Void)) {
        try! BlockInfo.realm.write {
            method()
        }
    }
    
    public static func fetch(_ hash: String) -> BlockInfo? {
        return realm.objects(BlockInfo.self).filter("blockHash == %@", hash).first
    }
    
    public static func fetchOrphans() -> [BlockInfo] {
        var res: [BlockInfo] = []
         for blk in realm.objects(BlockInfo.self).filter("height == %@", 0) {
            res.append(blk)
        }
        return res
    }
    
    public static func deleteOrphans() {
        for blk in realm.objects(BlockInfo.self).filter("height == %@", 0) {
            try! realm.write {
                realm.delete(blk)
            }
        }
    }
}
