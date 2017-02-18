//
//  TransactionOutputInfo.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/02/18.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class TransactionOutputInfo: RLMObject {
    dynamic var txHash = ""
    dynamic var value: Int = 0
    dynamic var index: Int = 0
    dynamic var isUTXO: Bool = true
    private let userInfos = LinkingObjects(fromType: UserKeyInfo.self, property: "txoutputs")
    var userInfo: UserKeyInfo? { return userInfos.first }
}
