//
//  MatchingBlockHashInfo.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/08/10.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation
import RealmSwift

class MatchingBlockHashInfo: Object {
    dynamic var txHash = ""
    
    public static func create(_ hash: String) -> MatchingBlockHashInfo {
        let matchingHashInfo = MatchingBlockHashInfo()
        
        matchingHashInfo.txHash = hash
        
        return matchingHashInfo
    }
}
