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
    
    public init?(data: NSData) {
        
        if data.length == 0 {
            return nil
        }
        
        let stream_p2pkh = InputStream(data: data as Data)
        stream_p2pkh.open()
        let P2PKH_scriptSig = P2PKH_InputScriptSig.fromBitcoinStream(stream_p2pkh)
        stream_p2pkh.close()
        
        if P2PKH_scriptSig != nil {
            self.P2PKH_scriptSig = P2PKH_scriptSig
            self.P2SH_scriptSig = nil
            self.type = .P2PKH
        } else {
            let stream_p2sh = InputStream(data: data as Data)
            stream_p2sh .open()
            let P2SH_scriptSig = P2SH_InputScriptSig.fromBitcoinStream(stream_p2sh)
            stream_p2sh.close()
            
            if P2SH_scriptSig != nil {
                self.P2PKH_scriptSig = nil
                self.P2SH_scriptSig = P2SH_scriptSig
                self.type = .P2SH
            } else {
                return nil
            }
        }
    }
    
    public var hash160: RIPEMD160HASH {
        switch type {
        case .P2PKH:
            return P2PKH_scriptSig!.pubKeyHash
        case .P2SH:
            return P2SH_scriptSig!.redeemScriptHash
        
        }
    }
}

