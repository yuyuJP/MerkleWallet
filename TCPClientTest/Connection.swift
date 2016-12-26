//
//  Connection.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/10/15.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

class Connection : NSObject, StreamDelegate{
    var host : String?
    var port : Int?
    
    var inputStream : InputStream?
    var outputStream: OutputStream?
    
    var sent = false
    
    func connect(_ host: String, port: Int) {
        self.host = host
        self.port = port
        
        Stream.getStreamsToHost(withName: host, port: port, inputStream: &inputStream, outputStream: &outputStream)
        
        if inputStream != nil && outputStream != nil {
            
            inputStream!.delegate = self
            outputStream!.delegate = self
            
            inputStream!.schedule(in: .main, forMode: .defaultRunLoopMode)
            outputStream!.schedule(in: .main, forMode: .defaultRunLoopMode)
            
            print("Start open()")
            
            inputStream!.open()
            outputStream!.open()
            //send()
        }
    }
    
    func send() {
        if let outputStream = outputStream {
            let message = Message(command: "version")
            print("writing...")
            outputStream.write(message.bytes.reversed(), maxLength: message.bytes.count)
        }
    }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.openCompleted:
            break
        case Stream.Event.hasBytesAvailable:
            print("Stream Event hasBytesAvailable")
        case Stream.Event.hasSpaceAvailable:
            print("Stream Event hasSpaceAvailable")
            //print()
            
        case Stream.Event.errorOccurred:
            print("Error occurred!!!")
        case Stream.Event.endEncountered:
            print("End encountered?? what??")
        default:
            assert(false, "what is happening??")
        }
        
    }
    
    
}
