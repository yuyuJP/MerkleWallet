//
//  PeerAddressMessage.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/08/23.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation

public func == (left: PeerAddressMessage, right: PeerAddressMessage) -> Bool {
    return left.peerAddresses == right.peerAddresses
}

public struct PeerAddressMessage: Equatable {
    
    public let peerAddresses: [PeerAddress]
    
    public init(peerAddresses: [PeerAddress]) {
        assert(peerAddresses.count > 0 && peerAddresses.count <= 1000, "PeerAddress'count is wrong. Make sure addresses are parsed properly.")
        self.peerAddresses = peerAddresses
    }
}

extension PeerAddressMessage: MessagePayload {
    
    public var command: Message.Command {
        return Message.Command.Address
    }
    
    public var bitcoinData: NSData {
        let data = NSMutableData()
        data.appendVarInt(peerAddresses.count)
        for peerAddress in peerAddresses {
            data.appendNSData(peerAddress.bitcoinData)
        }
        return data
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> PeerAddressMessage? {
        guard let count = stream.readVarInt() else {
            print("Failed to parse count from PeerAddressMessage")
            return nil
        }
        
        if count == 0 {
            print("Failed to parse PeerAddressMessage. Count is zero.")
            return nil
        }
        
        if count > 1000 {
            print("Failed to parse PeerAddressMessage. Count is greater than 1000.")
            return nil
        }
        
        var peerAddresses: [PeerAddress] = []
        for _ in 0 ..< count {
            guard let peerAddress = PeerAddress.fromBitcoinStream(stream) else {
                print("Failed to parse peerAddress from PeerAddressMessage")
                return nil
            }
            peerAddresses.append(peerAddress)
            
        }
        
        return PeerAddressMessage(peerAddresses: peerAddresses)
    }
    
}
