//
//  CoinKey.swift
//  CoinCryptography
//
//  Created by Yusuke Asai on 2016/10/09.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public class CoinKey : ECKey {
    let privateKeyPrefix: UInt8
    let publicKeyPrefix: UInt8
    
    public init(privateKeyHex: String, privateKeyPrefix: UInt8, publicKeyPrefix: UInt8, skipPublicKeyGeneration: Bool = true) {
        self.privateKeyPrefix = privateKeyPrefix
        self.publicKeyPrefix = publicKeyPrefix
        super.init(BigUInt(privateKeyHex, radix: 16)!, ECurve(domain: .Secp256k1), skipPublicKeyGeneration: skipPublicKeyGeneration)
    }
    
    public init(privateKeyHex: String, publicKeyHex: String, privateKeyPrefix: UInt8, publicKeyPrefix: UInt8) {
        self.privateKeyPrefix = privateKeyPrefix
        self.publicKeyPrefix = publicKeyPrefix
        let point = ECKey.pointFromHex(publicKeyHex, ECurve(domain: .Secp256k1))
        super.init(privateKey: BigUInt(privateKeyHex, radix: 16)!, publicKeyPoint: point)
    }
    
    // Generates a random Bitcoin keypair
    public init(privateKeyPrefix: UInt8, publicKeyPrefix: UInt8) {
        let key = ECKey.createRandom(ECurve(domain: .Secp256k1))
        
        self.privateKeyPrefix = privateKeyPrefix
        self.publicKeyPrefix = publicKeyPrefix
        
        super.init(privateKey: key.privateKey, publicKeyPoint: key.publicKeyPoint)
    }
    
    private var privateKeyPrefixString: String {
        let prefixHexString = String(format: "%2X", privateKeyPrefix)
            
        switch prefixHexString.characters.count {
        case 0:
            return "00"
        case 1:
            return "0" + prefixHexString
        case 2:
            return prefixHexString
        default:
            assert(false, "Invalid prefix")
            return "00"
        }
    }
    
    
    public var wif : String {
        let extendedKey = privateKeyPrefixString + privateKeyHexString
        
        //let hash1: NSData = SHA256.hexStringDigest(extendedKey)
        
        //let hash2: String = SHA256.hexStringDigest(hash1)
        
        let hash = Hash256.hexStringDigestHexString(extendedKey)
        
        var checkSum: String = ""
        for char in hash.characters {
            checkSum += String(char)
            if checkSum.characters.count == 8 { break }
        }
        
        let keyWithCheckSum = extendedKey + checkSum
        
        return keyWithCheckSum.hexStringToBase58Encoding()
    }
    
    public var publicAddress : String {
        
        let ripemd = Hash160.hexStringDigest(self.publicKeyHexString)
        let extendedRipemd = NSMutableData()
        
        let versionByte: [UInt8] = [publicKeyPrefix]
        extendedRipemd.append(versionByte, length: 1)
        extendedRipemd.append(ripemd.bytes, length: ripemd.length)
        
        //let doubleSHA: String = SHA256.hexStringDigest(SHA256.digest(extendedRipemd))
        let doubleSHA : String = Hash256.digestHexString(extendedRipemd)
        
        let checkSum: String = (doubleSHA as NSString).substring(with: NSMakeRange(0, 8))
        let hexAddress = extendedRipemd.toHexString() + checkSum
    
        let base58 = hexAddress.hexStringToBase58Encoding()
        
        return base58
    }
    
}
