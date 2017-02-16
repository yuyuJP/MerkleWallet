//
//  BigIntAddition.swift
//  FInt
//
//  Created by Yusuke Asai on 2016/10/01.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

func bigIntPow256(_ n : Int, _ m : Int) -> BigUInt {
    
    var val = BigUInt(n)
    var dicimal = BigUInt(1)
    
    for _ in 0 ..< m {
        dicimal = dicimal * 256
    }
    
    val = val * dicimal
    return val
}


func bigIntPow256(_ n : UInt32, _ m : Int) -> BigUInt {
    
    var val = BigUInt(n)
    var dicimal = BigUInt(1)
    
    for _ in 0 ..< m {
        dicimal = dicimal * 256
    }
    
    val = val * dicimal
    return val
}


func intArrayToBigInt(nums : [UInt8]) -> BigUInt {
    var bigInt = BigUInt(0)
    
    for (i,num) in nums.enumerated() {
        bigInt += bigIntPow256(Int(num), nums.count - i - 1)
        //keyBigInt += bigIntPow10(Int(byte), i)
    }
    return bigInt
}


func intArrayToBigInt(nums : [Int]) -> BigUInt {
    var bigInt = BigUInt(0)
    
    for (i,num) in nums.enumerated() {
        bigInt += bigIntPow256(num, nums.count - i - 1)
        //keyBigInt += bigIntPow10(Int(byte), i)
    }
    return bigInt
}

func intArrayToBigInt(nums : [UInt32]) -> BigUInt {
    var bigInt = BigUInt(0)
    
    for (i,num) in nums.enumerated() {
        bigInt += bigIntPow256(num, nums.count - i - 1)
        //keyBigInt += bigIntPow10(Int(byte), i)
    }
    return bigInt
}


func secureRandom(_ max: BigUInt) -> BigUInt {
    while(true) {
        var candidate = BigUInt(0)
        candidate[0] = BigUInt.Digit(arc4random_uniform(UInt32.max))
        candidate[0] = candidate[0] << 32
        candidate[0] += BigUInt.Digit(arc4random_uniform(UInt32.max))
    
        candidate[1] = BigUInt.Digit(arc4random_uniform(UInt32.max))
        candidate[1] = candidate[1] << 32
        candidate[1] += BigUInt.Digit(arc4random_uniform(UInt32.max))
        
        candidate[2] = BigUInt.Digit(arc4random_uniform(UInt32.max))
        candidate[2] = candidate[1] << 32
        candidate[2] += BigUInt.Digit(arc4random_uniform(UInt32.max))
        
        candidate[3] = BigUInt.Digit(arc4random_uniform(UInt32.max))
        candidate[3] = candidate[1] << 32
        candidate[3] += BigUInt.Digit(arc4random_uniform(UInt32.max))
        
        if candidate < max {
            return candidate
        }
    }
}

func bigUIntFromUInt32Array(nums: [UInt32]) -> BigUInt {
    assert(nums.count == 8, "Num array count must be 8")
    
    var value = BigUInt(0)
    value[0] = BigUInt.Digit(nums[6])
    value[0] = value[0] << 32
    value[0] += BigUInt.Digit(nums[7])
    
    value[1] = BigUInt.Digit(nums[4])
    value[1] = value[1] << 32
    value[1] += BigUInt.Digit(nums[5])

    value[2] = BigUInt.Digit(nums[2])
    value[2] = value[2] << 32
    value[2] += BigUInt.Digit(nums[3])
    
    value[3] = BigUInt.Digit(nums[0])
    value[3] = value[3] << 32
    value[3] += BigUInt.Digit(nums[1])
    
    return value
}



func rapseByPositivePower(radix: UInt32, power: UInt32) -> UInt32 {
    var res: UInt32 = 1
    if power > 0 {
        for _ in 1...power {
            res = res * radix
        }
    }
    return res
}

func singleBitAt(_ position: Int) -> BigUInt {
    switch position {
    case 0:
        //let num = [2147483648,0,0,0,0,0,0,0]
        var number = BigUInt(0)
        number[3] = 2147483648
        number[3] = number[3] << 32
        return number
    case 255:
        //let num = [0,0,0,0,0,0,0,1]
        return BigUInt(1)
    
    default:
        var result = BigUInt(0)
        var index: Int = 7 - position / 32
        let bit: Int = 31 - (position % 32)
    
        let res = rapseByPositivePower(radix: 2, power: UInt32(bit))
        var isHigh = false
    
        if index % 2 == 1 {
            isHigh = true
        }
        index = index / 2
        
        result[index] = UInt64(res)
        if isHigh {
            result[index] = result[index] << 32
        }
        return result
    }
}

