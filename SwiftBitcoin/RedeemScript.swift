//
//  RedeemScript.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/04/06.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation

public struct RedeemScript {
    
    public let publicKeys: [NSData]
    
    //Condition: n <= M <= 16
    public let OP_n: OPCode
    public let OP_M: OPCode
    
    public init(publicKeys: [NSData], OP_n: OPCode, OP_M: OPCode) {
        self.publicKeys = publicKeys
        self.OP_n = OP_n
        self.OP_M = OP_M
    }
}

extension RedeemScript: BitcoinSerializable {
    public var bitcoinData: NSData {
        let data = NSMutableData()
        data.appendOPCode(OP_n)
        for publicKey in publicKeys {
            data.appendUInt8(UInt8(publicKey.length))
            data.appendNSData(publicKey)
        }
        data.appendOPCode(OP_M)
        data.appendOPCode(OPCode.OP_CHECKMULTISIG)
        return data
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> RedeemScript? {
        guard let OP_n = stream.readOPCode() else {
            print("Failed to parse OP_n in RedeemScript")
            return nil 
        }
        
        var publicKeys: [NSData] = []
        
        let n = OP_n.OP_N_to_UInt8()
        for _ in 0 ..< n {
            guard let publicKeyLength = stream.readUInt8() else {
                print("Failed to parse publicKeyLength in TransactionInputScriptSignature")
                return nil
            }
            
            guard let publicKey = stream.readData(Int(publicKeyLength)) else {
                print("Failed to parse publicKey in TransactionInputScriptSignature")
                return nil
            }
            publicKeys.append(publicKey)
        }
        
        guard let OP_M = stream.readOPCode() else {
            print("Failed to parse OP_M in RedeemScript")
            return nil
        }
        
        if stream.readOPCode() != OPCode.OP_CHECKMULTISIG {
            print("RedeemScript : Not OP_CHECKMULTISIG")
            return nil
        }
        
        return RedeemScript(publicKeys: publicKeys, OP_n: OP_n, OP_M: OP_M)
    }
}
