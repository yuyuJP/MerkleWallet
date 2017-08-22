//
//  MatchingBlockHashInfo.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/08/10.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation
import RealmSwift

class MatchingTransactionHashInfo: Object {
    static let realm = try! Realm()
    
    dynamic var txHash = ""
    
    private let blocks = LinkingObjects(fromType: BlockInfo.self, property: "matchingTxs")
    var inverse_block: BlockInfo? { return blocks.first }
    
    public static func create(_ hash: String) -> MatchingTransactionHashInfo {
        let matchingHashInfo = MatchingTransactionHashInfo()
        
        matchingHashInfo.txHash = hash
        
        return matchingHashInfo
    }
    
    private static func fetch(_ hash: String) -> MatchingTransactionHashInfo? {
        return realm.objects(MatchingTransactionHashInfo.self).filter("txHash == %@", hash).first
    }
    
    public static func comfirmations(_ hash: String) -> Int {
        if let obj = fetch(hash) {
            if let height = obj.inverse_block?.height {
                return latestBlockHeight - height + 1
            }
        }
        //If error occurs, return -1.
        return -1
    }
}
