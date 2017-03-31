//
//  Wif.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2017/02/16.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation

public class Wif {
    
    private let privateKeyPrefix: UInt8
    
    private var _privateKeyHexString: String!
    
    private var _isCompressedPubKey: Bool!
    
    public init(privateKeyPrefix: UInt8) {
        self.privateKeyPrefix = privateKeyPrefix
    }
    
    public var privateKeyHexString: String {
        return _privateKeyHexString
    }
    
    public var isCompressedPublicKey: Bool {
        return _isCompressedPubKey
    }
    
    public func importWif(_ wif: String) -> Bool {
        if !wif.base58AlphabetContain() {
            return false
        }
        
        guard let wifBytes_ = wif.base58StringToNSData()?.toBytes() else {
            return false
        }
        
        var wifBytes = wifBytes_
        
        if privateKeyPrefix != wifBytes[0] {
            return false
        }
        
        //Wif corresponding to a compreesed public key
        if wifBytes.count == 38 {
            if wifBytes.last! != 0x01 {
                return false
            }
            wifBytes.removeLast()
            _isCompressedPubKey = true
        
        //Wif corresponding to an uncompreesed public key
        } else if wifBytes.count == 37 {
            _isCompressedPubKey = false
        } else {
            return false
        }
        
        var checkSumBytes: [UInt8] = []
        
        for _ in 0 ..< 4 {
            checkSumBytes.insert(wifBytes.last!, at: 0)
            wifBytes.removeLast()
        }
        
        let privKeyData = NSData(bytes: wifBytes, length: wifBytes.count)
        var hash256 = Hash256.digest(privKeyData).toBytes()
        
        var checkSumCandidate: [UInt8] = []
        
        for _ in 0 ..< 4 {
            checkSumCandidate.append(hash256.first!)
            hash256.removeFirst()
        }
        
        if checkSumBytes != checkSumCandidate {
            return false
        }
        
        wifBytes.removeFirst()
        
        _privateKeyHexString = NSData(bytes: wifBytes, length: wifBytes.count).toHexString()
        
        return true
    }
    
    //Use this method when there is no need to verify checksum
    public func importLegitimateWif(_ wif: String) {
        if !importWif(wif) {
            assert(false, "Failed to import wif. This method is intended to be used if wif that you try to import is obviously 'legitimate'.")
        }
    }
}
