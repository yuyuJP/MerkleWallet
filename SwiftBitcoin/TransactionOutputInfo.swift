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
    
    @objc dynamic var pubKeyHash = ""
    @objc dynamic var type = ""
    @objc dynamic var value: Int64 = 0
    @objc dynamic var isSpent = false
    
    private let txs = LinkingObjects(fromType: TransactionInfo.self, property: "outputs")
    var inverse_tx: TransactionInfo? { return txs.first }
    
    public static func create(_ output: Transaction.Output) -> TransactionOutputInfo {
        let outputInfo = TransactionOutputInfo()
        
        let parsedScript = output.parsedScript
        
        if let hash160 = parsedScript?.hash160.bitcoinData.toHexString() {
            outputInfo.pubKeyHash = hash160
        }
        
        if let type = parsedScript?.typeString {
            outputInfo.type = type
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
    
    public func getIndex() -> Int {
        if let parent_tx = inverse_tx {
            for (i, output) in parent_tx.outputs.enumerated() {
                if output == self {
                    return i
                }
            }
        }
        
        //When error occurs, return -1.
        return -1
    }
}
