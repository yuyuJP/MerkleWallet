//
//  FiniteFieldInteger.swift
//  FInt
//
//  Created by Yusuke Asai on 2016/09/30.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import BigInt

precedencegroup MultiplicationPrecedence {
    associativity: left
    higherThan: AdditionPrecedence
}

infix operator ^^ : MultiplicationPrecedence

public struct FFInt : CustomStringConvertible, Equatable {
    public let field : FiniteField
    public let value : BigUInt
    
    public init(_ value: BigUInt, _ field: FiniteField) {
        self.value = value
        self.field = field
        
        switch field {
        case let .PrimeField(p):
            assert(value < p, "Input value must be smaller than p")
        }
        
    }
    
    public init(_ hex: String, _ field: FiniteField) {
        self.value = BigUInt(hex, radix: 16)!
        self.field = field
        
        switch field {
        case let .PrimeField(p):
            assert(self.value < p, "Input value must be smaller than p")
        }

    }
    
    
    //For small value
    public init(val: Int, p: Int) {
        self.value = BigUInt(val)
        self.field = .PrimeField(p: BigUInt(p))
        
        switch field {
        case let .PrimeField(p):
            assert(self.value < p, "Input value must be smaller than p")
        }
    }
    
    
    public var description: String {
        return "\(value) in \(field)"
    }
}

public func == (lhs: FFInt, rhs: FFInt) -> Bool {
    return lhs.field == rhs.field && lhs.value == rhs.value
}

prefix public func - (rhs: FFInt) -> FFInt {
    let field = rhs.field
    switch field {
    case let .PrimeField(p):
        assert(rhs.value < p, "Input value must be smaller than p")
        return field.int(0) - rhs
   
    }
}

public func + (lhs: FFInt, rhs: FFInt) -> FFInt {
    assert(lhs.field == rhs.field, "Can't add integers from different fields")
    if (rhs.value == 0) { return lhs}
    
    let field = lhs.field
    switch field {
    case let .PrimeField(p):
        assert(lhs.value < p, "Input value must be smaller than p")
        assert(rhs.value < p, "Input value must be smaller than p")
        
        let rhsMod = p - rhs.value
        
        
        if (lhs.value >= rhsMod) {
            return field.int(lhs.value - rhsMod)
        } else {
            return field.int(p - rhsMod + lhs.value)
        }

    }
}


public func - (lhs: FFInt, rhs: FFInt) -> FFInt {
    assert(lhs.field == rhs.field, "Can't subtract integers from different fields")
    
    let field = lhs.field
    switch field {
    case let .PrimeField(p):
        assert(lhs.value < p, "Input value must be smaller than p")
        assert(rhs.value < p, "Input value must be smaller than p")
        
        if(lhs.value >= rhs.value) {
            return field.int(lhs.value - rhs.value)
        } else {
            return field.int(p - rhs.value + lhs.value )
            
        }
    }
}

public func ^^ (lhs: FFInt, rhs: Int) -> FFInt {
    switch lhs.field {
        case let .PrimeField(p):
            assert(lhs.value < p, "Input value must be smaller than p")
    }
    
    switch rhs {
    case 0:
        return lhs.field.int(1)
    case 1:
        return lhs
    case let k where k > 1:
        var res = lhs
        for _ in 1..<k {
            res *= lhs
        }
        return res
    case let k where k < 0:
        assert(false, "Negative power not supported")
        return lhs.field.int(0)
        
    default:
        assert(false, "Logical error")
        return lhs.field.int(0)
        
    }
}

public func * (lhs: Int, rhs: FFInt) -> FFInt {
    let lhsInt : BigUInt = BigUInt(UInt32(lhs))
    return rhs.field.int(lhsInt) * rhs
}

public func * (lhs: BigUInt, rhs: FFInt) -> FFInt {
    return rhs.field.int(lhs) * rhs
}

public func * (lhs: FFInt, rhs: BigUInt) -> FFInt {
    return lhs * lhs.field.int(rhs)
}

public func *= ( lhs: inout FFInt, rhs: FFInt) -> () {
    lhs = lhs * rhs
}

public func * (lhs: FFInt, rhs: FFInt) -> FFInt {
    assert(lhs.field == rhs.field, "Can't multiply integers from different fields")
    
    let field = lhs.field
    switch field {
    case let .PrimeField(p):
        assert(lhs.value < p, "Input value must be smaller than p")
        assert(rhs.value < p, "Input value must be smaller than p")
        
        let product = lhs.value * rhs.value
        
        return field.int(product % p)
    }
}

public func / (lhs: FFInt, rhs: FFInt) -> FFInt {
    assert(lhs.field == rhs.field, "Can't divide integers from different fields")
    
    let field = lhs.field
    switch field {
    case let .PrimeField(p):
        assert(lhs.value < p, "Input value must be smaller than p")
        assert(rhs.value < p, "Input value must be smaller than p")
        
        let inverse : BigUInt = rhs.value.modInverse(p)
        
        return  lhs * inverse
    }

}

public func / (lhs: Int, rhs : FFInt) -> FFInt {
    
    let lhsInt: BigUInt = BigUInt(UInt32(lhs))
    
    return rhs.field.int(lhsInt) / rhs
}
