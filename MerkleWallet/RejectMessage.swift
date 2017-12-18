//
//  RejectMessage.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2017/01/04.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation

public func ==(left: RejectMessage, right: RejectMessage) -> Bool {
    return left.rejectedCommand == right.rejectedCommand &&
        left.code == right.code &&
        left.reason == right.reason &&
        left.hash == right.hash
}


public struct RejectMessage: Equatable {
    public enum Code: UInt8 {
        case Malformed = 0x01
        case Invalid = 0x10
        case Obsolete = 0x11
        case Duplicate = 0x12
        case NonStandard = 0x40
        case Dust = 0x41
        case InsufficientFee = 0x42
        case Checkpoint = 0x43
    }
    
    public let rejectedCommand: Message.Command
    public let code: Code
    public let reason: String
    public let hash: SHA256Hash?
    
    public init(rejectedCommand: Message.Command, code: Code, reason: String, hash: SHA256Hash? = nil) {
        self.rejectedCommand = rejectedCommand
        self.code = code
        self.reason = reason
        self.hash = hash
    }
}

extension RejectMessage: MessagePayload {
    public var command: Message.Command {
        return Message.Command.Reject
    }
    
    public var bitcoinData: NSData {
        let data = NSMutableData()
        data.appendVarString(rejectedCommand.rawValue)
        data.appendUInt8(code.rawValue)
        data.appendVarString(reason)
        if let hash = self.hash  {
            data.appendNSData(hash.bitcoinData)
        }
        return data
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> RejectMessage? {
        guard let rawCommand = stream.readVarString() else {
            print("Failed to parse rawCommand from RejectMessage")
            return nil
        }
        guard let command = Message.Command(rawValue: rawCommand) else {
            print("Invalid command \(rawCommand) from RejectMessage")
            return nil
        }
        guard let rawCode = stream.readUInt8() else {
            print("Failed to parse rawCode from RejectMessage")
            return nil
        }
        guard let code = Code(rawValue: rawCode) else {
            print("Invalid code \(rawCode) from RejectMessage")
            return nil
        }
        guard let reason = stream.readVarString() else {
            print("Failed to parse reason from RejectMessage")
            return nil
        }
        var hash: SHA256Hash? = nil
        if stream.hasBytesAvailable {
            hash = SHA256Hash.fromBitcoinStream(stream)
            if hash == nil {
                print("Failed to parse hash from RejectMessage")
                return nil
            }
        }
        return RejectMessage(rejectedCommand: command, code: code, reason: reason, hash: hash)
    }
}
