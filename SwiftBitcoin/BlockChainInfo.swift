//
//  BlockChainInfo.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/08/10.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation
import RealmSwift


public class BlockChainInfo: Object {
    static let realm = try! Realm()
    
    dynamic var genesisCreated: Bool = false
    
    public static func loadItem() -> BlockChainInfo? {
        return realm.objects(BlockChainInfo.self).first
    }
    
    public func save() {
        try! BlockChainInfo.realm.write {
            BlockChainInfo.realm.add(self)
        }
    }
    
    
}
