//
//  TransactionScriptSig.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/04/06.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation

public struct InputScriptSig {
    
    public let type: InputScriptSigType
    public let P2PKH_scriptSig: P2PKH_InputScriptSig?
    public let P2SH_scriptSig: P2SH_InputScriptSig?
    
    public init(P2PKH_scriptSig: P2PKH_InputScriptSig?, P2SH_scriptSig: P2SH_InputScriptSig?, type: InputScriptSigType) {
        self.P2PKH_scriptSig = P2PKH_scriptSig
        self.P2SH_scriptSig = P2SH_scriptSig
        self.type = type
    }
    
}

