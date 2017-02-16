//
//  VarInt.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/10/22.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

struct VarInt {
    
    public enum varIntType {
        case UInt8_t(value : UInt8)
        case UInt16_t(value : UInt16)
        case UInt32_t(value : UInt32)
        case UInt64_t(value : UInt64)
        case ReadError
    }
    
    public let length : Int
    
    public let type : varIntType
    
    public let bytes : [UInt8]
    
    public init(_ value : UInt64) {
        let bin = toByteArray(value)
        
        switch value {
        case 0x00 ..< 0xfd:
            length = 1
            
            type = varIntType.UInt8_t(value: UInt8(value))
            
            bytes = [bin[0]]
            
        case 0xfd ... 0xffff:
            length = 3
            
            type = varIntType.UInt16_t(value: UInt16(value))
            
            bytes = [0xfd, bin[0], bin[1]]
            
        case 0xffff ... 0xffffffff:
            length = 5
            
            type = varIntType.UInt32_t(value: UInt32(value))
            
            bytes = [0xfe, bin[0], bin[1], bin[2], bin[3]]
        case 0xffffffff ... UInt64.max:
            length = 9
            
            type = varIntType.UInt64_t(value: value)
            
            bytes = [0xff, bin[0], bin[1], bin[2], bin[3], bin[4], bin[5], bin[6], bin[7]]
            
        default:
            self.length = 0
            type = varIntType.ReadError
            bytes = []
            assert(false, "wrong value input")
        }
    }
    
    public init(header : UInt8, data : [UInt8]) {
        
        switch header {
        case 0x00 ..< 0xfd:
            length = 1
            
            type = varIntType.UInt8_t(value: header)
            
            bytes = [header]
            
        case 0xfd:
            length = 3
            
            var value = UInt16(data[0])
            var high = UInt16(data[1])
            
            high = high << 8
            value += high
            
            type = varIntType.UInt16_t(value: value)
            
            bytes = [header, data[0], data[1]]
            
        case 0xfe:
            length = 5
            
            var value = UInt32(data[0])
            for i in 1 ... 3 {
                var high = UInt32(data[i])
                high = high << UInt32(8 * i)
                value += high
            }
            
            type = varIntType.UInt32_t(value: value)
            
            bytes = [header, data[0], data[1], data[2],data[3]]
            
        case 0xff:
            length = 9
            
            var value = UInt64(data[0])
            for i in 1 ... 7 {
                var high = UInt64(data[i])
                high = high << UInt64(8 * i)
                value += high
            }
            
            type = varIntType.UInt64_t(value: value)
            
            bytes = [header, data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7]]
            
        default:
            self.length = 0
            type = varIntType.ReadError
            bytes = []
            assert(false, "unable to read header value")
        }
    }
}
