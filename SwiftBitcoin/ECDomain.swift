//
//  ECDomain.swift
//  FInt
//
//  Created by Yusuke Asai on 2016/10/01.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import BigInt

public enum EllipticCurveDomain {
    case Secp256k1
    
    public var field: FiniteField {
        switch self {
        case .Secp256k1:
            //let numArray = [0xffffffff, 0xffffffff, 0xffffffff,0xffffffff, 0xffffffff,0xffffffff, 0xfffffffe,0xfffffc2f]
            let p = "fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f"
            let pNum = BigUInt(p, radix: 16)!
            return FiniteField.PrimeField(p: pNum)
        
        }
    }
    
    public var a: BigUInt {
        switch self {
        case .Secp256k1:
            return BigUInt(0)
        
        }
    }
    
    public var b: BigUInt {
        switch self {
        case .Secp256k1:
            return BigUInt(7)
        }
    }
    
    // The base point G in compressed form is:
    public var g: String {
        switch self {
        case .Secp256k1:
            return "0279BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798"
        }
    }
    
    // Base point expressed in X and Y coordinates (uncompressed form with 04 left out of the beginning)
    public var gX: FFInt {
        switch self {
        case .Secp256k1:
            let cordStr = "79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798"
            //let numArray = [0x79be667e, 0xf9dcbbac, 0x55a06295, 0xce870b07, 0x029bfcdb, 0x2dce28d9, 0x59f2815b, 0x16f81798]
            //let fieldNum = intArrayToBigInt(nums: numArray)
            let fieldNum = BigUInt(cordStr, radix: 16)!
            return field.int(fieldNum)
        }
    }
    
    public var gY: FFInt {
        switch self {
        case .Secp256k1:
            let cordStr = "483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8"
            //let numArray = [0x483ada77,0x26a3c465,0x5da4fbfc,0x0e1108a8,0xfd17b448,0xa6855419, 0x9c47d08f,0xfb10d4b8]
            //let fieldNum = intArrayToBigInt(nums: numArray)
            let fieldNum = BigUInt(cordStr, radix: 16)!
            return field.int(fieldNum)
        }
    }
    
    // The order n of G
    public var n: BigUInt {
        switch self {
        case .Secp256k1:
            let cordStr = "fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141"
            return BigUInt(cordStr, radix: 16)!
        }
    }
    
    public var h: BigUInt {
        switch self {
        case .Secp256k1:
            return  BigUInt(1)
        }
    }

    
}
