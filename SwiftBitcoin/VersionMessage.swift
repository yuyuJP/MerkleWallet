//
//  VersionMessage.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/10/28.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation


public struct VersionMessage: MessagePayload {
    
    public var command: Message.Command {
        return Message.Command.Version
    }
    
    public let protocolVersion: UInt32
    public let services: PeerServices
    public let date: NSDate
    public let senderAddress: PeerAddress
    public let receiverAddress: PeerAddress
    public let nonce: UInt64
    public let userAgent: String
    public let blockStartHeight: Int32
    public let announceRelayedTransactions: Bool
    
    public init(protocolVersion: UInt32, services: PeerServices, date: NSDate, senderAddress: PeerAddress, receiverAddress: PeerAddress, nonce: UInt64, userAgent: String, blockStartHeight: Int32, announceRelayedTransactions: Bool) {
        self.protocolVersion = protocolVersion
        self.services = services
        self.date = date
        self.senderAddress = senderAddress
        self.receiverAddress = receiverAddress
        self.nonce = nonce
        self.userAgent = userAgent
        self.blockStartHeight = blockStartHeight
        self.announceRelayedTransactions = announceRelayedTransactions
    }
    
}

extension VersionMessage {
    
    public var bitcoinData: NSData {
        let data = NSMutableData()
        data.appendUInt32(protocolVersion)
        data.appendUInt64(services.rawValue)
        data.appendDateAs64BitUnixTimestamp(date)
        data.appendNSData(receiverAddress.bitcoinDataWithTimestamp(false))
        data.appendNSData(senderAddress.bitcoinDataWithTimestamp(false))
        data.appendUInt64(nonce)
        data.appendVarString(userAgent)
        data.appendInt32(blockStartHeight)
        data.appendBool(announceRelayedTransactions)
        return data
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> VersionMessage? {
        let protocolVersion = stream.readUInt32()
        if protocolVersion == nil {
            print("Failed to parse protocolVersion from VersionMessage")
            return nil
        }
        let servicesRaw = stream.readUInt64()
        if servicesRaw == nil {
            print("Failed to parse servicesRaw from VersionMessage")
            return nil
        }
        
        let services = PeerServices(rawValue: servicesRaw!)
        let timestamp = stream.readUInt64()
        if timestamp == nil {
            print("Failed to parse timestamp from VersionMessage")
            return nil
        }
        let date = NSDate(timeIntervalSince1970: TimeInterval(timestamp!))
        let receiverAddress = PeerAddress.fromBitcoinStream(stream, includeTimestamp: false)
        if receiverAddress == nil {
            print("Failed to parse receiverAddress from VersionMessage")
            return nil
        }
        let senderAddress = PeerAddress.fromBitcoinStream(stream, includeTimestamp: false)
        if senderAddress == nil {
            print("Failed to parse senderAddress from VersionMessage")
            return nil
        }
        let nonce = stream.readUInt64()
        if nonce == nil {
            print("Failed to parse nonce from VersionMessage")
            return nil
        }
        let userAgent = stream.readVarString()
        if userAgent == nil {
            print("Failed to parse userAgent from VersionMessage")
            return nil
        }
        let blockStartHeight = stream.readInt32()
        if blockStartHeight == nil {
            print("Failed to parse blockstartHeight from VersionMessage")
            return nil
        }
        let announceRelayedTransactions = stream.readBool()
        if announceRelayedTransactions == nil {
            print("Failed to parse announceRelayedTransactions from VersionMessage")
            return nil
        }
       return VersionMessage(protocolVersion: protocolVersion!, services: services, date: date, senderAddress: senderAddress!, receiverAddress: receiverAddress!, nonce: nonce!, userAgent: userAgent!, blockStartHeight: blockStartHeight!, announceRelayedTransactions: announceRelayedTransactions!)
    }
}
