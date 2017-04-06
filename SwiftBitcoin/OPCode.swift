//
//  OPCode.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/12/29.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public enum OPCode: UInt8 {
    case OP_0 = 0x00
    case OP_PUSHDATA1 = 0x4c
    case OP_PUSHDATA2 = 0x4d
    case OP_PUSHDATA4 = 0x4e
    case OP_1 = 0x51
    case OP_2 = 0x52
    case OP_3 = 0x53
    case OP_4 = 0x54
    case OP_5 = 0x55
    case OP_6 = 0x56
    case OP_7 = 0x57
    case OP_8 = 0x58
    case OP_9 = 0x59
    case OP_10 = 0x5a
    case OP_11 = 0x5b
    case OP_12 = 0x5c
    case OP_13 = 0x5d
    case OP_14 = 0x5e
    case OP_15 = 0x5f
    case OP_16 = 0x60
    case OP_RETURN = 0x6a
    case OP_DUP = 0x76
    case OP_EQUAL = 0x87
    case OP_EQUALVERIFY = 0x88
    case OP_HASH160 = 0xa9
    case OP_CHECKSIG = 0xac
    case OP_CHECKSIGVERIFY = 0xad
    case OP_CHECKMULTISIG = 0xae
    case OP_CHECKMULTISIGVERIFY = 0xaf
}

extension OPCode {
    func OP_N_to_UInt8() -> UInt8 {
        assert(self.rawValue >= 0x51 && self.rawValue <= 0x60, "ERROR: Invalid OPCode. ONLY OP_1 ~ OP_16 accepted.")
        return self.rawValue - 0x50
    }
}

extension UInt8 {
    func toOPCode() -> OPCode {
        assert(self >= 1 && self <= 16, "ERROR: OP_N, N must be between 1 and 16.")
        return OPCode(rawValue: self + 0x50)!
    }
}
