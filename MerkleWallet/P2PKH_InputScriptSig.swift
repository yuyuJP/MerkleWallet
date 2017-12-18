//
//  P2PKH_InputScriptSig.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/04/06.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation

public struct P2PKH_InputScriptSig {
    
    public let derSignature: NSData
    public let publicKey: NSData
    
    public init(derSignature: NSData, publicKey: NSData) {
        self.derSignature = derSignature
        self.publicKey = publicKey
    }
    
    var pubKeyHash: RIPEMD160HASH {
        let ripemd = Hash160.digest(publicKey)
        return RIPEMD160HASH(ripemd)
    }
}

extension P2PKH_InputScriptSig: BitcoinSerializable {
    public var bitcoinData: NSData {
        let data = NSMutableData()
        data.appendUInt8(UInt8(derSignature.length))
        data.appendNSData(derSignature)
        data.appendUInt8(UInt8(publicKey.length))
        data.appendNSData(publicKey)
        return data
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> P2PKH_InputScriptSig? {
        guard let derSignatureLength = stream.readUInt8() else {
            print("Failed to parse derSignatureLength in P2PKH_InputScriptSig")
            return nil
        }
        
        guard let derSignature = stream.readData(Int(derSignatureLength)) else {
            print("Failed to parse derSignature in P2PKH_InputScriptSig")
            return nil
        }
        
        guard let publicKeyLength = stream.readUInt8() else {
            print("Failed to parse publicKeyLength in P2PKH_InputScriptSig")
            return nil
        }
        
        guard let publicKey = stream.readData(Int(publicKeyLength)) else {
            print("Failed to parse publicKey in P2PKH_InputScriptSig")
            return nil
        }
        
        return P2PKH_InputScriptSig(derSignature: derSignature, publicKey: publicKey)
    }
}
