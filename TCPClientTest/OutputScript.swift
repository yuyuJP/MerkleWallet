//
//  OutPutScript.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/12/24.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public struct OutputScript {
    
    public let script: NSData
    
    public init(script: NSData) {
        self.script = script
    }
    
    public var hash160 : RIPEMD160HASH? {
        //P2PKH outputScript only!!
        //Need to support other script formats
        
        if self.script.length != 25 {
            print("unsupported output script")
            return nil
        }
        let stream = InputStream(data: self.script as Data)
        stream.open()
        
        if stream.readUInt8() != 0x76 {
            print("Not OP_DUP")
            return nil
        }
        
        if stream.readUInt8() != 0xa9 {
            print("Not OP_HASH160")
            return nil
        }
        
        if stream.readUInt8() != 0x14 {
            print("Not length")
            return nil
        }
        
        guard let hash160 = RIPEMD160HASH.fromBitcoinStream(stream) else {
            print("Failed to parse RIPEMD160HASH")
            return nil
        }
        
        if stream.readUInt8() != 0x88 {
            print("Not OP_EQUALVERIFY")
            return nil
        }
        
        if stream.readUInt8() != 0xac {
            print("Not OP_CHECKSIG")
            return nil
        }
        
        return hash160
    }
    
}
