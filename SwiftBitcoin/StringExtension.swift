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
    
    func base58StringToNSData() -> NSData {
        var decimal = BigUInt(0)
        
        for c in self.characters {
            let temp_c = c
            
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
