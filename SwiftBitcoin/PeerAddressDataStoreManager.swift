//
//  PeerAddressDataStoreManager.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/08/29.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import Foundation

public class PeerAddressDataStoreManager {
    
    public static func add(peerAddressMessage: PeerAddressMessage) {
        for peerAddress in peerAddressMessage.peerAddresses {
            if let addressString = peerAddress.IP.addressString {
                let nodeInfo = NodeInfo.create(addressString, Int(peerAddress.port))
                nodeInfo.save()
                print("Address: \(addressString) saved")
            }
        }
    }
}
