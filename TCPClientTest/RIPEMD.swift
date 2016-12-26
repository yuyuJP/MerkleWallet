//
//  RIPEMD.swift
//  RIPEMD-160
//
//  Created by Yusuke Asai on 2016/10/09.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public struct RIPEMD {
    public static func digest(_ input: NSData, bitlength: Int = 160) -> NSData {
        assert(bitlength == 160, "Only RIPEMD-160 is implemented")
        
        let padedData = pad(input)
        
        var block = RIPEMD.Block()
        
        var i = 0
        while i < padedData.length / 64 {
            let part = getWordsInSection(padedData, i)
            block.compress(part)
            i += 1
        }
        
        return encodeWords(block.hash)
    }
    
    private static func pad(_ data: NSData) -> NSData {
        let paddedData = data.mutableCopy() as! NSMutableData
        
        let stop : [UInt8] = [0x80]
        paddedData.append(stop, length: 1)
        
        var numberOfZerosToPad: Int;
        if paddedData.length % 64 == 56 {
            numberOfZerosToPad = 0
        } else if paddedData.length % 64 < 56 {
            numberOfZerosToPad = 56 - (paddedData.length % 64)
        } else {
            // Add an extra round
            numberOfZerosToPad = 56 + (64 - paddedData.length % 64)
        }
        
        let zeroBytes = [UInt8](repeating: 0, count: numberOfZerosToPad)
        paddedData.append(zeroBytes, length: numberOfZerosToPad)
        
        // Append length of message:
        let length: UInt32 = UInt32(data.length) * 8
        let lengthBytes: [UInt32] = [length, UInt32(0x00_00_00_00)]

        paddedData.append(lengthBytes, length: 8)
        
        return paddedData as NSData
    }
    
    private static func getWordsInSection(_ data: NSData, _ section: Int) -> [UInt32] {
        let offset = section * 64
        
        assert(data.length >= Int(offset + 64), "Data too short")
        
        var words: [UInt32] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        data.getBytes(&words, range: NSMakeRange(offset, 64))
        
        return words
    }
    
    private static func encodeWords(_ input: [UInt32]) -> NSData {
        let data = NSMutableData(bytes: input, length: 20)
        return data
    }
    
    // Returns a string representation of a hexadecimal number
    public static func digest (_ input : NSData, bitlength:Int = 160) -> String {
        return digest(input, bitlength: bitlength).toHexString()
    }

    // Takes a string representation of a hexadecimal number
    public static func hexStringDigest (_ input : String, bitlength:Int = 160) -> NSData {
        let data = NSData.fromHexString(input)
        return digest(data, bitlength: bitlength)
    }

    // Takes a string representation of a hexadecimal number and returns a
    // string represenation of the resulting 160 bit hash.
    public static func hexStringDigest (_ input : String, bitlength:Int = 160) -> String {
        let digest: NSData = hexStringDigest(input, bitlength: bitlength)
        return digest.toHexString()
    }

    // Takes an ASCII string
    public static func asciiDigest (_ input : String, bitlength:Int = 160) -> NSData {
        // Order of bytes is preserved; if the last character is dot, the last
        // byte is a dot.
        if let data: NSData = input.data(using: String.Encoding.ascii) as NSData? {
            return digest(data, bitlength: bitlength)
        } else {
            assert(false, "Invalid input")
            return NSData()
        }
    }
    
    //     Takes an ASCII string and returns a hex string represenation of the
    //     resulting 160 bit hash.
    public static func asciiDigest (_ input : String, bitlength:Int = 160) -> String {
        return asciiDigest(input, bitlength: bitlength).toHexString()
    }

    
    
    
}
