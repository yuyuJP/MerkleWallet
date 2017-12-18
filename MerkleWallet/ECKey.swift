//
//  ECKey.swift
//  FInt
//
//  Created by Yusuke Asai on 2016/10/08.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation
import BigInt

public class ECKey {
    public let privateKey: BigUInt
    public let curve: ECurve
    
    public let publicKeyPoint: ECPoint
    
    public let isCompressedPublicKeyAddress: Bool
    
    public init(_ privateKey: BigUInt, _ curve: ECurve, skipPublicKeyGeneration: Bool = false, isCompressedPublicKeyAddress: Bool) {
        self.privateKey = privateKey
        self.curve = curve
        self.isCompressedPublicKeyAddress = isCompressedPublicKeyAddress
        
        if !skipPublicKeyGeneration {
            self.publicKeyPoint = self.privateKey * self.curve.G
        } else {
            self.publicKeyPoint = curve.infinity
        }
    }
    
    public init(privateKey: BigUInt, publicKeyPoint: ECPoint, isCompressedPublicKeyAddress: Bool) {
        self.privateKey = privateKey
        self.publicKeyPoint = publicKeyPoint
        self.curve = publicKeyPoint.curve
        self.isCompressedPublicKeyAddress = isCompressedPublicKeyAddress
    }
    
    public init(_ publicKeyPoint: ECPoint, isCompressedPublicKeyAddress: Bool) {
        self.privateKey = 0
        self.publicKeyPoint = publicKeyPoint
        self.curve = publicKeyPoint.curve
        self.isCompressedPublicKeyAddress = isCompressedPublicKeyAddress
    }
    
    public convenience init(_ privateKeyHex: String, _ curve: ECurve, skipPublicKeyGeneration: Bool = false, isCompressedPublicKeyAddress: Bool) {
        self.init(BigUInt(privateKeyHex, radix: 16)!, curve, skipPublicKeyGeneration: skipPublicKeyGeneration, isCompressedPublicKeyAddress: isCompressedPublicKeyAddress)
    }
    
    public var privateKeyHexString: String {
        let privateKeyStr = (privateKey.serialize() as NSData).toHexString()
        let hexStr = (privateKeyStr as NSString).substring(to: 64)
        
        return hexStr
    }
    
    public var publicKeyHexString: String {
        
        if isCompressedPublicKeyAddress {
            return compressedPublicKeyHexString
        } else {
            return uncompressedPublicKeyHexString
        }
    }
    
    public var uncompressedPublicKeyHexString: String {
        
        switch publicKeyPoint.coordinate {
        case let .Affine(x: x, y: y):
            let xStr = ((x!.value.serialize() as NSData).toHexString() as NSString).substring(to: 64)
            let yStr = ((y!.value.serialize() as NSData).toHexString() as NSString).substring(to: 64)
            return "04" + xStr + yStr
        default:
            assert(false, "Not implemented")
            return ""
        }
    }
    
    public var compressedPublicKeyHexString: String {
        switch publicKeyPoint.coordinate {
        case .Affine(_, _):
            return publicKeyPoint.toCompressedData.toHexString()
        default:
            assert(false, "Not implemented")
            return ""
        }
    }
    
    public class func pointFromHex(_ hexString: String, _ curve: ECurve) -> ECPoint {
        
        let x: String = (hexString as NSString).substring(with: NSRange(location: 2, length: 64))
        let y: String = (hexString as NSString).substring(with: NSRange(location: 66, length: 64))
        return ECPoint(x: FFInt(x, curve.field), y: FFInt(y, curve.field), curve: curve)
    }
    
    public class func createRandom(_ curve: ECurve, skipPublicKeyGeneration: Bool = false, isCompressedPublicKeyAddress: Bool = true) -> ECKey {
        //return ECKey(secureRandom(curve.n), curve, skipPublicKeyGeneration: skipPublicKeyGeneration, isCompressedPublicKeyAddress: isCompressedPublicKeyAddress)
        return ECKey(secureRandom(curve.n), curve, skipPublicKeyGeneration: skipPublicKeyGeneration, isCompressedPublicKeyAddress: isCompressedPublicKeyAddress)
    }
    
    public func sign(_ digest: BigUInt) -> (BigUInt, BigUInt) {
        let field = FiniteField.PrimeField(p: curve.n)
        let zero = field.int(0)
        let e = field.int(digest)
        
        var s = zero
        var k: BigUInt = 0
        var r = zero
        
        var isLowS = true
        
        while s == field.int(0) {
            
            while r == zero {
                
                k = secureRandom(curve.n - 1)
                
                if k == 0 {
                    continue
                }
                
                let R = k * self.curve.G
                
                switch R.coordinate {
                case let .Affine(x, _):
                    r = field.int(x!.value)
                default:
                    assert(false, "Not affine")
                }
            }
            
            s = (1 / field.int(k)) * (e +  r * privateKey)
            
            let maximum = BigUInt("7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0", radix: 16)!
            if s.value > maximum {
                isLowS = false
            }
            
        }
        
        var s_ = s.value
        
        if !isLowS {
            let n = BigUInt("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141", radix: 16)!
            s_ = n - s_
        }
        
        return (r.value, s_)
    }
    
    public class func verifySignature(_ digest: BigUInt, r: BigUInt, s: BigUInt, publicKey: ECPoint) -> Bool {
        
        let curve = publicKey.curve
        let field = FiniteField.PrimeField(p: curve.n)
        let e = field.int(digest)
        
        if r <= 0 || r >= curve.n || s <= 0 || s >= curve.n {
            return false
        }
        
        let w: FFInt = 1 / field.int(s)
        
        let u1 = e * w
        let u2 = field.int(r) * w
        
        let P = u1.value * curve.G + u2.value * publicKey
        
        switch P.coordinate {
        case let .Affine(x, _):
            let px = field.int(x!.value)
            return px == field.int(r)
        default:
            assert(false, "Not affine")
            return false
        }
    }
    
    public class func der(_ r: BigUInt, _ s: BigUInt) -> NSData {
    
        var r_bytes = [UInt8]((r.serialize() as NSData).toBytes())
        var s_bytes = [UInt8]((s.serialize() as NSData).toBytes())
        
        //r and s is unsigned, so if first byte of r or s is > 7f, append 0x00 as prefix
        // if first byte of r or s is > 7f, the highest bit is 1, which means negative when it is signed, r and s are unsigned though.
        if r_bytes[0] > 0x7f {
            r_bytes.insert(0x00, at: 0)
        }
        if s_bytes[0] > 0x7f {
            s_bytes.insert(0x00, at: 0)
        }
        
        var z: [UInt8] = [0x02]
        z.append(UInt8(r_bytes.count))
        z += r_bytes
        z.append(0x02)
        z.append(UInt8(s_bytes.count))
        z += s_bytes
        
        var bytes: [UInt8] = [0x30]

        bytes.append(UInt8(z.count))
        bytes += z
        
        let signature = NSData(bytes: bytes, length: bytes.count)
        
        return signature
    }
    
    
    public class func importDer(_ data: NSData) -> (BigUInt, BigUInt) {
        var R: [UInt32] = [0,0,0,0,0,0,0,0]
        var S: [UInt32] = [0,0,0,0,0,0,0,0]
        
        
        data.getBytes(&R, range: NSMakeRange(4, 0x20))
        data.getBytes(&S, range: NSMakeRange(39, 0x20))
        
        let r = bigUIntFromUInt32Array(nums: [R[0].bigEndian, R[1].bigEndian, R[2].bigEndian, R[3].bigEndian, R[4].bigEndian, R[5].bigEndian, R[6].bigEndian, R[7].bigEndian])
        
        let s = bigUIntFromUInt32Array(nums: [S[0].bigEndian, S[1].bigEndian, S[2].bigEndian, S[3].bigEndian, S[4].bigEndian, S[5].bigEndian, S[6].bigEndian, S[7].bigEndian])
        
        return (r, s)
    }
}
