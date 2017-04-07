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
    //dynamic var pubKey = ""
    dynamic var hash160 = ""
    
    private let txs = LinkingObjects(fromType: TransactionInfo.self, property: "inputs")
    var inverse_tx: TransactionInfo? { return txs.first }
    
    public static func create(_ input: Transaction.Input) -> TransactionInputInfo {
        let txInput = TransactionInputInfo()
        /*if let pubkey = input.scriptSignatureDetail?.publicKey.toHexString() {
            txInput.pubKey = pubkey
        }*/
        if let hash160 = input.parsedScript?.hash160 {
            txInput.hash160 = hash160.data.toHexString()
        }
        let txOutPoint = TransactionOutPointInfo.create(input.outPoint)
        txInput.outPoint = txOutPoint
        return txInput
    }
}
