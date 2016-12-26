//
//  ECKey.swift
//  FInt
//
//  Created by Yusuke Asai on 2016/10/08.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public class ECKey {
    public let privateKey: BigUInt
    public let curve: ECurve
    
    public let publicKeyPoint: ECPoint
    
    public init(_ privateKey: BigUInt, _ curve: ECurve, skipPublicKeyGeneration: Bool = false) {
        self.privateKey = privateKey
        self.curve = curve
        
        if !skipPublicKeyGeneration {
            self.publicKeyPoint = self.privateKey * self.curve.G
        } else {
            self.publicKeyPoint = curve.infinity
        }
    }
    
    public init(privateKey: BigUInt, publicKeyPoint: ECPoint) {
        self.privateKey = privateKey
        self.publicKeyPoint = publicKeyPoint
        self.curve = publicKeyPoint.curve
    }
    
    public init(_ publicKeyPoint: ECPoint) {
        self.privateKey = 0
        self.publicKeyPoint = publicKeyPoint
        self.curve = publicKeyPoint.curve
    }
    
    public convenience init(_ privateKeyHex: String, _ curve: ECurve, skipPublicKeyGeneration: Bool = false) {
        self.init(BigUInt(privateKeyHex, radix: 16)!, curve, skipPublicKeyGeneration: skipPublicKeyGeneration)
    }
    
    public var privateKeyHexString: String {
        let privateKeyStr = (privateKey.serialize() as NSData).toHexString()
        let hexStr = (privateKeyStr as NSString).substring(to: 64)
        
        return hexStr
    }
    
    public var publicKeyHexString: String {
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
    
    public class func pointFromHex(_ hexString: String, _ curve: ECurve) -> ECPoint {
        //print("length 130?? length : \(hexString.characters.count)")
        
        let x: String = (hexString as NSString).substring(with: NSRange(location: 2, length: 64))
        let y: String = (hexString as NSString).substring(with: NSRange(location: 66, length: 64))
        return ECPoint(x: FFInt(x, curve.field), y: FFInt(y, curve.field), curve: curve)
    }
    
    public class func createRandom(_ curve: ECurve, skipPublicKeyGeneration: Bool = false) -> ECKey {
        return ECKey(secureRandom(curve.n), curve, skipPublicKeyGeneration: skipPublicKeyGeneration)
    }
    
    public func sign(_ digest: BigUInt) -> (BigUInt, BigUInt) {
        let field = FiniteField.PrimeField(p: curve.n)
        let zero = field.int(0)
        let e = field.int(digest)
        
        var s = zero
        var k: BigUInt = 0
        var r = zero
        
        while s == field.int(0) {
            
            while r == zero {
                k = secureRandom(curve.n - 1) + 1
                let R = k * self.curve.G
                
                switch R.coordinate {
                case let .Affine(x, _):
                    r = field.int(x!.value)
                default:
                    assert(false, "Not affine")
                }
            }
            s = (e + privateKey * r) / field.int(k)
        }
        
        return (r.value, s.value)
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
        var bytes: [UInt8] = [0x30, 0x45, 0x02, 0x20]
        let signature = NSMutableData(bytes: &bytes, length: bytes.count)
        signature.append(r.serialize())
        bytes = [0x02, 0x21, 0x00]
        signature.append(&bytes, length: 3)
        
        signature.append(s.serialize())
        
        return signature as NSData
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
