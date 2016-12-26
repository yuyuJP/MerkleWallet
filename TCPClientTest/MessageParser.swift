//
//  MessageParser.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/10/23.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public protocol MessageParserDelegate {
    func didParseMessage(_ message: Message)
}

public class MessageParser {
    
    public var delegate: MessageParserDelegate? = nil
    
    private var receivedBytes: [UInt8] = []
    
    private var receivedHeader: Message.Header? = nil
    
    public func parseBytes(_ bytes: [UInt8]) {
        receivedBytes += bytes
        
        while true {
            if receivedHeader == nil {
                let headerStartIndex = headerStartIndexInBytes(receivedBytes)
                if headerStartIndex < 0 {
                    let end = receivedBytes.count - NetworkMagicBytes.magicBytes().count + 1
                    if end > 0 {
                        let range = receivedBytes.startIndex ..< end
                        receivedBytes.removeSubrange(range)
                    }
                    return
                }
                
                let range = receivedBytes.startIndex ..< headerStartIndex
                receivedBytes.removeSubrange(range)
                if receivedBytes.count < Message.Header.length {
                    //print("not enough bytes")
                    return
                }
                
                let stream = InputStream(data: NSData(bytes: receivedBytes, length: receivedBytes.count) as Data)
                stream.open()
                receivedHeader = Message.Header.fromBitcoinStream(stream)
                
                stream.close()
                
                if receivedHeader == nil {
                    let removeRange = receivedBytes.startIndex ..< NetworkMagicBytes.magicBytes().count
                    receivedBytes.removeSubrange(removeRange)
                    continue
                }
                
                let headerRange = receivedBytes.startIndex ..< Message.Header.length
                receivedBytes.removeSubrange(headerRange)
            }
                let payloadLength = Int(receivedHeader!.payloadLength)
                
                if receivedBytes.count < payloadLength {
                    // Haven't received the whole message yet. Wait for more bytes.
                    return
                }
                
            let payloadData = NSData(bytes: receivedBytes, length: payloadLength)
            let message = Message(header: receivedHeader!, payloadData: payloadData)
            
            
            if message.header.network == NetworkMagicBytes.magicBytes() {
                
                if message.isChecksumValid() {
                    delegate?.didParseMessage(message)
                } else {
                    print("Invalid checksum : \(message.command) command")
                }
            } else {
                    print("Invalid network header")
            }
                
            let payloadRange = receivedBytes.startIndex ..< payloadLength
            receivedBytes.removeSubrange(payloadRange)
            receivedHeader = nil
        }
    }
    
    private func headerStartIndexInBytes(_ bytes: [UInt8]) -> Int {
        let networkMagicBytes = NetworkMagicBytes.magicBytes()
        if bytes.count < networkMagicBytes.count {
            return -1
        }
        
        for i in 0 ... (bytes.count - networkMagicBytes.count) {
            var found = true
            for j in 0 ..< networkMagicBytes.count {
                if bytes[i + j] != networkMagicBytes[j] {
                    found = false
                    break
                }
            }
            if found {
                return i
            }
        }
        return -1
    }
    
}
