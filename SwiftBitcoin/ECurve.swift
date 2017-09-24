//
//  ECurve.swift
//  FInt
//
//  Created by Yusuke Asai on 2016/10/01.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation
import BigInt

public struct ECurve {
    public let domain: EllipticCurveDomain?
    
    public let field: FiniteField
    
    // let G: ECPoint // ECPoint refers to an ECurve, so this would create a cycle
    public let gX: FFInt
    public let gY: FFInt
    
    public let a: BigUInt
    public let b: BigUInt
    
    public let n: BigUInt
    public let h: BigUInt?
    
    public init(domain: EllipticCurveDomain) {
        self.domain = domain
        
        self.field = domain.field
        self.a = domain.a
        self.b = domain.b
        self.n = domain.n
        self.h = domain.h
        
        self.gX = domain.gX
        self.gY = domain.gY
    }
    
    public init(field: FiniteField, gX: FFInt, gY:FFInt, a: BigUInt, b: BigUInt, n: BigUInt, h: BigUInt?) {
        self.field = field
        
        self.a = a
        self.b = b
        self.n = n
        self.h = h
        
        self.gX = gX
        self.gY = gY
        
        self.domain = nil
    }
    
    public var G: ECPoint {
        return ECPoint(x: gX, y:gY, curve: self)
    }
    
    public var infinity: ECPoint {
        return ECPoint.infinity(self)
    }
    
    public subscript(x: BigUInt, y: BigUInt) -> ECPoint {
        return ECPoint(x: FFInt(x, self.field), y: FFInt(y, self.field), curve: self)
    }
    
    public subscript(x: FFInt, y: FFInt) -> ECPoint {
        return ECPoint(x: x, y: y, curve: self)
    }
    
    public var description: String {
        return "Curve over \(field) with base point (\(gX.value), \(gY.value)), a = \(a), b = \(b), order \(n) and cofactor \(h ?? "nil")"
    }

    public func point(data: NSData) -> ECPoint? {
        var firstByte: UInt8 = 0
        data.getBytes(&firstByte, length: 1)
        
        if firstByte == 4 {
            var x: [UInt32] = [0,0,0,0,0,0,0,0]
            var y: [UInt32] = [0,0,0,0,0,0,0,0]
            data.getBytes(&x, range: NSMakeRange(1, 32))
            data.getBytes(&y, range: NSMakeRange(33, 32))
            
            let X = intArrayToBigInt(nums: x)
            let Y = intArrayToBigInt(nums: y)
            
            return ECPoint(x: FFInt(X, self.field), y: FFInt(Y, self.field), curve: self)
        } else {
            assert (false, "Wrong format")
            return nil
        }
    }
}

public func == (lhs: ECurve, rhs: ECurve) -> Bool {
    if(lhs.domain == rhs.domain) {
        return true
    }
    
    switch (lhs.G.coordinate, rhs.G.coordinate) {
    case let (.Affine(lhsX,_), .Affine(rhsX,rhsY) ):
        return lhsX == rhsX && rhsY == rhsY  && lhs.a == rhs.a &&  lhs.b == rhs.b &&  lhs.n == rhs.n &&  lhs.h == rhs.h
        
    default:
        assert(false, "Not implemented")
        return false
    }
    
    
}

prefix public func - (rhs: ECPoint) -> ECPoint {
    switch rhs.coordinate {
    case let .Affine(x,y):
        if rhs.isInfinity {
            return rhs
        }
        
        assert(x != nil, "x set")
        let x1 = x!
        
        assert(y != nil, "y set")
        let y1 = y!
        
        let y3 = -y1
        
        return ECPoint(x: x1, y: y3, curve: rhs.curve)
        
    case .Jacobian:
        assert(false, "Not implemented")
        return rhs
    }
    
}

public func + (lhs: ECPoint, rhs: ECPoint) -> ECPoint {
    assert(lhs.curve == rhs.curve, "Can't add points on different curves")
    
    if lhs.isInfinity {
        return rhs
    }
    
    if rhs.isInfinity {
        return lhs
    }
    
    switch (lhs.coordinate, rhs.coordinate) {
    case let (.Affine(lhsX,lhsY), .Affine(rhsX,rhsY)) :
        
        assert(lhsX != nil, "lhs x set")
        let X1 = lhsX!
        
        assert(lhsY != nil, "lhs y set")
        let Y1 = lhsY!
        
        assert(rhsX != nil, "rhs x set")
        let X2 = rhsX!
        
        assert(rhsY != nil, "rhs y set")
        let Y2 = rhsY!
        
        if lhs == rhs { // P == Q
            return 2 * lhs
        }
        
        if X1 == X2 && Y1 + Y2 == lhs.curve.field.int(0) {
            return lhs.curve.infinity
        }
        
        let common = (Y2 - Y1) / (X2 - X1)
        let X3 = common ^^ 2 - X1 - X2
        let Y3 = common * (X1 - X3) - Y1
        
        return ECPoint(x: X3, y: Y3, curve: lhs.curve)
        
    case let (.Jacobian(X1, Y1, Z1),.Jacobian(X2, Y2, Z2)):
        
        assert(Z1 != lhs.curve.field.int(0), "Z1 should not be 0")
        assert(Z2 == lhs.curve.field.int(1), "Z2 must be 1")
        assert(!(X1 == X2 && Y1 == Y2 && Z1 == Z2), "Can't deal with   P == Q")
        assert(!(X1 == X2 && Y1 == -Y2 && Z1 == Z2), "Can't deal with P == -Q")
        
        let A = Z1 * Z1
        let B = Z1 * A
        let C = X2 * A
        let D = Y2 * B
        let E = C - X1
        let F = D - Y1
        let G = E * E
        let H = G * E
        let I = X1 * G
        
        let X3 = F * F - H - 2 * I
        let Y3 = F * (I - X3) - Y1 * H
        let Z3 = Z1 * E
        
        return ECPoint(coordinate: .Jacobian(X: X3, Y: Y3,Z: Z3), curve: lhs.curve)
        
    default:
        assert(false, "Combining different coordinate systems not implemented")
        return rhs
    }
}

extension ECPoint {
    public var double: ECPoint {
        let a = curve.field.int(self.curve.a)
        //print("a : \(a)")
        switch coordinate {
        case let .Affine(x, y):
            assert(x != nil, "lhs x set")
            let X1 = x!
            
            assert(y != nil, "lhs y set")
            let Y1 = y!
            
            //print("x1 : \(X1) y1 : \(Y1)")
            //let common = (3 * (X1 ^^ 2) + a) / (2 * Y1)
            let common = (3 * X1 * X1 + a) / (2 * Y1)
            //let X3 = (common ^^ 2) - 2 * X1
            let X3 = common * common - 2 * X1
            let Y3 = common * (X1 - X3) - Y1
            
            return curve[X3, Y3]
        case let .Jacobian(X1, Y1, Z1):
            // Check that P != -P
            // Negative of (X : Y : Z) is (X : -Y : Z)
            assert(Y1 != -Y1, "Can't deal with P == -P")
            
            let X12 = X1 * X1
            
            let Y12 = Y1 * Y1
            let Y14 = Y12 * Y12
            
            var D: FFInt
            if(a == curve.field.int(0)) {
                D = 3 * X12
            } else {
                let Z12 = Z1 * Z1
                let Z14 = Z12 * Z12
                D = 3 * X12 + a * Z14
            }
            
            let X3 = D * D - 8 * X1 * Y12
            let Y3 = D * (4 * X1 * Y12 - X3) - 8 * Y14
            let Z3 = 2 * Y1 * Z1
            
            return ECPoint(coordinate: .Jacobian(X: X3, Y: Y3, Z: Z3), curve: curve)
        }
    }
}

public func * (lhs: BigUInt, rhs: ECPoint) -> ECPoint {
    
    if rhs.isInfinity {
        return rhs
    }
    
    if lhs == 0 {
        return rhs.curve.infinity
    }
    
    if lhs == 2 {
        return rhs.double
    }
    
    let P = rhs
    
    var tally = P.curve.infinity
    
    var increment: ECPoint
    
    //print(lhs)
    
    let lhsBitLength = lhs.highestBitOfUInt256()
    
    //print(lhsBitLength)
    
    tally.convertToJacobian()
    
    var lookup: Array<Any>?
    
    if rhs.curve.domain == EllipticCurveDomain.Secp256k1 && rhs == rhs.curve.G {
        lookup = importLookupTable()
        increment = lookup![0] as! ECPoint
    } else {
        increment = P
        increment.convertToJacobian()
    }
    
    if lookup != nil {
        var i = 0
        for incrementId in lookup! {
            let increment = incrementId as! ECPoint
            if singleBitAt(255 - i) & lhs != 0 {
                tally = tally + increment
            }
            i += 1
        }
    }
    else {
        
        //let valStr = String(lhsBitLength, radix: 10)
        //let length = Int(valStr, radix: 10)!
        //print(lhsBitLength)
        for i in 0 ..< lhsBitLength {
            if singleBitAt(255 - i) & lhs != 0 {
                tally = tally + increment
            }
            increment.convertToAffine()
            
            increment = 2 * increment
            
            increment.convertToJacobian()
        }
    }
    
    tally.convertToAffine()
    
    return tally
}

public func importLookupTable() -> [Any] {
    
    let plistPath = Bundle.main.path(forResource: "Secp256k1BasePointDoublings", ofType: "plist")
    assert(plistPath != nil, "Missing plist")
    
    let plist = NSArray(contentsOfFile: plistPath!)! as! [NSArray]
    
    var lookup: [Any] = []
    
    let field = EllipticCurveDomain.Secp256k1.field
    let one = field.int(1)
    
    for coordinates in plist {
        let x  = coordinates[0] as! NSArray
        let y  = coordinates[1] as! NSArray
        
        let X = field.int(bigUIntFromUInt32Array(nums: [(x[0] as AnyObject).uint32Value!, (x[1] as AnyObject).uint32Value!, (x[2] as AnyObject).uint32Value!, (x[3] as AnyObject).uint32Value!, (x[4] as AnyObject).uint32Value!, (x[5] as AnyObject).uint32Value!, (x[6] as AnyObject).uint32Value!, (x[7] as AnyObject).uint32Value!]))
        let Y = field.int(bigUIntFromUInt32Array(nums: [(y[0] as AnyObject).uint32Value!, (y[1] as AnyObject).uint32Value!, (y[2] as AnyObject).uint32Value!, (y[3] as AnyObject).uint32Value!, (y[4] as AnyObject).uint32Value!, (y[5] as AnyObject).uint32Value!, (y[6] as AnyObject).uint32Value!, (y[7] as AnyObject).uint32Value!]))
        
        let coordinate = ECPoint(coordinate: ECPoint.Coordinate.Jacobian(X: X, Y: Y, Z: one), curve: ECurve(domain: EllipticCurveDomain.Secp256k1)  );
        
        lookup.append(coordinate)
    }
    
   return lookup
    
   /* for coordinates in plist {
        var x : NSArray?
        var y : NSArray?
        for (i, coordinate) in (coordinates as! NSArray).enumerated() {
            if i > 2 {
                break
            }
            if i == 1 {
                x = coordinate as? NSArray
            } else if i == 2 {
                y = coordinate as? NSArray
            }
        }
    
        let score : Int = Int(x?[0] as! String)!
        print(score)
        
        let X = field.int(bigUIntFromUInt32Array(nums: [(x?[0] as AnyObject).uint32Value, (x?[1] as AnyObject).uint32Value, (x?[2] as AnyObject).uint32Value, (x?[3] as AnyObject).uint32Value,(x?[4] as AnyObject).uint32Value ,(x?[5] as AnyObject).uint32Value ,(x?[6] as AnyObject).uint32Value, (x?[7] as AnyObject).uint32Value]))
        
        let Y = field.int(bigUIntFromUInt32Array(nums: [(y?[0] as AnyObject).uint32Value, (y?[1] as AnyObject).uint32Value, (x?[2] as AnyObject).uint32Value, (x?[3] as AnyObject).uint32Value, (x?[4] as AnyObject).uint32Value, (x?[5] as AnyObject).uint32Value, (x?[6] as AnyObject).uint32Value, (x?[7] as AnyObject).uint32Value]))
        
        let coordinate = ECPoint(coordinate: ECPoint.Coordinate.Jacobian(X: X, Y: Y, Z: one), curve: ECurve(domain: EllipticCurveDomain.Secp256k1))
        lookup.append(coordinate)
    }
    
    return lookup*/
}

public func * (lhs: Int, rhs: ECPoint) -> ECPoint {
    let lhsInt = BigUInt(UInt32(lhs))
    
    if rhs.isInfinity {
        return rhs
    }
    
    if lhs == 0 {
        return rhs.curve.infinity
    }
    
    if lhs == 2 {
        return rhs.double
    }
    
    return lhsInt * rhs

}




    
