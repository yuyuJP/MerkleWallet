//
//  HeadersMessage.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/11/08.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public func ==(left: HeadersMessage, right: HeadersMessage) -> Bool {
    return left.headers == right.headers
}

public struct HeadersMessage: Equatable {
    
    public let headers: [BlockHeader]
    
    public init(_ headers: [BlockHeader]) {
        self.headers = headers
    }
}

extension HeadersMessage: MessagePayload {
    
    public var command: Message.Command {
        return Message.Command.Headers
    }
    
    public var bitcoinData: NSData {
        let data = NSMutableData()
        data.appendVarInt(headers.count)
        for header in headers {
            data.appendNSData(header.bitcoinData)
        }
        return data
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> HeadersMessage? {
        let count = stream.readVarInt()
        if count == nil  {
            print("Failed to parse count from HeadersMessage")
            return nil
        }
        if count! == 0 {
            print("Failed to parse HeadersMessage. Count is zero")
            return nil
        }
        var headers: [BlockHeader] = []
        for i in 0 ..< count! {
            let header = BlockHeader.fromBitcoinStream(stream)
            if header == nil {
                print("Failed to parse header \(i) from HeadersMessage")
                return nil
            }
            
            let transactionCount = stream.readVarInt()
            if transactionCount == nil {
                print("Failed to parse transactionCount for header \(i) from HeadersMessage")
                return nil
            }
            if transactionCount! != 0 {
                print("Invalid transactionCount \(transactionCount!) for header \(i) from " +
                    "HeadersMessage")
                return nil
            }
            headers.append(header!)
        }
        return HeadersMessage(headers)
    }
}
