//
//  BloomFilter.swift
//  Murmurhash3
//
//  Created by Yusuke Asai on 2016/10/23.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public class BloomFilter {
    
    public static var sharedFilter : BloomFilter? = nil
    
    private var byteArray : [UInt8]
    private let length : UInt32
    public let hash_funcs : UInt32
    public let tweak : UInt32
    
    public init(length: UInt32, hash_funcs: UInt32, tweak: UInt32) {
        
        self.byteArray = [UInt8](repeating: 0, count: Int(length))
        self.length = length
        self.hash_funcs = hash_funcs
        self.tweak = tweak
    }
    
    public var filterData : NSData {
        
        return NSData(bytes: byteArray, length: byteArray.count)
    }
    
    private func hash(byteData: [UInt8], hashNum: UInt32) -> UInt32 {
        return Murmurhash3.hash32Bytes(key: byteData, seed: (hashNum &* 0xfba4c795 &+ tweak)) % UInt32(length * 8)
    }
    
    private func filterAdd(bytes: [UInt8]) {
        for i in 0 ..< hash_funcs {
            
            let idx = self.hash(byteData: bytes, hashNum: i)
            
            byteArray[Int(idx >> 3)] |= UInt8(1 << (7 & idx))
        }
    }
    
    public func add(data: NSData) {
        filterAdd(bytes: data.toBytes())
    }
    
    public func add(string: String) {
        filterAdd(bytes: [UInt8](string.utf8))
    }
    
    /* For test use only*/
    public func contain(data: String) -> Bool {
        for i in 0 ..< hash_funcs {
            let hash_value = Murmurhash3.hash32Bytes(key: [UInt8](data.utf8), seed: i &* 0xfba4c795 &+ tweak)
            let adjust_hash_value = hash_value % UInt32(byteArray.count * 8)
            let idx = adjust_hash_value >> 3
            if byteArray[Int(idx)] != 0 {
                return true
            }
        }
        
        return false
    }
}
