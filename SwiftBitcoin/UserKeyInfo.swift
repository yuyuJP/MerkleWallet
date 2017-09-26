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
    
    @objc dynamic private var id = 0
    @objc dynamic var privateKey = ""
    @objc dynamic var uncompressedPublicKey = ""
    @objc dynamic var compressedPublicKey = ""
    @objc dynamic var publicKeyHash = ""
    @objc dynamic var isCompressedPublicKey: Bool = false
    
    var UTXOs = List<TransactionOutputInfo>()
    
    public var balance: Int64 {
        var balance: Int64 = 0
        for utxo in UTXOs {
            balance += utxo.value
        }
        return balance
    }
    
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
    
    public static func create(key: CoinKey) -> UserKeyInfo {
        let userKeyInfo = UserKeyInfo()
        userKeyInfo.id = lastId()
        userKeyInfo.privateKey = key.privateKeyHexString
        userKeyInfo.uncompressedPublicKey = key.uncompressedPublicKeyHexString
        userKeyInfo.compressedPublicKey = key.compressedPublicKeyHexString
        userKeyInfo.publicKeyHash = key.publicKeyHashHex
        userKeyInfo.isCompressedPublicKey = key.isCompressedPublicKeyAddress
        
        return userKeyInfo
    }
    
    public static func loadAll() -> [UserKeyInfo] {
        let userKeyInfos = realm.objects(UserKeyInfo.self).sorted(byKeyPath: "id")
        var ret: [UserKeyInfo] = []
        for userKeyInfo in userKeyInfos {
            ret.append(userKeyInfo)
        }
        return ret
    }
    
    public static func lastId() -> Int {
        if let userKeyInfo = realm.objects(UserKeyInfo.self).last {
            return userKeyInfo.id + 1
        } else {
            return 1
        }
    }
    
    public func save() {
        try! UserKeyInfo.realm.write {
            UserKeyInfo.realm.add(self)
        }
    }
    
    public func update(_ method: (() -> Void)) {
        try! UserKeyInfo.realm.write {
            method()
        }
    }
}
