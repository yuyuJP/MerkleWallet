//
//  P2SH_InputScriptSig.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/04/06.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation

public struct P2SH_InputScriptSig {
    
    public let derSignatures: [NSData]
    
    public let redeemScriptData: NSData
    
    public init(derSignatures: [NSData], redeemScriptData: NSData) {
        self.derSignatures = derSignatures
        self.redeemScriptData = redeemScriptData
    }
    
    public var redeemScript: RedeemScript? {
        let stream = InputStream(data: redeemScriptData as Data)
        stream.open()
        let redeemScript = RedeemScript.fromBitcoinStream(stream)
        stream.close()
        return redeemScript
    }
    
    public var redeemScriptHash: RIPEMD160HASH {
        let ripemd = Hash160.digest(redeemScriptData)
        return RIPEMD160HASH(ripemd)
    }
}

extension P2SH_InputScriptSig: BitcoinSerializable {
    public var bitcoinData: NSData {
        let data = NSMutableData()
        data.appendOPCode(OPCode.OP_0)
        for derSignature in derSignatures {
            data.appendUInt8(UInt8(derSignature.length))
            data.appendNSData(derSignature)
        }
        data.appendOPCode(OPCode.OP_PUSHDATA1)
        data.appendUInt8(UInt8(redeemScriptData.length))
        data.appendNSData(redeemScriptData)
        return data
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> P2SH_InputScriptSig? {
        if stream.readOPCode() != OPCode.OP_0 {
            print("Failed to parse OP_0 in P2SH_InputScriptSig")
            return nil
        }
        
        var derSignatures: [NSData] = []
        
        while true {
            guard let opcode = stream.readOPCode() else {
                print("Failed to parse pushByte or OP_PUSHDATA1 in P2SH_InputScriptSig")
                return nil
            }
            
            if opcode == OPCode.OP_PUSHDATA1 {
                break
            }
            
            let length = opcode.rawValue
            guard let derSignature = stream.readData(Int(length)) else {
                print("Failed to parse derSignature in P2SH_InputScriptSig")
                return nil
            }
            derSignatures.append(derSignature)
        }
        
        guard let redeemScriptLength = stream.readUInt8() else {
            print("Failed to parse redeemScriptLength in P2SH_InputScriptSig")
            return nil
        }
        
        guard let redeemScript = stream.readData(Int(redeemScriptLength)) else {
            print("Failed to parse redeemScript in P2SH_InputScriptSig")
            return nil
        }
        
        return P2SH_InputScriptSig(derSignatures: derSignatures, redeemScriptData: redeemScript)
    }
}
