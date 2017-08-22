//
//  NodeInfo.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/08/23.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation
import RealmSwift

public class NodeInfo: Object {
    static let realm = try! Realm()
    
    dynamic var node = ""
    
    public static func create(_ node: String) -> NodeInfo {
        let nodeInfo = NodeInfo()
        nodeInfo.node = node
        
        return nodeInfo
    }
    
    public static func loadAll() -> [NodeInfo] {
        let nodeInfos = realm.objects(NodeInfo.self)
        var ret: [NodeInfo] = []
        for nodeInfo in nodeInfos {
            ret.append(nodeInfo)
        }
        return ret
    }
}
