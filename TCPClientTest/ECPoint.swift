//
//  ECPoint.swift
//  FInt
//
//  Created by Yusuke Asai on 2016/10/01.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public struct ECPoint : CustomStringConvertible, Equatable {
    public let curve : ECurve
    
    public enum Coordinate {
        case Affine(x: FFInt?, y: FFInt?)
        case Jacobian(X: FFInt, Y: FFInt, Z: FFInt)
    }
    
    public var coordinate: Coordinate
    
    mutating public func convertToJacobian() {
        switch coordinate {
        case let .Affine(x, y):
            if let x_safe = x {
                coordinate = Coordinate.Jacobian(X: x_safe, Y: y!, Z: self.curve.field.int(1))
            } else {
                coordinate = Coordinate.Jacobian(X: self.curve.field.int(1), Y: self.curve.field.int(1), Z: self.curve.field.int(0))
            }
        case .Jacobian:
            assert(false, "Already a Jacobian coordinate")
        }
    }
    
    mutating public func convertToAffine() {
        switch coordinate {
            case let .Jacobian(X, Y, Z):
                if Z == curve.field.int(1) {
                    coordinate = Coordinate.Affine(x: X, y: Y)
                } else {
                    let Z2 = Z * Z
                    let Z3 = Z2 * Z
                    coordinate = Coordinate.Affine(x: X / Z2, y: Y / Z3)
            }
            
            case .Affine:
                assert(false, "Already an affine coordinate")
        }
    }
    
    public init(x: FFInt?, y: FFInt?, curve: ECurve) {
        self.curve = curve
        
        self.coordinate = .Affine(x: x, y: y)
    }
    
    public init(coordinate: Coordinate, curve: ECurve) {
        self.curve = curve
        self.coordinate = coordinate
    }
    
    static public func infinity (_ curve: ECurve) -> ECPoint {
        return ECPoint(x: nil, y: nil, curve: curve)
    }
    
    public var isInfinity: Bool {
        switch coordinate {
        case let .Affine(x,y):
            return x == nil && y == nil
        case let .Jacobian(X, Y, Z):
            return X == curve.field.int(1) && Y == curve.field.int(1) && Z == curve.field.int(0) // Page 88 of EC guide
        }
    }
    
    public var description: String {
        if self.isInfinity {
            return "Infinity"
        } else {
            switch coordinate {
            case let .Affine(x,y):
                return "(\(x!.value.description), \( y!.value.description ))"
            case let .Jacobian(X, Y, Z):
                return "(\(X.value.description), \( Y.value.description ), \( Z.value.description ))"
            }
        }
    }
    
    public var toData : NSData {
        var bytes: [UInt8] = [0x04]
        let result = NSMutableData(bytes: &bytes, length: bytes.count)
        
        switch coordinate {
        case let .Affine(x,y):
            result.append(x!.value.serialize())
            result.append(y!.value.serialize())
            
        default:
            assert(false, "Not implemented")
            return NSData()
        }
        
        return result as NSData
    }
    
    public var toCompressedData: NSData {
        switch coordinate {
        case let .Affine(x, y):
            let lastDigit = UInt8(y!.value.serialize().last!)
            var bytes: [UInt8] = []
            if lastDigit % 2 == 0 {
                bytes.append(0x02)
            } else {
                bytes.append(0x03)
            }
            
            let result = NSMutableData(bytes: &bytes, length: bytes.count)
            result.append(x!.value.serialize())
            return result as NSData
            
        default:
            assert(false, "Not implemented")
            return NSData()
        }
    }
}

public func == (lhs: ECPoint, rhs: ECPoint) -> Bool {
    
    switch (lhs.coordinate,rhs.coordinate) {
    case let (.Affine(x1,y1),.Affine(x2,y2) ):
        return lhs.curve == rhs.curve && x1 == x2 && y1 == y2
    case let (.Jacobian(X1,Y1,Z1),.Jacobian(X2,Y2,Z2)):
        return lhs.curve == rhs.curve && X1 == X2 && Y1 == Y2 && Z1 == Z2
    default:
        assert(false, "Comparing different coordinate systems is not implemented")
        return false
    }
    
}


