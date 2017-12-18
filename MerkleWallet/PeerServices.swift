//
//  PeerServices.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/10/30.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public func == (left: PeerServices, right: PeerServices) -> Bool {
    return left.value == right.value
}


public struct PeerServices: Equatable {
    public let value: UInt64
    
    public init(rawValue value: UInt64) { self.value = value }
    public init(_ nilLiteral: ()) { value = 0 }
    public var rawValue: UInt64 { return value }
    
    public static var allZeros: PeerServices { return PeerServices(rawValue: 0) }
    
    public static var None: PeerServices { return PeerServices(rawValue: 0) }
    // This node can be asked for full blocks instead of just headers.
    public static var NodeNetwork: PeerServices { return PeerServices(rawValue: 1 << 0) }
}
