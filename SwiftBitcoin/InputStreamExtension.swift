//
//  InputStreamExtension.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/10/24.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

extension InputStream {
    public func readUInt8() -> UInt8? {
        let size = 1
        var int: UInt8 = 0
        let numberOfBytesRead = self.read(&int, maxLength: size)
        if numberOfBytesRead != size {
            return nil
        }
        return int
    }
    
    public func readOPCode() -> OPCode? {
        if let rawValue = readUInt8() {
            return OPCode(rawValue: rawValue)
        }
        return nil
    }
    
    public func readUInt16(_ endianness: Endianness = .LittleEndian) -> UInt16? {
        let size = 2
        var readBuffer = [UInt8](repeating: 0, count: size)
        let numberOfBytesRead = self.read(&readBuffer, maxLength: size)
        if numberOfBytesRead != size {
            return nil
        }
        
        var buf_endian = readBuffer
        
        if endianness == .BigEndian {
            buf_endian = buf_endian.reversed()
        }
        
        let int = UnsafePointer(buf_endian).withMemoryRebound(to: UInt16.self, capacity: 1) {
            $0.pointee
        }
        return int
    }
    
    public func readUInt32(_ endianness: Endianness = .LittleEndian) -> UInt32? {
        let size = 4
        var readBuffer = [UInt8](repeating: 0, count: size)
        let numberOfBytesRead = self.read(&readBuffer, maxLength: size)
        if numberOfBytesRead != size {
            return nil
        }
        
        var buf_endian = readBuffer
        
        if endianness == .BigEndian {
            buf_endian = buf_endian.reversed()
        }
        
        let int = UnsafePointer(buf_endian).withMemoryRebound(to: UInt32.self, capacity: 1) {
            $0.pointee
        }
        return int
    }
    
    public func readUInt64(_ endianness: Endianness = .LittleEndian) -> UInt64? {
        let size = 8
        var readBuffer = [UInt8](repeating: 0, count: size)
        let numberOfBytesRead = self.read(&readBuffer, maxLength: size)
        if numberOfBytesRead != size {
            return nil
        }
        
        var buf_endian = readBuffer
        
        if endianness == .BigEndian {
            buf_endian = buf_endian.reversed()
        }
        
        let int = UnsafePointer(buf_endian).withMemoryRebound(to: UInt64.self, capacity: 1) {
            $0.pointee
        }
        return int
    }
    
    public func readInt16(_ endianness: Endianness = .LittleEndian) -> Int16? {
        let size = 2
        var readBuffer = [UInt8](repeating: 0, count: size)
        let numberOfBytesRead = self.read(&readBuffer, maxLength: size)
        if numberOfBytesRead != size {
            return nil
        }
        
        var buf_endian = readBuffer
        
        if endianness == .BigEndian {
            buf_endian = buf_endian.reversed()
        }
        
        let int = UnsafePointer(buf_endian).withMemoryRebound(to: Int16.self, capacity: 1) {
            $0.pointee
        }
        return int

    }
    
    public func readInt32(_ endianness: Endianness = .LittleEndian) -> Int32? {
        let size = 4
        var readBuffer = [UInt8](repeating: 0, count: size)
        let numberOfBytesRead = self.read(&readBuffer, maxLength: size)
        if numberOfBytesRead != size {
            return nil
        }
        
        var buf_endian = readBuffer
        
        if endianness == .BigEndian {
            buf_endian = buf_endian.reversed()
        }
        
        let int = UnsafePointer(buf_endian).withMemoryRebound(to: Int32.self, capacity: 1) {
            $0.pointee
        }
        return int
    }
    
    public func readInt64(_ endianness: Endianness = .LittleEndian) -> Int64? {
        let size = 8
        var readBuffer = [UInt8](repeating: 0, count: size)
        let numberOfBytesRead = self.read(&readBuffer, maxLength: size)
        if numberOfBytesRead != size {
            return nil
        }
        
        var buf_endian = readBuffer
        
        if endianness == .BigEndian {
            buf_endian = buf_endian.reversed()
        }
        
        let int = UnsafePointer(buf_endian).withMemoryRebound(to: Int64.self, capacity: 1) {
            $0.pointee
        }
        return int
    }
    
    public func readBool() -> Bool? {
        if let uint8 = readUInt8() {
            if uint8 > 0 {
                return true
            }
            return false
        }
        return nil
    }
    
    public func readASCIIStringWithLength(_ count: Int) -> String? {
        var length = count
        var readBuffer = [UInt8](repeating: 0, count: length)
        let numberOfBytesRead = self.read(&readBuffer, maxLength: readBuffer.count)
        if numberOfBytesRead != length {
            return nil
        }
        
        for i in 0 ..< numberOfBytesRead {
            if readBuffer[numberOfBytesRead - 1 - i] != 0 {
                break
            }
            length -= 1
        }
        
        return NSString(bytes: readBuffer, length: length, encoding: String.Encoding.ascii.rawValue) as String?
    }
    
    public func readData(_ count: Int = 0) -> NSData? {
        let data = NSMutableData()
        var length = count
        
        var readBuffer = [UInt8](repeating: 0, count: 256)
        if length == 0 {
            while hasBytesAvailable {
                let numOfBytesRead = self.read(&readBuffer, maxLength: readBuffer.count)
                if numOfBytesRead == 0 {
                    return nil
                }
                let subArray = [UInt8](readBuffer[0 ..< numOfBytesRead])
                data.append(subArray, length: numOfBytesRead)
            }
        } else {
            while hasBytesAvailable && length > 0 {
                let numOfBytesToRead = min(length, readBuffer.count)
                let numOfBytesRead = self.read(&readBuffer, maxLength: numOfBytesToRead)
                if numOfBytesRead != numOfBytesToRead {
                    return nil
                }
                let subarray = [UInt8](readBuffer[0..<numOfBytesRead])
                data.append(subarray, length: numOfBytesRead)
                length -= numOfBytesRead
            }
        }
        return data
    }
    
    public func readVarInt() -> UInt64? {
        if let uint8 = readUInt8() {
            switch uint8 {
            case 0..<0xfd:
                return UInt64(uint8)
            case 0xfd:
                if let uint16 = readUInt16() {
                    return UInt64(uint16)
                }
            case 0xfe:
                if let uint32 = readUInt32() {
                    return UInt64(uint32)
                }
            case 0xff:
                return readUInt64()
            default: 
                return nil
            }
        }
        return nil
    }
    
    public func readVarString() -> String? {
        if let length = readVarInt() {
            return readASCIIStringWithLength(Int(length))
        }
        return nil
    }
    
    public func readDateFrom32BitUnixTimestamp(endianness: Endianness = .LittleEndian) -> NSDate? {
        let rawTimestamp = readUInt32(endianness)
        if rawTimestamp == nil {
            return nil
        }
        return NSDate(timeIntervalSince1970: TimeInterval(rawTimestamp!))
    }
    
    public func readDateFrom64BitUnixTimestamp(endianness: Endianness = .LittleEndian) -> NSDate? {
        let rawTimestamp = readUInt64(endianness)
        if rawTimestamp == nil {
            return nil
        }
        return NSDate(timeIntervalSince1970: TimeInterval(rawTimestamp!))
    }
    
}
