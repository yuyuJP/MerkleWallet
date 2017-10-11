//
//  CFController.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/11/01.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public protocol CFControllerDelegate {
    func newTransactionReceived()
    func transactionSendRejected(message: String)
    func transactionPassedToNode()
    func blockSyncCompleted()
    func blockSyncProgressChanged(progress: Float)
    func blockSyncStarted()
    func connectionError()
}

public class CFController: CFConnectionDelegate {
    private let hostname: String
    private let port: UInt16
    private let network: [UInt8]
    private let queue: OperationQueue
    
    
    private var connection: CFConnection?
    private var peerVersion: VersionMessage?
    private var headersDownloaded = 0
    
    private var blockHashesDownloaded : [InventoryVector] = []
    private var blockHashesCountDownloaded = 0
    private var syncStartBlockHeight = 0
    
    public var blockSyncCompleted = false
    
    private var pendingTransactions: [Transaction] = []
    
    private var lastBlockHash: InventoryVector = InventoryVector(type: .Error, hash: SHA256Hash())
    
    public var delegate: CFControllerDelegate? = nil
    
    public init(hostname: String, port: UInt16, network: [UInt8]) {
        self.hostname = hostname
        self.port = port
        self.network = network
        self.queue = OperationQueue.main
    }
    
    public func connectionStatus() -> CFConnection.Status {
        if connection == nil {
            return CFConnection.Status.NotConnected
        } else {
            return connection!._status
        }
        
    }
    
    public func start() {
        
        queue.addOperation {
            self.connection = CFConnection(hostname: self.hostname, port: self.port)
            self.connection?.delegate = self
            
            self.connection!.connectWithVersionMessage(self.createVersion())
        }
    }
    
    private func createVersion() -> VersionMessage {
        let senderPeerAddress = PeerAddress(services: PeerServices.None, IP: IPAddress.IPV4(0x00000000), port: 0)
        let receiverAddress = PeerAddress(services: PeerServices.None, IP: IPAddress.IPV4(0x00000000), port: 0)
        return VersionMessage(protocolVersion: 70002, services: PeerServices.None, date: NSDate(), senderAddress: senderPeerAddress, receiverAddress: receiverAddress, nonce: 0x5e9e17ca3e515405, userAgent: "/Swift-Bitcoin:0.0.1/", blockStartHeight: 0, announceRelayedTransactions: false)
        
    }
    
    private var genesisBlockHash: SHA256Hash {
        let bytes: [UInt8] = [
            0x00, 0x00, 0x00, 0x00, 0x00, 0x19, 0xd6, 0x68,
            0x9c, 0x08, 0x5a, 0xe1, 0x65, 0x83, 0x1e, 0x93,
            0x4f, 0xf7, 0x63, 0xae, 0x46, 0xa2, 0xa6, 0xc1,
            0x72, 0xb3, 0xf1, 0xb6, 0x0a, 0x8c, 0xe2, 0x6f]
        return SHA256Hash(bytes)
    }
    
    private var genesisBlockHash_testnet : SHA256Hash {
        let bytes: [UInt8] = [
            0x00, 0x00, 0x00, 0x00, 0x09, 0x33, 0xea, 0x01,
            0xad, 0x0e, 0xe9, 0x84, 0x20, 0x97, 0x79, 0xba,
            0xae, 0xc3, 0xce, 0xd9, 0x0f, 0xa3, 0xf4, 0x08,
            0x71, 0x95, 0x26, 0xf8, 0xd7, 0x7f, 0x49, 0x43]
        return SHA256Hash(bytes)
    }
    
    /*private var firstCreatedBlock: SHA256Hash {
        return SHA256Hash("00000000b873e79784647a6c82962c70d228557d24a747ea4d1b8bbe878e1206".hexStringToNSData())
    }*/
    
    //MARK: CFConnectionDelegate
    public func cfConnection(peerConnection: CFConnection, didConnectWithPeerVersion peerVersion: VersionMessage) {
        //print("Hand Shake Done!! with node version \(peerVersion)")
        self.syncStartBlockHeight = latestBlockHeight
        
        //Send Bloom Filter just after the connection is established
        queue.addOperation {
            
            self.peerVersion = peerVersion
            
            if let filter = BloomFilter.sharedFilter {
                
                let filterLoadMessage = FilterLoadMessage(filter: filter.filterData, numHashFunctions: filter.hash_funcs, tweak: filter.tweak, flags: 1)
                self.connection?.sendMessageWithPayload(filterLoadMessage)
                
                let memPoolMessage = MemPoolMessage()
                self.connection?.sendMessageWithPayload(memPoolMessage)
                
                if latestBlockHeight < Int(self.peerVersion!.blockStartHeight) {
                    
                    let blkHash = SHA256Hash(latestBlockHash.hexStringToNSData())
                    let getBlocksMsg = GetBlocksMessage(protocolVersion: 70002, blockLocatorHashes: [blkHash])
                    
                    self.delegate?.blockSyncStarted()
                    self.connection?.sendMessageWithPayload(getBlocksMsg)
                } else {
                    self.blockSyncCompleted = true
                }
                
            } else {
                assert(false, "No filter looaded")
                return
            }
        }
        
    }
    
    private func sendGetData(inventoryVecs: [InventoryVector]) {
        
        let latestBlockHeight_ = latestBlockHeight
        let firstCreatedBlock_ = firstCreatedBlock
        
        var vecs : [InventoryVector] = []
        for vec in inventoryVecs {
            if vec.type == .Block {
                let blkInfo = BlockInfo.fetch(vec.hash.data.toHexString())
                
                //When block is found or found block is orphan(whick has no connection with a block.)
                if blkInfo != nil && blkInfo?.height != 0 {
                    continue
                }
                
                if vec.hash == firstCreatedBlock_ && latestBlockHeight_ != 0 {
                    if let currentBlock = BlockInfo.fetch(latestBlockHash) {
                        let blockChainInfo = BlockChainInfo.loadItem()!
                        blockChainInfo.update {
                            blockChainInfo.lastBlockHash = currentBlock.previousBlockHash
                            blockChainInfo.lastBlockHeight = currentBlock.height - 1
                            let blkHash = SHA256Hash(currentBlock.previousBlockHash.hexStringToNSData())
                            let getBlocksMsg = GetBlocksMessage(protocolVersion: 70002, blockLocatorHashes: [blkHash])
                            self.connection?.sendMessageWithPayload(getBlocksMsg)
                        }
                    }
                    return
                }
                
                let merkleVec = InventoryVector(type: .FilteredBlock, hash: vec.hash)
                vecs.append(merkleVec)
            } else {
                vecs.append(vec)
            }
        }
        
        if vecs.count > 0 {
            let getDataMessage = GetDataMessage(inventoryVectors: vecs)
            self.connection?.sendMessageWithPayload(getDataMessage)
            
            let lastBlockHash = vecs.last!.hash
            let getBlocksMsg = GetBlocksMessage(protocolVersion: 70002, blockLocatorHashes: [lastBlockHash])
            self.connection?.sendMessageWithPayload(getBlocksMsg)
        }
    }
    
    public func sendTransaction(transaction: Transaction) {
        self.pendingTransactions.append(transaction)
        let inv = InventoryVector(type: .Transaction, hash: transaction.hash)
        let invMessage = InventoryMessage(inventoryVectors: [inv])
        queue.addOperation {
            self.connection?.sendMessageWithPayload(invMessage)
            self.delegate?.transactionPassedToNode()
        }
    }
    
    public func sendGetAddressMessage() {
        let getAddrMsg = GetPeerAddressMessage()
        queue.addOperation {
            self.connection?.sendMessageWithPayload(getAddrMsg)
        }
    }
    
    public func cfConnection(peerConnection: CFConnection, didReceiveMessage message: PeerConnectionMessage) {
        
        switch message {
        
            case let .HeadersMessage(headersMessage):
                queue.addOperation {
                    self.headersDownloaded += headersMessage.headers.count
                    print("\(self.headersDownloaded) blocks received / \(self.peerVersion!.blockStartHeight)")
                
                    if headersMessage.headers.count == 2000 {
                        let percentComplete = Double(self.headersDownloaded) / Double(self.peerVersion!.blockStartHeight) * 100
                        print("Received \(headersMessage.headers.count) block headers - "+"\(Int(percentComplete))% complete")
                        let lastHeaderHash = headersMessage.headers.last!.hash
                        print(lastHeaderHash)
                        let getHeadersMessage = GetHeadersMessage(protocolVersion: 70002, blockLocatorHashes: [lastHeaderHash])
                        self.connection?.sendMessageWithPayload(getHeadersMessage)
                    } else {
                        print("Header sync complete!!!")
                    }
                }
            
            case let .InventoryMessage(inventoryMessage):
                queue.addOperation {
                
                    if inventoryMessage.inventoryVectors.count == 1 && self.lastBlockHash == inventoryMessage.inventoryVectors[0] {
                        return
                    }
                
                    if inventoryMessage.inventoryVectors.count == 1 {
                        if inventoryMessage.inventoryVectors[0].type != .Block {
                            return
                        }
                        self.lastBlockHash = inventoryMessage.inventoryVectors[0]
                    }
                
                    self.blockHashesCountDownloaded += inventoryMessage.inventoryVectors.count
                    print("\(self.blockHashesCountDownloaded + self.syncStartBlockHeight) block hashes received / \(self.peerVersion!.blockStartHeight)")
                
                
                    if inventoryMessage.inventoryVectors.count > 0 {
                        self.sendGetData(inventoryVecs: inventoryMessage.inventoryVectors)
                    
                        if self.blockHashesCountDownloaded + self.syncStartBlockHeight >= Int(self.peerVersion!.blockStartHeight) {
                            self.blockSyncCompleted = true
                            self.delegate?.blockSyncCompleted()
                            
                        } else {
                            if !self.blockSyncCompleted {
                                let sub = Float(self.peerVersion!.blockStartHeight - Int32(self.syncStartBlockHeight))
                                let progress = Float(self.blockHashesCountDownloaded) / sub
                                self.delegate?.blockSyncProgressChanged(progress: progress)
                            }
                        }
                        
                       /* let lastBlockHash = inventoryMessage.inventoryVectors.last!.hash
                        let getBlocksMsg = GetBlocksMessage(protocolVersion: 70002, blockLocatorHashes: [lastBlockHash])
                        self.connection?.sendMessageWithPayload(getBlocksMsg)*/
                    }
                }
            
            case let .MerkleBlockMessage(merkleBlockMessage):
                queue.addOperation {
                    BlockDataStoreManager.add(merkleBlockMsg: merkleBlockMessage)
                }
                /*DispatchQueue.main.async {
                    
                }*/
            
            case let .TransactionMessage(transactionMessage):
                DispatchQueue.main.async {
                    TransactionDataStoreManager.add(tx: transactionMessage)
                    self.delegate?.newTransactionReceived()
                }
            
            case let .GetDataMessage(getDataMessage):
                //Broadcast pending transactions after receiving GetDataMessage from node.
                queue.addOperation {
                    for inv in getDataMessage.inventoryVectors {
                        for i in 0 ..< self.pendingTransactions.count {
                            if inv.hash == self.pendingTransactions[i].hash {
                                self.connection?.sendMessageWithPayload(self.pendingTransactions[i])
                                self.pendingTransactions.remove(at: i)
                            }
                        }
                    }
                }
            
            case let .RejectMessage(rejectMessage):
                queue.addOperation {
                    self.delegate?.transactionSendRejected(message: rejectMessage.reason)
                }

            case let .PingMessage(pingMessage):
                print("Sending pong back...")
                queue.addOperation {
                    let pongMessage = PongMessage(nonce: pingMessage.nonce)
                    self.connection?.sendMessageWithPayload(pongMessage)
                }
            
            default:
                print(message)
                break
        }
    }
    
    public func cfConnectionConnectionError() {
        delegate?.connectionError()
    }
    
    public func disconnect() {
        self.connection?.disconnect()
    }
}
