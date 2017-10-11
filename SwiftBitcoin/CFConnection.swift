//
//  CFConnection.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/10/16.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public protocol CFConnectionDelegate {
    func cfConnection(peerConnection: CFConnection, didConnectWithPeerVersion peerVersion: VersionMessage)
    
    //func CFConnection(peerConnection: CFConnection, didDisconnectWithError error: NSError?)
    
    func cfConnection(peerConnection: CFConnection, didReceiveMessage message: PeerConnectionMessage)
    
    func cfConnectionConnectionError()
}

public enum PeerConnectionMessage {
    case GetHeadersMessage(GetHeadersMessage)
    case HeadersMessage(HeadersMessage)
    case InventoryMessage(InventoryMessage)
    case MerkleBlockMessage(MerkleBlockMessage)
    case TransactionMessage(Transaction)
    case GetDataMessage(GetDataMessage)
    case RejectMessage(RejectMessage)
    case AddressMessage(PeerAddressMessage)
    case PingMessage(PingMessage)
    
}

public class CFConnection: NSObject, StreamDelegate, MessageParserDelegate {
    
    public enum Status { case NotConnected, Connecting, Connected, Disconnecting }
    
    public var status: Status { return _status }
    public var _status: Status = .NotConnected

    var host : String?
    var port : UInt16?

    var inputStream : InputStream!
    var outputStream: OutputStream!
    
    public var delegate: CFConnectionDelegate?
    private var delegateQueue: OperationQueue

    private let messageParser = MessageParser()
    
    private let networkThread = CFThread()

    private var connectionTimeoutTimer: Timer? = nil
    
    private var messageSendQueue : [Message] = []
    
    private var pendingSendBytes : [UInt8] = []
    private var readBuffer = [UInt8](repeating: 0, count: 1024)
    
    private var peerVersion: VersionMessage? = nil
    
    private var receivedVersionAck = false
    
    public init(hostname: String, port: UInt16, delegateQueue: OperationQueue = OperationQueue.main) {
        self.host = hostname
        self.port = port
        self.delegateQueue = delegateQueue
        super.init()
        messageParser.delegate = self
    }

    public func connectWithVersionMessage(_ versionMessage: VersionMessage, timeout: TimeInterval = 10) {
        
        setStatus(.Connecting)
        
        connectionTimeoutTimer = Timer.scheduledTimer(timeInterval: timeout, target: self, selector: #selector(CFConnection.connectionTimerDidTimeout(_:)), userInfo: nil, repeats: false)
        
        networkThread.startWithCompletion {
            
            self.networkThread.addOperationWithBlock {
    
                if let (inputStream, outputStream) = self.streamsToPeerWithHostname(hostname: self.host!, port: self.port!) {
                    self.inputStream = inputStream
                    self.outputStream = outputStream
                    self.inputStream.delegate = self
                    self.outputStream.delegate = self
                    
                    self.inputStream.schedule(in: RunLoop.current, forMode: .defaultRunLoopMode)
                    self.outputStream.schedule(in: RunLoop.current, forMode: .defaultRunLoopMode)
                    
                    self.inputStream.open()
                    self.outputStream.open()
                    
                    self.sendMessageWithPayload(versionMessage)
                }
            }
        }
        
    }
    
    private func receive() {
        if let inputStream = inputStream {
            receiveWithStream(inputStream)
        }
    }
    
    private func receiveWithStream(_ inputStream: InputStream) {
        if !inputStream.hasBytesAvailable {
            return
        }
        
        let bytesRead = inputStream.read(&readBuffer, maxLength: readBuffer.count)
        if bytesRead > 0 {
            //printUInt8ArrayToHex(data: [UInt8](readBuffer[0 ..< bytesRead]))
            messageParser.parseBytes([UInt8](readBuffer[0 ..< bytesRead]))
            if inputStream.hasBytesAvailable {
                networkThread.addOperationWithBlock {
                    self.receive()
                }
            }
        }
    }
    
    private func send() {
        //precondition(Thread.current == networkThread)
        if let outputStream = outputStream {
            sendWithStream(outputStream)
        }
    }
    
    private func sendWithStream(_ outputStream: OutputStream) {
        if !outputStream.hasSpaceAvailable {
            return
        }
    
        if messageSendQueue.count > 0 && pendingSendBytes.count == 0 {
            let message = messageSendQueue.remove(at: 0)
            pendingSendBytes += message.bitcoinData.toBytes()
        }
        
        if pendingSendBytes.count > 0 {
            let bytesWritten = outputStream.write(pendingSendBytes, maxLength: pendingSendBytes.count)
            if bytesWritten > 0 {
                let range = pendingSendBytes.startIndex ..< bytesWritten
                pendingSendBytes.removeSubrange(range)
            }
            
            if messageSendQueue.count > 0 || pendingSendBytes.count > 0 {
                networkThread.addOperationWithBlock {
                    self.send()
                }
            }
        }
    }

    public func streamsToPeerWithHostname(hostname: String, port: UInt16) -> (inputStream: InputStream, outputStream: OutputStream)? {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        CFStreamCreatePairWithSocketToHost(nil, hostname as NSString, UInt32(port), &readStream, &writeStream)
        if readStream == nil || writeStream == nil {
            print("Connection failed")
            return nil
        }
    
        return (readStream!.takeUnretainedValue(), writeStream!.takeUnretainedValue())
    }
    
    public func sendMessageWithPayload(_ payload: MessagePayload) {
        let message = Message(network: NetworkMagicBytes.magicBytes(), payload: payload)
        networkThread.addOperationWithBlock {
            self.messageSendQueue.append(message)
            self.send()
        }
    }
    
    
    // MARK: - StreamDelegate
    
    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.openCompleted:
            break
        case Stream.Event.hasBytesAvailable:
            //print("Stream Event hasBytesAvailable")
            self.receive()
        case Stream.Event.hasSpaceAvailable:
            //print("Stream Event hasSpaceAvailable")
            self.send()
        case Stream.Event.errorOccurred:
            print("Error occurred!!!")
            delegate?.cfConnectionConnectionError()
        case Stream.Event.endEncountered:
            print("End endEncountered")
            delegate?.cfConnectionConnectionError()
        default:
            assert(false, "what is happening??")
        }
        
    }
    
    //MARK: - MessageParseDelegate
    public func didParseMessage(_ message: Message) {
        //print(message)
        let payloadStream = InputStream(data: message.payload as Data)
        payloadStream.open()
        switch message.header.command {
        case .Version:
            if peerVersion != nil {
                print("Received extraneous VersionMessage.")
                break
            }
            let versionMessage = VersionMessage.fromBitcoinStream(payloadStream)
            if versionMessage == nil {
                print("Received VersionMessage parse error")
                break
            }
            if !isPeerVersionSupported(versionMessage!) {
                print("Peer Version not supported by this client")
                break
            }
            peerVersion = versionMessage!
            sendVersionAck()
            if receivedVersionAck {
                didConnect()
            }
        case .VersionAck:
            if status != .Connecting {
                print("Ingnoring VersionAck Message bacause it is not in .Connecting state")
                break
            }
            receivedVersionAck = true
            if peerVersion != nil {
                didConnect()
            }
            
        case .Pong:
            print(message)
            
        case .Ping:
            if let pingMsg = PingMessage.fromBitcoinStream(payloadStream) {
                self.delegateQueue.addOperation {
                    let message = PeerConnectionMessage.PingMessage(pingMsg)
                    self.delegate?.cfConnection(peerConnection: self, didReceiveMessage: message)
                }
            }
            
        case .Address:
            if let addressMsg = PeerAddressMessage.fromBitcoinStream(payloadStream) {
                self.delegateQueue.addOperation {
                    let message = PeerConnectionMessage.AddressMessage(addressMsg)
                    self.delegate?.cfConnection(peerConnection: self, didReceiveMessage: message)
                }
            }
            
        case .GetHeaders:
            if let getHeadersMessage = GetHeadersMessage.fromBitcoinStream(payloadStream) {
                self.delegateQueue.addOperation {
                    let message = PeerConnectionMessage.GetHeadersMessage(getHeadersMessage)
                    self.delegate?.cfConnection(peerConnection: self, didReceiveMessage: message)
                }
            }
        case .Headers:
            if let headersMessage = HeadersMessage.fromBitcoinStream(payloadStream) {
                self.delegateQueue.addOperation {
                    let message = PeerConnectionMessage.HeadersMessage(headersMessage)
                    self.delegate?.cfConnection(peerConnection: self, didReceiveMessage: message)
                }
            }
        case .FilterLoad:
            print(message)
            
        case . MemPool:
            print(message)
            
        case .Transaction:
            if let transactionMessage = Transaction.fromBitcoinStream(payloadStream) {
                self.delegateQueue.addOperation {
                    let message = PeerConnectionMessage.TransactionMessage(transactionMessage)
                    self.delegate?.cfConnection(peerConnection: self, didReceiveMessage: message)
                }
            }
            
        case .GetBlocks:
            print(message)
            
        case .Inventory:
            if let inventoryMessage = InventoryMessage.fromBitcoinStream(payloadStream) {
                self.delegateQueue.addOperation {
                    let message = PeerConnectionMessage.InventoryMessage(inventoryMessage)
                    self.delegate?.cfConnection(peerConnection: self, didReceiveMessage: message)
                }
            }
        case .GetData:
            if let getDataMessage = GetDataMessage.fromBitcoinStream(payloadStream) {
                self.delegateQueue.addOperation {
                    let message = PeerConnectionMessage.GetDataMessage(getDataMessage)
                    self.delegate?.cfConnection(peerConnection: self, didReceiveMessage: message)
                }
            }
            
        case .MerkleBlock:
            if let merkleBlockMessage = MerkleBlockMessage.fromBitcoinStream(payloadStream) {
                self.delegateQueue.addOperation {
                    let message = PeerConnectionMessage.MerkleBlockMessage(merkleBlockMessage)
                    self.delegate?.cfConnection(peerConnection: self, didReceiveMessage: message)
                }
            }
        case .Reject:
            if let rejectMessage = RejectMessage.fromBitcoinStream(payloadStream) {
                self.delegateQueue.addOperation {
                    let message = PeerConnectionMessage.RejectMessage(rejectMessage)
                    self.delegate?.cfConnection(peerConnection: self, didReceiveMessage: message)
                }
            }
        case .GetAddress:
            print(message)
        }
    }
    
    private func didConnect() {
        print("Connected to peer \(host!): \(port!)")
        connectionTimeoutTimer?.invalidate()
        connectionTimeoutTimer = nil
        setStatus(.Connected)
        let peerVersion = self.peerVersion!
        self.delegateQueue.addOperation {
            self.delegate?.cfConnection(peerConnection: self, didConnectWithPeerVersion: peerVersion)
        }
    }
    
    private func sendVersionAck() {
        sendMessageWithPayload(VersionAckMessage())
    }
    
    private func isPeerVersionSupported(_ versionMessage: VersionMessage) -> Bool {
        
        //Make this a real check
        return true
    }
    
    private func setStatus(_ newStatus: Status) {
        _status = newStatus
    }

    
    @objc func connectionTimerDidTimeout(_ timer: Timer) {
        connectionTimeoutTimer?.invalidate()
        connectionTimeoutTimer = nil
        delegate?.cfConnectionConnectionError()
        print("Error : connection did time out")
    }
    
    public func disconnect() {
        self.delegate = nil
        self.inputStream.close()
        self.outputStream.close()
    }

}
