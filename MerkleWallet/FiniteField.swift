//
//  FiniteField.swift
//  FInt
//
//  Created by Yusuke Asai on 2016/09/30.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import BigInt

public enum FiniteField : CustomStringConvertible {
    case PrimeField(p : BigUInt)
    
    public func int(_ val : BigUInt) -> FFInt {
        return FFInt(val, self)
    }
    
    public func intWithDec(dec: String) -> FFInt {
        return FFInt(BigUInt(dec)!, self)
    }
    
    public func intWithHex(hex: String) -> FFInt {
        return FFInt(BigUInt(hex, radix: 16)!, self)
    }
    
    //BigUInt(String(value), radix: 10)!
    
    public var description: String {
        switch self {
        case let .PrimeField(p):
            return "Prime field p = \( p ) "
        }
    }
}

public func == (lhs: FiniteField, rhs: FiniteField) -> Bool {
    switch lhs {
    case let .PrimeField(p1):
        switch rhs {
        case let .PrimeField(p2):
            return p1 == p2
        }
    }

}

private func powDouble(n: Int) -> UInt64 {
    
    return UInt64(n * n)
    //return UInt64(pow(Double(2), Double(n)))
}

extension BigUInt {
    internal func modInverse(_ m: BigUInt) -> BigUInt {
        assert(m > 0, "Modulo 0 makes no sense")
        let a = BigInt(self)
        let b = BigInt(m)
        
        var t = BigInt(0)
        var nt = BigInt(1)
        var r = b
        var nr = a % b
        
        while nr != 0 {
            let q = r / nr
            var tmp = nt
            nt = t - q * nt
            t = tmp
            tmp = nr
            nr = r - q * nr
            r = tmp
        }
        
        if t < 0 {
            t += b
        }
        
        return t.magnitude
    }
    
    internal func highestBitOfUInt256() -> Int {
        var bitLength: UInt32 = 256
        let e = Int(self.words[3] >> 32)
        
        if e == 0 { bitLength -= 32} else {
            for i in 0 ..< 31 {
                if powDouble(n: 31 - i) & UInt64(e) != 0 { break } else {
                    bitLength -= 1
                }
            }
        }
        
        return Int(bitLength)
    }


}
