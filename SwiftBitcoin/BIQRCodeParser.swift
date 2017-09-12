//
//  BIQRCodeParser.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/07/01.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation

public class BIQRCodeParser {
    
    private let qrcodeString: String
    
    public init(string: String) {
        self.qrcodeString = string
    }
    
    public var address: String? {
        
        if validAddressString(addressStr: self.qrcodeString) {
            
            return self.qrcodeString
            
        } else {
            
            if let dir_address = extractWithRegx(self.qrcodeString, regx: "bitcoin:*") {
                
                if validAddressString(addressStr: dir_address) {
                    return dir_address
                }
                
            } else {
                
                if let address = extractWithRegx(self.qrcodeString, regx: "bitcoin:(.*)\\?.*") {
                    if validAddressString(addressStr: address) {
                        return address
                    }
                }
            }
        }
        
        return nil
    }
    
    private func validAddressString(addressStr: String) -> Bool {
        
        guard let type = addressStr.determinOutputScriptTypeWithAddress() else {
            return false
        }
            
        let pubkeyPrefix = BitcoinPrefixes.pubKeyPrefix
        var prefix = pubkeyPrefix
            
        if type == .P2SH {
            prefix = BitcoinPrefixes.scriptHashPrefix
        }
            
        guard let _ = addressStr.publicAddressToPubKeyHash(prefix) else {
            return false
        }
            
        return true
    }
    
    public var amount: String? {
        return getParameterValue(self.qrcodeString, param: "amount")
    }
    
    public var label: String? {
        return getParameterValue(self.qrcodeString, param: "label")
    }
    
    public var message: String? {
        return getParameterValue(self.qrcodeString, param: "message")
    }
    
    public var isValid: Bool {
        if address != nil {
            return true
        }
        return false
    }
    
    private func extractWithRegx(_ string: String, regx: String) -> String? {
        let result = string.replacingOccurrences(of: regx, with: "$1", options: .regularExpression, range: string.startIndex ..< string.endIndex)
        
        if result == string {
            return nil
        }
        return result
    }
    
    private func getParameterValue(_ uriString: String, param: String) -> String? {
        let uri = URL(string: uriString)!
        
        let queryItems = URLComponents(url: uri, resolvingAgainstBaseURL: false)?.queryItems
        
        let paramValue = queryItems?.filter({$0.name == param}).first
        
        return paramValue?.value
    }
    
}
