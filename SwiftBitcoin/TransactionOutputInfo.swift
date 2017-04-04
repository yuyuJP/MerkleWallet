//
//  TransactionOutputInfo.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/02/18.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation
import RealmSwift

class TransactionOutputInfo: Object {
    static let realm = try! Realm()
    
    dynamic var pubKeyHash = ""
    dynamic var value: Int64 = 0
    dynamic var isSpent = false
    
    private let txs = LinkingObjects(fromType: TransactionInfo.self, property: "outputs")
    var inverse_tx: TransactionInfo? { return txs.first }
    
    public static func create(_ output: Transaction.Output) -> TransactionOutputInfo {
        let outputInfo = TransactionOutputInfo()
        if let hash160 = output.parsedScript?.hash160.bitcoinData.toHexString() {
            outputInfo.pubKeyHash = hash160
        }
        
        outputInfo.value = output.value
        
        return outputInfo
    }
    
    public static func loadAll() -> [TransactionOutputInfo] {
        let txOutputInfos = realm.objects(TransactionOutputInfo.self)
        var ret: [TransactionOutputInfo] = []
        for txOutputInfo in txOutputInfos {
            ret.append(txOutputInfo)
        }
        return ret
    }
    
    public func update(_ method: (() -> Void)) {
        try! TransactionOutputInfo.realm.write {
            method()
        }
    }
}
