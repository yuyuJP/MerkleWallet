//
//  PingMessage.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/10/07.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation

public func == (left: PingMessage, right: PingMessage) -> Bool {
    return left.nonce == right.nonce
}

public struct PingMessage: Equatable {
    
    public var nonce: UInt64
    
    public init(nonce: UInt64? = nil) {
        if let nonce = nonce {
            self.nonce = nonce
        } else {
            self.nonce = UInt64(arc4random()) | (UInt64(arc4random()) << 32)
        }
    }
}

extension PingMessage: MessagePayload {
    
    public var command: Message.Command {
        return Message.Command.Ping
    }
    
    public var bitcoinData: NSData {
        let data = NSMutableData()
        data.appendUInt64(nonce)
        return data
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> PingMessage? {
        guard let nonce = stream.readUInt64() else {
            print("Failed to parse nonce from PingMessage")
            return nil
        }
        return PingMessage(nonce: nonce)
    }
}
