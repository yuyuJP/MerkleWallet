//
//  BitcoinMessage.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/10/15.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

struct BitcoinMessage {
    let magic : [UInt8]
    let command : String
    let length : UInt32
    var checkSum : [UInt8]
    let payload : [UInt8]
    
    var bytes : [UInt8]
    
    public init(command: String) {
        self.magic = NetworkMagicBytes.magicBytes()
        
        self.command = command
        
        let version = Version()
        self.payload = version.bytes
        self.length = UInt32(self.payload.count)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(payload, UInt32(payload.count), &hash)
        var hash_ = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(hash, UInt32(hash.count), &hash_)
        
        self.checkSum = [hash_[0], hash_[1], hash_[2], hash_[3]]
        
        var commandBytes = [UInt8]()
        for char in command.utf8 {
            commandBytes += [char]
        }
        
        while true {
            if commandBytes.count >= 12 {
                break
            }
            commandBytes += [0]
        }
        
        self.bytes = magic
        self.bytes += commandBytes
        self.bytes += toByteArray(length)
        self.bytes += checkSum
        self.bytes += payload
    }
    
}
