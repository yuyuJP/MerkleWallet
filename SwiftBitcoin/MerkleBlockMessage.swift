//
//  MerkleBlock.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/12/17.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

/*public func == (left: MerkleBlockMessage, right: MerkleBlockMessage) -> Bool {
    return left.blockHeader == right.blockHeader && left.totalTransactions == right.totalTransactions && left.hashes == right.hashes && left.flags == right.flags
}*/
public func == (left: MerkleBlockMessage, right: MerkleBlockMessage) -> Bool {
    return left.header == right.header && left.partialMerkleTree == right.partialMerkleTree
}


public struct MerkleBlockMessage: Equatable {
    let header: BlockHeader
    let partialMerkleTree: PartialMerkleTree
    //let totalTransactions: UInt32
    //let hashes: [SHA256Hash]
    //let flags: [UInt8]
    
    /*public init(blockHeader: BlockHeader, totalTransactions: UInt32, hashes: [SHA256Hash], flags: [UInt8]) {
        self.blockHeader = blockHeader
        self.totalTransactions = totalTransactions
        self.hashes = hashes
        self.flags = flags
    }*/
    public init(header: BlockHeader, partialMerkleTree: PartialMerkleTree) {
        self.header = header
        self.partialMerkleTree = partialMerkleTree
    }
    
    public var merkleProofIsValid: Bool {
        return header.merkleRoot == partialMerkleTree.rootHash
    }
    
}

extension MerkleBlockMessage: MessagePayload {
    
    public var command: Message.Command {
        return Message.Command.MerkleBlock
    }
    
    public var bitcoinData: NSData {
        let data = NSMutableData()
        data.append(header.bitcoinData as Data)
        
        /*data.appendUInt32(totalTransactions)
        for hash in hashes {
            data.append(hash.bitcoinData as Data)
        }
        for flag in flags {
            data.appendUInt8(flag)
        }*/
        
        data.append(partialMerkleTree.bitcoinData as Data)
        
        return data
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> MerkleBlockMessage? {
        guard let header = BlockHeader.fromBitcoinStream(stream) else {
            print("Failed to parse blockHeader from MerkleBlockMessage")
            return nil
        }
        
        /*guard let totalTransactions = stream.readUInt32() else {
            print("Failed to parse totalTransactions from MerkleBlockMessage")
            return nil
        }
        
        if totalTransactions == 0 {
            print("Failed to parse totalTransactions from MerkleBlockMessage. Total should NOT be zero")
            return nil
        }
        
        guard let hashesCount = stream.readVarInt() else {
            print("Failed to parse hashesCount from MerkleBlockMessage")
            return nil
        }
        
        //TODO: Chack hashesCount is zero or not
        
        var hashes : [SHA256Hash] = []
        
        for i in 0 ..< hashesCount {
            guard let hash = SHA256Hash.fromBitcoinStream(stream) else {
                print("Failed to parse SHA256Hash \(i) from MerkleBlock Message")
                return nil
            }
            hashes.append(hash)
        }
        
        guard let flagsCount = stream.readVarInt() else {
            print("Failed to parse flagsCount from MerkleBlockMessage")
            return nil
        }
        
        //TODO: Chack flagsCount is zero or not
        
        var flags : [UInt8] = []
        
        for i in 0 ..< flagsCount {
            guard let flag = stream.readUInt8() else {
                print("Failed to parse flag \(i) from MerkleBlock Message")
                return nil
            }
            flags.append(flag)
        }
        
        return MerkleBlockMessage(blockHeader: blockHeader, totalTransactions: totalTransactions, hashes: hashes, flags: flags)
        */
        guard let partialMerkleTree = PartialMerkleTree.fromBitcoinStream(stream) else {
            print("Failed to parse partialMerkleTree from FilteredBlock")
            return nil
        }
        let merkleBlock = MerkleBlockMessage(header: header, partialMerkleTree: partialMerkleTree)
        if !merkleBlock.merkleProofIsValid {
            print("Failed to parse FilteredBlock, invalid merkle proof")
            return nil
        }
        return merkleBlock
    }
    
}
