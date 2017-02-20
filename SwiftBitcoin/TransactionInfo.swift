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
    dynamic var input: TransactionInputInfo?
    dynamic var output: TransactionOutputInfo?
    private let keyInfos = LinkingObjects(fromType: UserKeyInfo.self, property: "txs")
    var inverse_keyInfo: UserKeyInfo? { return keyInfos.first }
}
