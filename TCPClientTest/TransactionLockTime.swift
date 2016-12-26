//
//  TransactionLockTime.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/12/13.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public func == (left: Transaction.LockTime, right: Transaction.LockTime) -> Bool {
    switch (left, right) {
    case (.AlwaysLocked, .AlwaysLocked):
        return true
    case let (.BlockHeight(leftBlockHeight), .BlockHeight(rightBlockHeight)):
        return leftBlockHeight == rightBlockHeight
    case let (.Date(leftDate), .Date(rightDate)):
        return leftDate == rightDate
    default:
        return false
    }
}

public extension Transaction {
    
    public enum LockTime: Equatable {
        
        case AlwaysLocked
        
        case BlockHeight(UInt32)
        
        case Date(NSDate)
        
        public static func fromRaw(_ raw: UInt32) -> LockTime? {
            switch raw {
            case 0:
                return .AlwaysLocked
            case 1 ..< 500000000:
                return .BlockHeight(raw)
            default:
                return .Date(NSDate(timeIntervalSince1970: TimeInterval(raw)))
            }
        }
        
        public var rawValue: UInt32 {
            switch self {
            case .AlwaysLocked:
                return 0
            case let .BlockHeight(blockHeight):
                return blockHeight
            case let .Date(date):
                return UInt32(date.timeIntervalSince1970)
                
            }
        }
    }
}
