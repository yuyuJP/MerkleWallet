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
    var inputs = List<TransactionInputInfo>()
    var outputs = List<TransactionOutputInfo>()
    private let keyInfos = LinkingObjects(fromType: UserKeyInfo.self, property: "txs")
    var inverse_keyInfo: UserKeyInfo? { return keyInfos.first }
    
    public static func create(_ tx: Transaction) -> TransactionInfo {
        let txInfo = TransactionInfo()
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
}
