//
//  P2SH_OutputScript.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/04/04.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation


public struct P2SH_OutputScript {
    
    public let hash160: RIPEMD160HASH
    
    public init(hash160: RIPEMD160HASH) {
        self.hash160 = hash160
    }
}

extension P2SH_OutputScript: BitcoinSerializable {
    public var bitcoinData: NSData {
        let data = NSMutableData()
        data.appendOPCode(OPCode.OP_HASH160)
        data.appendUInt8(0x14)
        data.appendNSData(hash160.bitcoinData)
        data.appendOPCode(OPCode.OP_EQUAL)
        return data
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> P2SH_OutputScript? {
        
        if stream.readOPCode() != OPCode.OP_HASH160 {
            print("P2SH_OutputScript: Not OP_HASH160.")
            return nil
        }
        
        if stream.readUInt8() != 0x14 {
            print("P2SH_OutputScript : Not length")
            return nil
        }
        
        guard let hash160 = RIPEMD160HASH.fromBitcoinStream(stream) else {
            print("P2SH_OutputScript : Failed to parse RIPEMD160HASH")
            return nil
        }
        
        if stream.readOPCode() != OPCode.OP_EQUAL {
            print("P2SH_OutputScript : Not OP_EQUAL")
            return nil
        }
        return P2SH_OutputScript(hash160: hash160)
    }
}
