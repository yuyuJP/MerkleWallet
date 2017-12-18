//
//  PeerAddress.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/10/30.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public func == (left: PeerAddress, right: PeerAddress) -> Bool {
    return left.services == right.services &&
        left.IP == right.IP &&
        left.port == right.port &&
        left.timestamp == right.timestamp
}

public struct PeerAddress: Equatable {
    public let services: PeerServices
    public let IP: IPAddress
    public let port: UInt16
    public var timestamp: NSDate?
    
    public init(services: PeerServices, IP: IPAddress, port: UInt16, timestamp: NSDate? = nil) {
        self.services = services
        self.IP = IP
        self.port = port
        self.timestamp = timestamp
    }
}

extension PeerAddress {
    
    public var bitcoinData: NSData {
        return bitcoinDataWithTimestamp(true)
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> PeerAddress? {
        return PeerAddress.fromBitcoinStream(stream, includeTimestamp: true)
    }
    
    public func bitcoinDataWithTimestamp(_ includeTimestamp: Bool) -> NSData {
        let data = NSMutableData()
        if includeTimestamp {
            if let timestamp = timestamp {
                data.appendDateAs32BitUnixTimestamp(timestamp)
            } else {
                data.appendDateAs32BitUnixTimestamp(NSDate())
            }
        }
        data.appendUInt64(services.rawValue)
        data.appendNSData(IP.bitcoinData)
        data.appendUInt16(port, endianness: .BigEndian)
        return data
    }
    
    public static func fromBitcoinStream(_ stream: InputStream, includeTimestamp: Bool) -> PeerAddress? {
        var timestamp: NSDate? = nil
        if includeTimestamp {
            timestamp = stream.readDateFrom32BitUnixTimestamp()
            if timestamp == nil {
                print("Failed to parse timestamp from PeerAddress")
                return nil
            }
        }
        
        let serviceRaw = stream.readUInt64()
        if serviceRaw == nil {
            print("Failed to parse serviceRaw from PeerAddress")
            return nil
        }
        let services = PeerServices(rawValue: serviceRaw!)
        let IP = IPAddress.fromBitcoinStream(stream)
        if IP == nil {
            print("Failed to parse IP from PeerAddress")
            return nil
        }
        let port = stream.readUInt16(.BigEndian)
        if port == nil {
            print("Failed to parse port from PeerAddress")
            return nil
        }
        return PeerAddress(services: services, IP: IP!, port: port!, timestamp: timestamp)
    }
}
