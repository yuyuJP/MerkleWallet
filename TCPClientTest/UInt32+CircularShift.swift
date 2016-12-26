//
//  UInt32+CircularShift.swift
//  RIPEMD-160
//
//  Created by Yusuke Asai on 2016/10/09.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//


precedencegroup MultiplicationPrecedence {
    associativity: left
    higherThan: AdditionPrecedence
}

infix operator  ~<< : MultiplicationPrecedence

public func ~<< (lhs: UInt32, rhs: Int) -> UInt32 {
    return (lhs << UInt32(rhs)) | (lhs >> UInt32(32 - rhs));
}
