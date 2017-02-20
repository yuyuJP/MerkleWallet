//
//  TransactionInputInfo.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/02/20.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation
import RealmSwift

class TransactionInputInfo: Object {
    dynamic var outPoint : TransactionOutPointInfo?
    dynamic var pubKeyHash = ""
    private let txs = LinkingObjects(fromType: TransactionInfo.self, property: "input")
    var inverse_tx: TransactionInfo? { return txs.first }
}
