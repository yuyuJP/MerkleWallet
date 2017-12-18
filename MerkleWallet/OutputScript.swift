//
//  OutPutScript.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/12/24.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation


public struct OutputScript {
    
    public let type: OutputScriptType
    public let P2PKH_script: P2PKH_OutputScript?
    public let P2SH_script: P2SH_OutputScript?
    
    public init(P2PKH_script: P2PKH_OutputScript?, P2SH_script: P2SH_OutputScript?, type: OutputScriptType) {
        self.P2PKH_script = P2PKH_script
        self.P2SH_script = P2SH_script
        self.type = type
    }
    
    public init?(data: NSData) {
        let stream = InputStream(data: data as Data)
        stream.open()
        let P2PKH_script = P2PKH_OutputScript.fromBitcoinStream(stream)
        stream.close()
        
        if P2PKH_script != nil {
            self.P2PKH_script = P2PKH_script
            self.P2SH_script = nil
            self.type = .P2PKH
        } else {
            let stream_ = InputStream(data: data as Data)
            stream_.open()
            let P2SH_script = P2SH_OutputScript.fromBitcoinStream(stream_)
            stream_.close()
            
            if P2SH_script != nil {
                self.P2PKH_script = nil
                self.P2SH_script = P2SH_script
                self.type = .P2SH
            } else {
                return nil
            }
        }
    }
    
    public var hash160: RIPEMD160HASH {
        switch type {
        case .P2PKH:
            return P2PKH_script!.hash160
        case .P2SH:
            return P2SH_script!.hash160
        }
    }
    
    public var typeString: String {
        switch type {
        case .P2PKH:
            return "P2PKH"
        case .P2SH:
            return "P2SH"
        }
    }

}
