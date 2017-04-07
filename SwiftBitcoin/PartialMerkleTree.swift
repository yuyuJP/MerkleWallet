//
//  PartialMerkleTree.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/03/24.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation

public func == (left: PartialMerkleTree, right: PartialMerkleTree) -> Bool {
    return left.totalLeafNodes == right.totalLeafNodes &&
        left.hashes == right.hashes &&
        left.flags == right.flags &&
        left.rootHash == right.rootHash &&
        left.matchingHashes == right.matchingHashes
}

public struct PartialMerkleTree: Equatable{
    public let totalLeafNodes: UInt32
    public let hashes: [SHA256Hash]
    public let flags: [UInt8]
    public let rootHash: SHA256Hash
    public let matchingHashes: [SHA256Hash]
    
    public init?(totalLeafNodes: UInt32, hashes: [SHA256Hash], flags: [UInt8]) {
        self.totalLeafNodes = totalLeafNodes
        self.hashes = hashes
        self.flags = flags
        
        let height = PartialMerkleTree.treeHeightWithtotalLeafNodes(totalLeafNodes)
        var matchingHashes: [SHA256Hash] = []
        var flagBitIndex = 0
        var hashIndex = 0
        if let merkleRoot = PartialMerkleTree.merkleTreeNodeWithHeight(height,
                                                                       hashes: hashes,
                                                                       flags: flags,
                                                                       matchingHashes: &matchingHashes,
                                                                       flagBitIndex: &flagBitIndex,
                                                                       hashIndex: &hashIndex) {
            self.rootHash = merkleRoot.hash
            self.matchingHashes = matchingHashes
            
            // Fail if there are any unused hashes.
            if hashIndex < hashes.count {
                return nil
            }
            // Fail if there are unused flag bits, except for the minimum number of bits necessary to
            // pad up to the next full byte.
            if (flagBitIndex / 8 != flags.count - 1) && (flagBitIndex != flags.count * 8) {
                return nil
            }
            // Fail if there are any non-zero bits in the padding section.
            while flagBitIndex < flags.count * 8 {
                let flag = PartialMerkleTree.flagBitAtIndex(flagBitIndex, flags: flags)
                flagBitIndex += 1
                if flag == 1 {
                    return nil
                }
            }
            
        } else {
            self.rootHash = SHA256Hash()
            self.matchingHashes = []
            return nil
        }
    }
    
    private static func treeHeightWithtotalLeafNodes(_ totalLeafNodes: UInt32) -> Int {
        return Int(ceil(log2(Double(totalLeafNodes))))
    }
    
    private static func merkleTreeNodeWithHeight(_ height: Int,
                                                 hashes: [SHA256Hash],
                                                 flags:[UInt8],
                                                 matchingHashes: inout [SHA256Hash],
                                                 flagBitIndex: inout Int,
                                                 hashIndex: inout Int) -> MerkleTreeNode? {
        
        if hashIndex >= hashes.count {
            //We have run out of hashes without successfully building the tree.
            return nil
        }
        if flagBitIndex >= flags.count * 8 {
            // We have run out of flags without sucessfully building the tree.
            return nil
        }
        
        
        let flag = flagBitAtIndex(flagBitIndex, flags: flags)
        flagBitIndex += 1
        
        var nodeHash: SHA256Hash
        var leftNode: MerkleTreeNode! = nil
        var rightNode: MerkleTreeNode! = nil
        if height == 0 {
            nodeHash = hashes[hashIndex]
            hashIndex += 1
            if flag == 1 {
                matchingHashes.append(nodeHash)
            }
        } else {
            if flag == 0 {
                nodeHash = hashes[hashIndex]
                hashIndex += 1
                
            } else {
                leftNode = merkleTreeNodeWithHeight(height - 1,
                                                    hashes: hashes,
                                                    flags: flags,
                                                    matchingHashes: &matchingHashes,
                                                    flagBitIndex: &flagBitIndex,
                                                    hashIndex: &hashIndex)
                rightNode = merkleTreeNodeWithHeight(height - 1,
                                                     hashes: hashes,
                                                     flags: flags,
                                                     matchingHashes: &matchingHashes,
                                                     flagBitIndex: &flagBitIndex,
                                                     hashIndex: &hashIndex)
                
                if rightNode == nil {
                    rightNode = leftNode
                }
                
                let hashData = NSMutableData()
                hashData.appendNSData(leftNode.hash.data.reversedData)
                hashData.appendNSData(rightNode.hash.data.reversedData)
                nodeHash = SHA256Hash(Hash256.digest(hashData).reversedData)
            }
        }
        return MerkleTreeNode(hash: nodeHash, left: leftNode, right: rightNode)
    }
    
    private static func flagBitAtIndex(_ index: Int, flags: [UInt8]) -> UInt8 {
        precondition(index < flags.count * 8)
        let flagByte = flags[Int(index / 8)]
        return (flagByte >> UInt8(index % 8)) & 1
    }
}

extension PartialMerkleTree: BitcoinSerializable {
    public var bitcoinData: NSData {
        let data = NSMutableData()
        data.appendUInt32(totalLeafNodes)
        data.appendVarInt(hashes.count)
        for hash in hashes {
            data.appendNSData(hash.bitcoinData)
        }
        data.appendVarInt(flags.count)
        for flag in flags {
            data.appendUInt8(flag)
        }
        return data
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> PartialMerkleTree? {
        
        guard let totalLeafNodes = stream.readUInt32() else {
            print("Failed to parse totalLeafNodes from PartialMerkleTree")
            return nil
        }
 
        guard let hashesCount = stream.readVarInt() else {
            print("Failed to parse hashesCount from PartialMerkleTree")
            return nil
        }
        
        var hashes: [SHA256Hash] = []
        for i in 0 ..< hashesCount {
            guard let hash = SHA256Hash.fromBitcoinStream(stream) else {
                print("Failed to parse hash \(i) from PartialMerkleTree")
                return nil
            }
            hashes.append(hash)
        }
        
        guard let flagBytesCount = stream.readVarInt() else {
            print("Failed to parse flagBytesCount from PartialMerkleTree")
            return nil
        }
        
        var flags: [UInt8] = []
        for i in 0 ..< flagBytesCount {
            guard let flagByte = stream.readUInt8() else {
                print("Failed to parse flagByte \(i) from PartialMerkleTree")
                return nil
            }
            flags.append(flagByte)
        }
        
        return PartialMerkleTree(totalLeafNodes: totalLeafNodes, hashes: hashes, flags: flags)
    }
}
