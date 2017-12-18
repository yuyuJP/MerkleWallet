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
    
    @objc dynamic var node = ""
    //Port ZERO means the value is not properly set yet.
    @objc dynamic var port = 0
    
    public static func create(_ node: String, _ port: Int) -> NodeInfo {
        let nodeInfo = NodeInfo()
        nodeInfo.node = node
        nodeInfo.port = port
        return nodeInfo
    }
    
    public func save() {
        try! NodeInfo.realm.write {
            NodeInfo.realm.add(self)
        }
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
