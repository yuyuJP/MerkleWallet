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
    dynamic var type = ""
    
    private let txs = LinkingObjects(fromType: TransactionInfo.self, property: "inputs")
    var inverse_tx: TransactionInfo? { return txs.first }
    
    public static func create(_ input: Transaction.Input) -> TransactionInputInfo {
        let txInput = TransactionInputInfo()
        /*if let pubkey = input.scriptSignatureDetail?.publicKey.toHexString() {
            txInput.pubKey = pubkey
        }*/
        
        let parsedScript = input.parsedScript
        
        if let hash160 = parsedScript?.hash160 {
            txInput.hash160 = hash160.data.toHexString()
        } else {
            //print("Failed to register hash160 data in TransactionInputInfo.swift")
        }
        
        if let type = parsedScript?.typeString {
            txInput.type = type
        } else {
            txInput.type = "unknown"
            //print("Failed to register input type data in TransactionInputInfo.swift")
        }
        
        let txOutPoint = TransactionOutPointInfo.create(input.outPoint)
        txInput.outPoint = txOutPoint
        return txInput
    }
}
