//
//  ByteConverter.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/10/15.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

func toByteArray<T>(_ value: T) -> [UInt8] {
    var data = [UInt8](repeating: 0, count: MemoryLayout<T>.size)
    data.withUnsafeMutableBufferPointer {
        UnsafeMutableRawPointer($0.baseAddress!).storeBytes(of: value, as: T.self)
    }
    return data
}
