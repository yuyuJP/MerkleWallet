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
    }
}
