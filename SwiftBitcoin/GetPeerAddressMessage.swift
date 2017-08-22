//
//  GetPeerAddressMessage.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/08/23.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation

public struct GetPeerAddressMessage: MessagePayload {
    
    public var command: Message.Command {
        return Message.Command.GetAddress
    }
    
    public var bitcoinData: NSData {
        return NSData()
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> GetPeerAddressMessage? {
        return GetPeerAddressMessage()
    }
}
