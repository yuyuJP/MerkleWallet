//
//  SHA-256.swift
//  CoinCryptography
//
//  Created by Yusuke Asai on 2016/10/09.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public struct SHA256 {
    public static func digest(_ input: NSData) -> NSData {
        let digestLength = HMACAlgorithm.SHA256.digestLength()
        
        var hash = [UInt8](repeating: 0, count: digestLength)
        
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        
        return NSData(bytes: hash, length: digestLength)
    }
    
    public static func hexStringDigest(_ input: String) -> NSData {
        let data = SHA256.dataFromHexString(input)
        return digest(data)
    }
    
    public static func hexStringDigest(_ input: NSData) -> String {
        //return hexStringFromData(digest(input))
        return digest(input).toHexString()
    }
    
    public static func hexStringDigest(_ input: String) -> String {
        let digest: NSData = hexStringDigest(input)
        return digest.toHexString()
    }
    
    
    public static func dataFromHexString(_ input: String) -> NSData {
        /*// Based on: http://stackoverflow.com/a/2505561/313633
        let data = NSMutableData()
        
        var string = ""
        
        for char in input.characters {
            string.append(char)
            if(string.characters.count == 2) {
                let scanner = Scanner(string: string)
                var value: CUnsignedInt = 0
                scanner.scanHexInt32(&value)
                data.append(&value, length: 1)
                string = ""
            }
            
        }
        
        return data as NSData*/
        
        //let hexNum = BigUInt(input, radix: 16)!
        
        //return hexNum.serialize() as NSData
        return input.hexStringToNSData()
    }
    
    /*public static func hexStringFromData(_ input: NSData) -> String {
        let sha256description = input.description as String
        
        // TODO: more elegant way to convert NSData to a hex string
        
        var result: String = ""
        
        for char in sha256description.characters {
            switch char {
            case "0", "1", "2", "3", "4", "5", "6", "7","8","9", "a", "b", "c", "d", "e", "f":
                result.append(char)
            default:
                result += ""
            }
        }
        
        return result
    }*/
}

enum HMACAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    func toCCEnum() -> CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:
            result = kCCHmacAlgMD5
        case .SHA1:
            result = kCCHmacAlgSHA1
        case .SHA224:
            result = kCCHmacAlgSHA224
        case .SHA256:
            result = kCCHmacAlgSHA256
        case .SHA384:
            result = kCCHmacAlgSHA384
        case .SHA512:
            result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .MD5:
            result = CC_MD5_DIGEST_LENGTH
        case .SHA1:
            result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:
            result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:
            result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:
            result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:
            result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}
