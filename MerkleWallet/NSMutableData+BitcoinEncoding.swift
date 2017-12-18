//
//  NSMutableData+BitcoinEncoding.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/10/28.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

extension NSData {
    public func toBytes() -> [UInt8] {
        var buf = [UInt8](repeating: 0, count: self.length)
        self.getBytes(&buf, length: buf.count)
        
        return buf
    }
    
    public var reversedData: NSData {
        var bytes = [UInt8](repeating: 0, count: self.length)
        self.getBytes(&bytes, length: bytes.count)
        /*var tmp: UInt8 = 0
        for i in 0 ..< (bytes.count / 2) {
            tmp = bytes[i]
            bytes[i] = bytes[bytes.count - i - 1]
            bytes[bytes.count - i - 1] = tmp
        }*/
        return NSData(bytes: bytes.reversed(), length: bytes.count)
    }
}

extension NSMutableData {
    
    //TODO : This method can be useful to make code more readable
    public func appendItem<T>(_ value: T, endianness: Endianness = .LittleEndian) {
        var bytes = toByteArray(value)
        
        if endianness == .BigEndian {
            bytes = bytes.reversed()
        }
        self.append(bytes, length: bytes.count)
    }
    
    public func appendNSData(_ data: NSData) {
        self.append(data as Data)
    }
    
    public func appendVarInt(_ value: UInt64, endiasness: Endianness = .LittleEndian) {
        let varInt = VarInt(value)
        self.append(varInt.bytes, length: varInt.bytes.count)
    }
    
    public func appendVarInt(_ value: Int, endianness: Endianness = .LittleEndian) {
        appendVarInt(UInt64(value), endiasness: endianness)
    }
    
    public func appendVarString(_ string: String, endianness: Endianness = .LittleEndian) {
        let varStr = VarString(string)
        self.append(varStr.bytes, length: varStr.bytes.count)
    }
    
    public func appendUInt8(_ value: UInt8) {
        self.append([value] as [UInt8], length: 1)
    }
    
    public func appendOPCode(_ opcode: OPCode) {
        self.append([opcode.rawValue] as [UInt8], length: 1)
    }
    
    public func appendUInt16(_ value: UInt16, endianness: Endianness = .LittleEndian) {
        var bytes = toByteArray(value)
        
        if endianness == .BigEndian {
            bytes = bytes.reversed()
        }
        
        self.append(bytes, length: 2)
    }
    
    public func appendUInt32(_ value: UInt32, endianness: Endianness = .LittleEndian) {
        var bytes = toByteArray(value)
        
        if endianness == .BigEndian {
            bytes = bytes.reversed()
        }
        
        self.append(bytes, length: 4)
    }
    
    public func appendUInt64(_ value: UInt64, endianness: Endianness = .LittleEndian) {
        var bytes = toByteArray(value)
        
        if endianness == .BigEndian {
            bytes = bytes.reversed()
        }
        
        self.append(bytes, length: 8)
    }

    public func appendInt16(_ value: Int16, endianness: Endianness = .LittleEndian) {
        var bytes = toByteArray(value)
        
        if endianness == .BigEndian {
            bytes = bytes.reversed()
        }
        
        self.append(bytes, length: 2)
    }
    
    public func appendInt32(_ value: Int32, endianness: Endianness = .LittleEndian) {
        var bytes = toByteArray(value)
        
        if endianness == .BigEndian {
            bytes = bytes.reversed()
        }
        
        self.append(bytes, length: 4)
    }
    
    public func appendInt64(_ value: Int64, endianness: Endianness = .LittleEndian) {
        var bytes = toByteArray(value)
        
        if endianness == .BigEndian {
            bytes = bytes.reversed()
        }
        
        self.append(bytes, length: 8)
    }
    
    public func appendBool(_ value: Bool) {
        value ? appendUInt8(1) : appendUInt8(0)
    }


    public func appendDateAs32BitUnixTimestamp(_ date: NSDate, endianness: Endianness = .LittleEndian) {
        appendUInt32(UInt32(date.timeIntervalSince1970), endianness: endianness)
    }
    
    public func appendDateAs64BitUnixTimestamp(_ date: NSDate, endianness: Endianness = .LittleEndian) {
        appendUInt64(UInt64(date.timeIntervalSince1970), endianness: endianness)
    }

}
