//
//  Hash256+160.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/11/29.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public struct Hash256 {
    public static func digest(_ input: NSData) -> NSData {
        let data = SHA256.digest(SHA256.digest(input))
        return data
    }
    
    public static func hexStringDigest(_ hexStr: String) -> NSData {
        let data: NSData = SHA256.digest(SHA256.hexStringDigest(hexStr))
        return data
    }
    
    public static func digestHexString(_ input: NSData) -> String {
        return digest(input).toHexString()
    }
    
    public static func hexStringDigestHexString(_ hexStr: String) -> String {
        return hexStringDigest(hexStr).toHexString()
    }
    
}
