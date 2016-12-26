//
//  MemPoolMessage.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/12/06.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public struct MemPoolMessage: MessagePayload {
    public init () {}
    
    public var command: Message.Command {
        return Message.Command.MemPool
    }
    
    public var bitcoinData: NSData {
        return NSData()
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> MemPoolMessage? {
        return MemPoolMessage()
    }
}
