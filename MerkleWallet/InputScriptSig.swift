//
//  TransactionScriptSig.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/04/06.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation

public struct InputScriptSig {
    
    public let derSignature: NSData
    public let publicKey: NSData
    public let type: InputScriptSigType
    
    public init(derSignature: NSData, publicKey: NSData, type: InputScriptSigType) {
        self.derSignature = derSignature
        self.publicKey = publicKey
        self.type = type
    }
    
    public init?(data: NSData) {
        
        if data.length == 0 {
            return nil
        }
        
        let stream = InputStream(data: data as Data)
        stream.open()
        guard let derSignatureLength = stream.readUInt8() else {
            //print("Failed to parse derSignatureLength in P2PKH_InputScriptSig")
            return nil
        }
        
        guard let derSignature = stream.readData(Int(derSignatureLength)) else {
            //print("Failed to parse derSignature in P2PKH_InputScriptSig")
            return nil
        }
        
        guard let publicKeyLength = stream.readUInt8() else {
            //print("Failed to parse publicKeyLength in P2PKH_InputScriptSig")
            return nil
        }
        
        guard let publicKey = stream.readData(Int(publicKeyLength)) else {
            //print("Failed to parse publicKey in P2PKH_InputScriptSig")
            return nil
        }
        
        stream.close()
        
        self.derSignature = derSignature
        self.publicKey = publicKey
        
        let prefix = publicKey.toBytes()[0]
        if prefix == 0x02 || prefix == 0x03 || prefix == 0x04 {
            self.type = .P2PKH
        } else {
            self.type = .P2SH
        }
    }


    public var hash160: RIPEMD160HASH {
        let ripemd = Hash160.digest(publicKey)
        return RIPEMD160HASH(ripemd)
    }
    
    public var typeString: String {
        switch type {
        case .P2PKH:
            return "P2PKH"
        case .P2SH:
            return "P2SH"
        }
    }
    
}

