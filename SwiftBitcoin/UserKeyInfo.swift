//
//  UserKeyInfo.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/02/17.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation
import RealmSwift

class UserKeyInfo: Object {
    static let realm = try! Realm()
    
    dynamic private var id = 0
    dynamic var privateKey = ""
    dynamic var uncompressedPublicKey = ""
    dynamic var compressedPublicKey = ""
    dynamic var publicKeyHash = ""
    dynamic var isCompressedPublicKey: Bool = false
    
    //dynamic var txoutputs = RLMArray(objectClassName: TransactionOutputInfo.className())
    var txs = List<TransactionInfo>()
    
    public var publicKey: String {
        if isCompressedPublicKey {
            return compressedPublicKey
        } else {
            return uncompressedPublicKey
        }
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func create(key: CoinKey) -> UserKeyInfo {
        let userKeyInfo = UserKeyInfo()
        userKeyInfo.id = lastId()
        userKeyInfo.privateKey = key.privateKeyHexString
        userKeyInfo.uncompressedPublicKey = key.uncompressedPublicKeyHexString
        userKeyInfo.compressedPublicKey = key.compressedPublicKeyHexString
        userKeyInfo.publicKeyHash = key.publicKeyHashHex
        userKeyInfo.isCompressedPublicKey = key.isCompressedPublicKeyAddress
        
        return userKeyInfo
    }
    
    static func loadAll() -> [UserKeyInfo] {
        let userKeyInfos = realm.objects(UserKeyInfo.self).sorted(byProperty: "id")
        var ret: [UserKeyInfo] = []
        for userKeyInfo in userKeyInfos {
            ret.append(userKeyInfo)
        }
        return ret
    }
    
    static func lastId() -> Int {
        if let userKeyInfo = realm.objects(UserKeyInfo.self).last {
            return userKeyInfo.id + 1
        } else {
            return 1
        }
    }
    
    func save() {
        try! UserKeyInfo.realm.write {
            UserKeyInfo.realm.add(self)
        }
    }
    
    func update(_ method: (() -> Void)) {
        try! UserKeyInfo.realm.write {
            method()
        }
    }
}
