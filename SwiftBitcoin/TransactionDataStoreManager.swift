//
//  TransactionDataStoreManager.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/02/20.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation

public class TransactionDataStoreManager {
    
    public static func add(tx: Transaction) {
        if let userKey = UserKeyInfo.loadAll().first {
            let realm = UserKeyInfo.realm
            realm.beginWrite()
            let txInfo = TransactionInfo.create(tx)
            userKey.txs.append(txInfo)
            
            try! realm.commitWrite()
        } else {
            print("ERROR : NO User Key found")
        }
        
    }
}
