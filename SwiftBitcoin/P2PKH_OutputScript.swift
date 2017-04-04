//
//  P2PKH_OutputScript.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/04/04.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation


public struct P2PKH_OutputScript {
    
    public let hash160: RIPEMD160HASH
    
    public init(hash160: RIPEMD160HASH) {
        self.hash160 = hash160
    }
}

extension P2PKH_OutputScript: BitcoinSerializable {
    public var bitcoinData: NSData {
        let data = NSMutableData()
        data.appendOPCode(OPCode.OP_DUP)
        data.appendOPCode(OPCode.OP_HASH160)
        data.appendUInt8(0x14) //length
        data.appendNSData(hash160.bitcoinData)
        data.appendOPCode(OPCode.OP_EQUALVERIFY)
        data.appendOPCode(OPCode.OP_CHECKSIG)
        return data
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> P2PKH_OutputScript? {
        
        if stream.readOPCode() != OPCode.OP_DUP {
            print("P2PKH_OutputScript : Not OP_DUP")
            return nil
        }
        
        if stream.readOPCode() != OPCode.OP_HASH160 {
            print("P2PKH_OutputScript : Not OP_HASH160")
            return nil
        }
        
        if stream.readUInt8() != 0x14 {
            print("P2PKH_OutputScript : Not length")
            return nil
        }
        
        guard let hash160 = RIPEMD160HASH.fromBitcoinStream(stream) else {
            print("P2PKH_OutputScript : Failed to parse RIPEMD160HASH")
            return nil
        }
        
        if stream.readOPCode() != OPCode.OP_EQUALVERIFY {
            print("P2PKH_OutputScript : Not OP_EQUALVERIFY")
            return nil
        }
        
        
        if stream.readOPCode() != OPCode.OP_CHECKSIG {
            print("P2PKH_OutputScript : Not OP_CHECKSIG")
            return nil
        }
        
        return P2PKH_OutputScript(hash160: hash160)
    }

}
