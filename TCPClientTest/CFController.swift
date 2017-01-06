//
//  CFController.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/11/01.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

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
    
    private var pendingSendTransaction: [Transaction] = []
    
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
        return VersionMessage(protocolVersion: 70002, services: PeerServices.None, date: NSDate(), senderAddress: senderPeerAddress, receiverAddress: receiverAddress, nonce: 0x5e9e17ca3e515405, userAgent: "/Bitcoin-Swift:0.0.1/", blockStartHeight: 0, announceRelayedTransactions: false)
        
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
    
    //MARK: CFConnectionDelegate
    public func cfConnection(peerConnection: CFConnection, didConnectWithPeerVersion peerVersion: VersionMessage) {
        print("Hand Shake Done!! with node version \(peerVersion)")
        
        //Send Bloom Filter just after the connection is established
        queue.addOperation {
            
            self.peerVersion = peerVersion
            
            if let filter = BloomFilter.sharedFilter {
                
                print("Sending filterLoad Message")
                let filterLoadMessage = FilterLoadMessage(filter: filter.filterData, numHashFunctions: filter.hash_funcs, tweak: filter.tweak, flags: 1)
                self.connection?.sendMessageWithPayload(filterLoadMessage)
                
                print("Sending memPool Message")
                let memPoolMessage = MemPoolMessage()
                self.connection?.sendMessageWithPayload(memPoolMessage)
            
                
                /*let blkHash = SHA256Hash("0000000053be966d2beb2aa8f87b2cba790422b3efc096f6e1aa36a69a048335".hexStringToNSData())
                
            
                let inv = InventoryVector(type: .FilteredBlock, hash: blkHash)
                
                let msg = GetDataMessage(inventoryVectors: [inv])
                self.connection?.sendMessageWithPayload(msg)
                 */
                
                /*print("Sending getHeaders Message")
                
                self.peerVersion = peerVersion
                let getHeadersMessage = GetHeadersMessage(protocolVersion: 70002, blockLocatorHashes: [self.genesisBlockHash])
                self.connection?.sendMessageWithPayload(getHeadersMessage)
                */
                /*let blkHash = SHA256Hash("000000000000041b35fe70f155301d729a9256610c35dc5d75557a191b545009".hexStringToNSData())
                let getBlocksMsg = GetBlocksMessage(protocolVersion: 70002, blockLocatorHashes: [blkHash])
                self.connection?.sendMessageWithPayload(getBlocksMsg)
                */
                
            } else {
                assert(false, "No filter looaded")
                return
            }
            
            
            /*let getHeadersMessage = GetHeadersMessage(protocolVersion: 70002, blockLocatorHashes: [self.genesisBlockHash])
            self.connection?.sendMessageWithPayload(getHeadersMessage)
            */
            
            /* //let genInvVec = InventoryVector(type: .FilteredBlock, hash: genesisBlockHash_testnet)
             let blkHash = SHA256Hash("0000000053be966d2beb2aa8f87b2cba790422b3efc096f6e1aa36a69a048335".hexStringToNSData())
             let inv = InventoryVector(type: .FilteredBlock, hash: blkHash)*/
        }
        
        
        /*queue.addOperation {
         self.peerVersion = peerVersion
         let getHeadersMessage = GetHeadersMessage(protocolVersion: 70002, blockLocatorHashes: [self.genesisBlockHash])
         self.connection?.sendMessageWithPayload(getHeadersMessage)
        }*/
        
        
    }
    
    private func sendGetData(inventoryVecs: [InventoryVector]) {
        
        var vecs : [InventoryVector] = []
        for vec in inventoryVecs {
            if vec.type == .Block {
                let merckeVec = InventoryVector(type: .FilteredBlock, hash: vec.hash)
                vecs.append(merckeVec)
            } else {
                vecs.append(vec)
            }
        }
        
        let getDataMessage = GetDataMessage(inventoryVectors: vecs)
        self.connection?.sendMessageWithPayload(getDataMessage)
    }
    
    public func sendTransaction(transaction: Transaction) {
        let inv = InventoryVector(type: .Transaction, hash: transaction.hash)
        print("transaction hash: \(transaction.hash)")
        let invMessage = InventoryMessage(inventoryVectors: [inv])
        self.connection?.sendMessageWithPayload(invMessage)
        self.pendingSendTransaction.append(transaction)
    }
    
    public func cfConnection(peerConnection: CFConnection, didReceiveMessage message: PeerConnectionMessage) {
        switch message {
        
        case let .HeadersMessage(headersMessage):
            queue.addOperation {
                self.headersDownloaded += headersMessage.headers.count
                print("\(self.headersDownloaded) blocks received / \(self.peerVersion!.blockStartHeight)")
                
                if headersMessage.headers.count == 2000 {
                    let percentComplete = Double(self.headersDownloaded) /
                        Double(self.peerVersion!.blockStartHeight) * 100
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
                self.blockHashesCountDownloaded += inventoryMessage.inventoryVectors.count
                print("\(self.blockHashesCountDownloaded) block hashes received / \(self.peerVersion!.blockStartHeight)")
                //if inventoryMessage.inventoryVectors.count == 500 {
                    let lastBlockHash = inventoryMessage.inventoryVectors.last!.hash
                    print(lastBlockHash)
                //let getBlocksMsg = GetBlocksMessage(protocolVersion: 70002, blockLocatorHashes: [lastBlockHash])
                    //self.connection?.sendMessageWithPayload(getBlocksMsg)
                //}
            }
            
            //self.sendGetData(inventoryVecs: inventoryMessage.inventoryVectors)
            
            
        case let .MerkleBlockMessage(merkleBlockMessage):
            print("Received merkle block")
            //print(merkleBlockMessage)
            
        case let .TransactionMessage(transactionMessage):
            print(transactionMessage)
            /*for output in transactionMessage.outputs {
                let script = output.script
                print(script)
                //let hash160 = OutputScript(script: script).hash160
                //print(hash160?.bitcoinData)
            }*/
            
        case let .GetDataMessage(getDataMessage):
            print("received getDataMessage \(getDataMessage)")
            for inv in getDataMessage.inventoryVectors {
                for tx in pendingSendTransaction {
                    if inv.hash == tx.hash {
                        self.connection?.sendMessageWithPayload(tx)
                    }
                }
            }
            
        default:
            print(message)
            break
        }
    }
}
