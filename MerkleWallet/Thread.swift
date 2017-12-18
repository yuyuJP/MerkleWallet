//
//  Thread.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/10/16.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public class CFThread : Thread {
    var runLoop: RunLoop!
    var completionBlock: (() -> Void)?
    
    public override func main() {
        runLoop = RunLoop.current
        completionBlock?()
        completionBlock = nil
        
        while !isCancelled {
            runLoop.run()
        }
        
        runLoop = nil
    }
    
    public func startWithCompletion(_ completionBlock: @escaping () -> Void) {
        self.completionBlock = completionBlock
        start()
    }
    
    public func addOperationWithBlock(_ block : @escaping () -> Void) {
        precondition(runLoop != nil, "Cannot add operation to thread before it gets started")
        CFRunLoopPerformBlock(runLoop.getCFRunLoop(), CFRunLoopMode.commonModes.rawValue, block)
        CFRunLoopWakeUp(runLoop.getCFRunLoop())
    }
}
