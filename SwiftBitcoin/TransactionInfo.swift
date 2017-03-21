//
//  TransactionInfo.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/02/20.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation
import RealmSwift

class TransactionInfo: Object {
    static let realm = try! Realm()
    
    var inputs = List<TransactionInputInfo>()
    var outputs = List<TransactionOutputInfo>()
    
    dynamic var txHash = ""
    //private let keyInfos = LinkingObjects(fromType: UserKeyInfo.self, property: "txs")
    //var inverse_keyInfo: UserKeyInfo? { return keyInfos.first }
    
    public static func create(_ tx: Transaction) -> TransactionInfo {
        let txInfo = TransactionInfo()
        txInfo.txHash = tx.hash.data.toHexString()
        
        for input in tx.inputs {
            let inputInfo = TransactionInputInfo.create(input)
            txInfo.inputs.append(inputInfo)
        }
        for output in tx.outputs {
            let outputInfo = TransactionOutputInfo.create(output)
            txInfo.outputs.append(outputInfo)
        }
        
        return txInfo
    }
    
    public static func fetch(txHash: String) -> TransactionInfo? {
        return realm.objects(TransactionInfo.self).filter("txHash == %@", txHash).first
    }
    
    public static func loadAll() -> [TransactionInfo] {
        let txInfos = realm.objects(TransactionInfo.self)
        var ret: [TransactionInfo] = []
        for txInfo in txInfos {
            ret.append(txInfo)
        }
        return ret
    }
    
    public func save() {
        try! TransactionInfo.realm.write {
            TransactionInfo.realm.add(self)
        }
    }
    
    public func update(_ method: (() -> Void)) {
        try! TransactionInfo.realm.write {
            method()
        }
    }
}
