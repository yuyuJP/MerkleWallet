//
//  TransactionOutPointInfo.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/02/20.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation
import RealmSwift

class TransactionOutPointInfo: Object {
    dynamic var txHash = ""
    dynamic var index = 0
    let inputs = LinkingObjects(fromType: TransactionInputInfo.self, property: "outPoint")
    var inverse_input: TransactionInputInfo? { return inputs.first }
}
