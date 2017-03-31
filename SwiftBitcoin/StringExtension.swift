//
//  Base58Extension.swift
//  CoinCryptography
//
//  Created by Yusuke Asai on 2016/10/09.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

private let ALPHABET : String = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

extension String {
    
    func base58AlphabetContain() -> Bool {
        for c in self.characters {
            let cStr = String(c)
            if !ALPHABET.contains(cStr) {
                return false
            }
        }
        return true
    }
    
    func hexStringToBase58Encoding() -> String {
        let bigNum = BigUInt(self, radix: 16)!
        
        var leadingOnes: String = ""
        
        var i = 0
        while i < self.characters.count {
            let digit: String = (self as NSString).substring(with: NSMakeRange(i, 2))
            
            if digit == "00" {
                leadingOnes += "1"
            } else {
                break
            }
            i += 2
        }
        
        return leadingOnes + base58Encoding(bigNum)
    }
    
    func base58StringToNSData() -> NSData? {
        var decimal = BigUInt(0)
        
        for c in self.characters {
            let temp_c = c
            
            if !ALPHABET.characters.contains(c) {
                print("Invalid character:\(c) contains.")
                return nil
            }
            
            var indexNum = 0
            for (i, letter) in ALPHABET.characters.enumerated() {
                if letter == temp_c {
                    indexNum = i
                }
            }
            decimal = decimal * 58
            decimal = decimal + BigUInt(indexNum)
        }
        return decimal.serialize() as NSData
    }
    
    func hexStringToNSData() -> NSData {
        
        let data = NSMutableData()
        
        var i = 0
        while i < self.characters.count {
            let digit: String = (self as NSString).substring(with: NSMakeRange(i, 2))
            
            if digit == "00" {
                data.appendUInt8(0x00)
            } else {
                break
            }
            i += 2
        }

        data.append(BigUInt(self, radix: 16)!.serialize())
        
        return data as NSData
    }
    
    func publicAddressToPubKeyHash(_ pubKeyPrefix: UInt8) -> String? {
        guard let decodedStr = self.base58StringToNSData()?.toHexString() else {
            return nil
        }
        
        let startIndex = decodedStr.startIndex
        let endIndex = decodedStr.endIndex
        
        let prefixEnd = decodedStr.index(startIndex, offsetBy: 2)
        let prefixRange = startIndex ..< prefixEnd
        
        guard let prefix = UInt8(decodedStr.substring(with: prefixRange), radix: 16) else {
            print("Failed to decode prefix from Decoded Public Address.")
            return nil
        }
        
        if prefix != pubKeyPrefix {
            print("Failed to decode Public Address. Invalid prefix(\(prefix). It should be \(pubKeyPrefix).")
            return nil
        }
        
        let checksumStart = decodedStr.index(endIndex, offsetBy: -8)
        let checksumRange = checksumStart ..< endIndex
        let checksumStr = decodedStr.substring(with: checksumRange)
    
        let pubKeyHashRange = prefixEnd ..< checksumStart
        let extractedPubKeyHash = decodedStr.substring(with: pubKeyHashRange)
        
        //Public Key Hash with public key prefix
        let extendedPubKeyHash = decodedStr.substring(with: startIndex ..< checksumStart)
        
        let hash256Str = Hash256.digestHexString(extendedPubKeyHash.hexStringToNSData())
        
        let checksumCandidateStart = hash256Str.startIndex
        let checksumCandidateEnd = hash256Str.index(startIndex, offsetBy: 8)
        let checksumCandidateRange = checksumCandidateStart ..< checksumCandidateEnd
        let checksumCandidate = hash256Str.substring(with: checksumCandidateRange)
        
        if checksumStr != checksumCandidate {
            print("Failed to decode Public Address. Invalid checksum.")
            return nil
        }
        
        return extractedPubKeyHash
    }
}


private func base58Encoding(_ bignum: BigUInt) -> String {
    var num = bignum
    var strBuf = ""
    while num > 0 {
        let indexNum = bigIntToInt(num % 58)
        let alphabetIndex = ALPHABET.index(ALPHABET.startIndex, offsetBy: indexNum)
        let c = String(ALPHABET.characters[alphabetIndex])
        strBuf += c
        num = num / 58
    }
    
    return String(strBuf.characters.reversed())
}


private func bigIntToInt(_ bigInt: BigUInt) -> Int {
    let bigIntStr = String(bigInt, radix: 10)
    return Int(bigIntStr, radix: 10)!
}

private func dataToUInt8Array(_ data : NSData) -> Array<UInt8> {
    var buf = Array<UInt8>(repeating : 0, count : data.length)
    data.getBytes(&buf, length : data.length)
    return buf
}
