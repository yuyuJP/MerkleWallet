//
//  MerkleTreeNode.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/03/24.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation

public func == (left: MerkleTreeNode, right: MerkleTreeNode) -> Bool {
    return left.hash == right.hash &&
        left.left == right.left &&
        left.right == right.right
}


public class MerkleTreeNode: Equatable {
    let hash: SHA256Hash
    let left: MerkleTreeNode?
    let right: MerkleTreeNode?
    
    public init(hash: SHA256Hash, left: MerkleTreeNode?, right: MerkleTreeNode?) {
        self.hash = hash
        self.left = left
        self.right = right
    }
}
