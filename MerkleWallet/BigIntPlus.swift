//
//  BigIntPlus.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/09/24.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation
import BigInt

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
        /*var candidate = BigUInt(0)
        candidate.storage[0] = BigUInt.Word(arc4random_uniform(UInt32.max))
        candidate.storage[0] = candidate.storage[0] << 32
        candidate.storage[0] += BigUInt.Word(arc4random_uniform(UInt32.max))
        
        candidate.storage[1] = BigUInt.Word(arc4random_uniform(UInt32.max))
        candidate.storage[1] = candidate.storage[1] << 32
        candidate.storage[1] += BigUInt.Word(arc4random_uniform(UInt32.max))
        
        candidate.storage[2] = BigUInt.Word(arc4random_uniform(UInt32.max))
        candidate.storage[2] = candidate.storage[2] << 32
        candidate.storage[2] += BigUInt.Word(arc4random_uniform(UInt32.max))
        
        candidate.storage[3] = BigUInt.Word(arc4random_uniform(UInt32.max))
        candidate.storage[3] = candidate.storage[3] << 32
        candidate.storage[3] += BigUInt.Word(arc4random_uniform(UInt32.max))
        */
        
        var a1: UInt = UInt(arc4random_uniform(UInt32.max))
        a1 = a1 << 32
        a1 += UInt(arc4random_uniform(UInt32.max))
        
        var a2: UInt = UInt(arc4random_uniform(UInt32.max))
        a2 = a2 << 32
        a2 += UInt(arc4random_uniform(UInt32.max))
        
        var a3: UInt = UInt(arc4random_uniform(UInt32.max))
        a3 = a3 << 32
        a3 += UInt(arc4random_uniform(UInt32.max))
        
        var a4: UInt = UInt(arc4random_uniform(UInt32.max))
        a4 = a4 << 32
        a4 += UInt(arc4random_uniform(UInt32.max))
        
        let candidate = BigUInt(words: [a1, a2, a3, a4])
        
        if candidate < max {
            return candidate
        }
    }
}

func bigUIntFromUInt32Array(nums: [UInt32]) -> BigUInt {
    assert(nums.count == 8, "Num array count must be 8")
    
    /*var value = BigUInt(0)
    value.storage[0] = BigUInt.Word(nums[6])
    value.storage[0] = value.storage[0] << 32
    value.storage[0] += BigUInt.Word(nums[7])
    
    value.storage[1] = BigUInt.Word(nums[4])
    value.storage[1] = value.storage[1] << 32
    value.storage[1] += BigUInt.Word(nums[5])
    
    value.storage[2] = BigUInt.Word(nums[2])
    value.storage[2] = value.storage[2] << 32
    value.storage[2] += BigUInt.Word(nums[3])
    
    value.storage[3] = BigUInt.Word(nums[0])
    value.storage[3] = value.storage[3] << 32
    value.storage[3] += BigUInt.Word(nums[1])*/
    
    var num1: UInt = UInt(nums[6])
    num1 = num1 << 32
    num1 += UInt(nums[7])
    
    var num2: UInt = UInt(nums[4])
    num2 = num2 << 32
    num2 += UInt(nums[5])
    
    var num3: UInt = UInt(nums[2])
    num3 = num3 << 32
    num3 += UInt(nums[3])
    
    var num4: UInt = UInt(nums[0])
    num4 = num4 << 32
    num4 += UInt(nums[1])
    
    let value = BigUInt(words: [num1, num2, num3, num4])
    
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
        var num: UInt = 2147483648
        num = num << 32
        
        let number = BigUInt(words: [0, 0, 0, num])
        
        return number
    case 255:
        //let num = [0,0,0,0,0,0,0,1]
        return BigUInt(1)
        
    default:
        var words: [UInt] = [0, 0, 0, 0]
        var index: Int = 7 - position / 32
        let bit: Int = 31 - (position % 32)
        
        let res = rapseByPositivePower(radix: 2, power: UInt32(bit))
        var isHigh = false
        
        if index % 2 == 1 {
            isHigh = true
        }
        index = index / 2
        
        words[index] = UInt(res)
        if isHigh {
            words[index] = words[index] << 32
        }
        
        let result = BigUInt(words: words)
        
        return result
    }
}
