//
//  Message.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/10/24.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public protocol MessagePayload: BitcoinSerializable {
    var command: Message.Command { get }
}

public struct Message {
    
    public enum Command: String {
        
        case Version = "version"
        case VersionAck = "verack"
        case Address = "addr"
        case Ping = "ping"
        case Pong = "pong"
        case GetHeaders = "getheaders"
        case Headers = "headers"
        case FilterLoad = "filterload"
        case MemPool = "mempool"
        case Transaction = "tx"
        case GetBlocks = "getblocks"
        case Inventory = "inv"
        case GetData = "getdata"
        case MerkleBlock = "merkleblock"
        case Reject = "reject"
        case GetAddress = "getaddr"
        
        public static let encodedLength = 12
        
        public var bytes: [UInt8] {
            
            var commandBytes = [UInt8]()
            for char in rawValue.utf8 {
                commandBytes += [char]
            }
            
            while true {
                if commandBytes.count >= 12 {
                    break
                }
                commandBytes += [0]
            }
            return commandBytes
        }
    }
    
    public let header: Header
    public let payload: NSData
    
    public var network : [UInt8] {
        return NetworkMagicBytes.magicBytes()
    }
    
    public var command: Command {
        return header.command
    }
    
    public var payloadChecksum: UInt32 {
        return header.payloadChecksum
    }
    
    public init(network: [UInt8], command: Command, payloadData: NSData) {
        self.header = Header(network: network, command: command, payloadLength: UInt32(payloadData.length), payloadChecksum: Message.checksumForPayload(payloadData))
        self.payload = payloadData
    }
    
    public init(network: [UInt8], payload: MessagePayload) {
        self.header = Header(network: network, command: payload.command, payloadLength: UInt32(payload.bitcoinData.length), payloadChecksum: Message.checksumForPayload(payload.bitcoinData))
        self.payload = payload.bitcoinData
    }
    
        
    public init(header: Header, payloadData: NSData) {
        self.header = header
        self.payload = payloadData
    }
    
    public func isChecksumValid() -> Bool {
        return payloadChecksum == Message.checksumForPayload(payload)
    }
    
    // MARK: - Private Methods
    
    private static func checksumForPayload(_ payload: NSData) -> UInt32 {
        let doubleSha = SHA256.digest(SHA256.digest(payload))
        var checksum : UInt32 = 0
        doubleSha.getBytes(&checksum, length: NetworkMagicBytes.checksumNum)
        return checksum
    }
}

extension Message: BitcoinSerializable {
    public var bitcoinData: NSData {
        let data = NSMutableData(data: header.bitcoinData as Data)
        data.appendNSData(payload)
        return data
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> Message? {
        let header = Header.fromBitcoinStream(stream)
        if header == nil {
            return nil
        }
        let payloadData = stream.readData()
        if payloadData == nil || payloadData!.length == 0 {
            return nil
        }
        
        return Message(header: header!, payloadData: payloadData!)
    }
}
