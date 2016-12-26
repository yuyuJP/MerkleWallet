//
//  TestVersionMessage.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/10/15.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

struct Version {
    let version : UInt32 =  70001
    let services : UInt64 = 0
    let timestamp : UInt64
    let your_addr : [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00]
    //let your_addr : [UInt8] = []
    
    let my_addr : [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00]
    //let my_addr : [UInt8] = []
    
    let nonce : UInt64
    //let agent : [UInt8] = [0x0F, 0x2F, 0x53, 0x61, 0x74, 0x6F, 0x73, 0x68, 0x69, 0x3A, 0x30, 0x2E, 0x37, 0x2E, 0x32, 0x2F]
    let agent : [UInt8]
    
    let height : UInt32 = 212672
    let relay : Bool = false
    
    var bytes : [UInt8]
    
    public init() {
        self.timestamp = UInt64(NSDate().timeIntervalSince1970)
        var random : UInt64 = UInt64(arc4random_uniform(UInt32.max))
        random = random << 32
        random += UInt64(arc4random_uniform(UInt32.max))
        self.nonce = random
        
        let agentName = VarString("Swift-Samurai")
        self.agent = agentName.bytes
        
        bytes = toByteArray(version)
        bytes += toByteArray(services)
        bytes += toByteArray(timestamp)
        bytes += your_addr
        bytes += my_addr
        bytes += toByteArray(nonce)
        bytes += agent
        bytes += toByteArray(height)
        bytes += toByteArray(relay)
        
    }
    
    
}
