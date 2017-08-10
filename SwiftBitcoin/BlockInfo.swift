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
    
    dynamic var blockHash = ""
    
    //Height ZERO means the value is not properly set yet.
    dynamic var height = 0

    var matchingTxs = List<MatchingBlockHashInfo>()
    
    public static func genesisCreate(_ hash: String, with height: Int) -> BlockInfo {
        let blockChainInfo = BlockChainInfo()
        blockChainInfo.genesisCreated = true
        blockChainInfo.save()
        
        let blockInfo = BlockInfo()
        blockInfo.blockHash = hash
        blockInfo.height = height
        
        return blockInfo
    }
    
    public static func create(_ merkleBlock: MerkleBlockMessage) -> BlockInfo {
        let blockInfo = BlockInfo()
        blockInfo.blockHash = merkleBlock.header.hash.data.toHexString()
        if let previousBlk = fetch(merkleBlock.header.previousBlockHash.data.toHexString()){
            blockInfo.height = previousBlk.height + 1
        } else {
            print("Failed to make a relation with previous block in BlockInfo.swift")
        }
        
        for matchingTxHash in merkleBlock.partialMerkleTree.matchingHashes {
            let matchingTxHashStr = matchingTxHash.data.toHexString()
            let matchingBlockHashInfo = MatchingBlockHashInfo.create(matchingTxHashStr)
            blockInfo.matchingTxs.append(matchingBlockHashInfo)
        }
        
        return blockInfo
    }
    
    public static func loadAll() -> [BlockInfo] {
        let blockInfos = realm.objects(BlockInfo.self).sorted(byProperty: "height")
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

}
