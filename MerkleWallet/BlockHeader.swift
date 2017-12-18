//
//  BlockHeader.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/11/08.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation
import BigInt

public func == (left: BlockHeader, right: BlockHeader) -> Bool {
    return left.version == right.version &&
        left.previousBlockHash == right.previousBlockHash &&
        left.merkleRoot == right.merkleRoot &&
        left.timestamp == right.timestamp &&
        left.compactDifficulty == right.compactDifficulty &&
        left.nonce == right.nonce
}

public protocol BlockHeaderParameters {
    var blockVersion: UInt32 { get }
}

public struct BlockHeader: Equatable {
    public let version: UInt32
    public let previousBlockHash: SHA256Hash
    public let merkleRoot: SHA256Hash
    public let timestamp: NSDate
    public let compactDifficulty: UInt32
    public let nonce: UInt32
    
    static private let largestDifficulty = BigUInt(1) << 256
    private var cachedHash: SHA256Hash?
    
    public init(params: BlockHeaderParameters, previousBlockHash: SHA256Hash, merkleRoot: SHA256Hash, timestamp: NSDate, compactDifficulty: UInt32, nonce: UInt32) {
        self.init(version: params.blockVersion, previousBlockHash: previousBlockHash, merkleRoot: merkleRoot, timestamp: timestamp, compactDifficulty: compactDifficulty, nonce: nonce)
    }
    
    public init(version: UInt32, previousBlockHash: SHA256Hash, merkleRoot: SHA256Hash, timestamp: NSDate, compactDifficulty: UInt32, nonce: UInt32) {
        self.version = version
        self.previousBlockHash = previousBlockHash
        self.merkleRoot = merkleRoot
        self.timestamp = timestamp
        self.compactDifficulty = compactDifficulty
        self.nonce = nonce
    }
    
    public var hash: SHA256Hash {
        //let data = SHA256.digest(SHA256.digest(bitcoinData))
        let data = Hash256.digest(bitcoinData)
        return SHA256Hash(data.reversedData)
    }
    
    public var difficulty: BigUInt {
        let compactDifficultyData = NSMutableData()
        compactDifficultyData.appendUInt32(compactDifficulty, endianness: .BigEndian)
        return BigUInt(compactDifficultyData as Data)
    }
    
    public var work: BigUInt {
        return BlockHeader.largestDifficulty / (difficulty + BigUInt(1))
    }
}

extension BlockHeader: BitcoinSerializable {
    public var bitcoinData: NSData {
        let data = NSMutableData()
        data.appendUInt32(version)
        data.appendNSData(previousBlockHash.bitcoinData)
        data.appendNSData(merkleRoot.bitcoinData)
        data.appendDateAs32BitUnixTimestamp(timestamp)
        data.appendUInt32(compactDifficulty)
        data.appendUInt32(nonce)
        return data
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> BlockHeader? {
        let version = stream.readUInt32()
        if version == nil {
            print("Failed to parse version from BlockHeader")
            return nil
        }
        let previousBlockHash = SHA256Hash.fromBitcoinStream(stream)
        if previousBlockHash == nil {
            print("Failed to parse previousBlockHash from BlockHeader")
            return nil
        }
        let merkleRoot = SHA256Hash.fromBitcoinStream(stream)
        if merkleRoot == nil {
            print("Failed to parse merkleRoot from BlockHeader")
            return nil
        }
        let timestamp = stream.readDateFrom32BitUnixTimestamp()
        if timestamp == nil {
            print("Failed to parse timestamp from BlockHeader")
            return nil
        }
        let compactDifficulty = stream.readUInt32()
        if compactDifficulty == nil {
            print("Failed to parse compactDifficulty from BlockHeader")
            return nil
        }
        let nonce = stream.readUInt32()
        if nonce == nil {
            print("Failed to parse nonce from BlockHeader")
            return nil
        }
        return BlockHeader(version: version!,
                           previousBlockHash: previousBlockHash!,
                           merkleRoot: merkleRoot!,
                           timestamp: timestamp!,
                           compactDifficulty: compactDifficulty!,
                           nonce: nonce!)
    }
}
