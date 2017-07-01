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
        print(qrcodeString)
    }
    
    public var address: String? {
        let address = extractWithRegx(self.qrcodeString, regx: "bitcoin:(.*)\\?.*")
        //TODO: Check the extracted address's validity before passing the value
        
        return address
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
