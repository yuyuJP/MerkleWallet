//
//  MessageHeader.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/10/24.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

extension Message {
    public struct Header {
        public let network : [UInt8]
        public let command: Command
        public let payloadLength: UInt32
        public let payloadChecksum: UInt32
        
        public static let length = 24
        
        public init(network: [UInt8], command: Command, payloadLength: UInt32, payloadChecksum: UInt32) {
            self.network = network
            self.command = command
            self.payloadLength = payloadLength
            self.payloadChecksum = payloadChecksum
        }
    }
}

extension Message.Header: BitcoinSerializable {
    
    public var bitcoinData: NSData {
        var bytes = network
        bytes += command.bytes
        bytes += toByteArray(payloadLength)
        bytes += toByteArray(payloadChecksum)
        
        return NSData(bytes: bytes, length: bytes.count)
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> Message.Header? {
        let networkRaw = stream.readUInt32()
        if networkRaw == nil {
            print("Failed to parse network magic value in message header")
            return nil
        }
        
        let commandRaw = stream.readASCIIStringWithLength(Message.Command.encodedLength)
        if commandRaw == nil {
            print("Failed to parse command in message header")
            return nil
        }
        let command = Message.Command(rawValue: commandRaw!)
        if command == nil {
            print("Unsupported command \(commandRaw!) in message header")
            return nil
        }
        let payloadLength = stream.readUInt32()
        if payloadLength == nil {
            print("Failed to parse size in message header")
            return nil
        }
        let payloadChecksum = stream.readUInt32()
        if payloadChecksum == nil {
            print("Failed to parse payload checksum in message header")
            return nil
        }
        
        return Message.Header(network: toByteArray(networkRaw!),command: command!,payloadLength: payloadLength!,payloadChecksum: payloadChecksum!)
        
    }
}
    

    
    
