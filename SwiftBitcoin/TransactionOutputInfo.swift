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
    dynamic var pubKeyHash = ""
    dynamic var value: Int64 = 0
    private let txs = LinkingObjects(fromType: TransactionInfo.self, property: "outputs")
    var inverse_tx: TransactionInfo? { return txs.first }
    
    public static func create(_ output: Transaction.Output) -> TransactionOutputInfo {
        let outputInfo = TransactionOutputInfo()
        outputInfo.pubKeyHash = output.script.hash160.bitcoinData.toHexString()
        outputInfo.value = output.value
        return outputInfo
    }
}
