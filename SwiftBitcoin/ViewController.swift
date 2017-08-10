//
//  ViewController.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/10/15.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, BITransactionHistoryViewDelegate, BISendTopViewDelegate, UIScrollViewDelegate, CFControllerDelegate {

    private var con : CFController!
    private var key : BitcoinTestnet!
    
    
    var scrollView: BIScrollView!
    var topStatusView: BITopStatusView!
    var txHistoryView: BITransactionHistoryView!
    
    var displayTxDetail: TransactionDetail? = nil
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userKey = UserKeyInfo.loadAll().first {
            
            key = BitcoinTestnet(privateKeyHex: userKey.privateKey, publicKeyHex: userKey.uncompressedPublicKey)
            //key = BitcoinTestnet(privateKeyHex: "33260783e40b16731673622ac8a5b045fc3ea4af70f727f3f9e92bdd3a1ddc42")
            print(key.publicAddress)
            
        } else {
            print("No user info. Generating a new key.")
            key = BitcoinTestnet(privateKeyHex: "33260783e40b16731673622ac8a5b045fc3ea4af70f727f3f9e92bdd3a1ddc42")
            //key = BitcoinTestnet()
            
            let newUserKeyInfo = UserKeyInfo.create(key: key)
            newUserKeyInfo.save()
        }
        
        if let blkChainInfo = BlockChainInfo.loadItem() {
            print("blk chain info: \(blkChainInfo)")
        } else {
            let blkInfo = BlockInfo.genesisCreate(startingBlockHash, with: startingBlockHeight)
            blkInfo.save()
        }
        
        bloomFilterSet(publicKeyHex: key.publicKeyHexString, publicKeyHashHex: key.publicKeyHashHex)
        
        
        let blks = BlockInfo.loadAll()
        for blk in blks {
            print("hash: \(blk.blockHash) height: \(blk.height)")
        }
        
        //establishConnection()

        //txGenerateFromLocalDBTest()
 
        
        self.view.backgroundColor = UIColor.backgroundWhite()
        pageControl.currentPageIndicatorTintColor = UIColor.themeColor()
        
        setupContentView()
    }
    
    func bloomFilterSet(publicKeyHex: String, publicKeyHashHex: String) {
        let hash_funcs : UInt32 = 10
        let tweak : UInt32 = 0
        BloomFilter.sharedFilter = BloomFilter(length: 512, hash_funcs: hash_funcs, tweak: tweak)
        
        let bloomFilter = BloomFilter.sharedFilter!
        bloomFilter.add(data: publicKeyHex.hexStringToNSData())
        bloomFilter.add(data: publicKeyHashHex.hexStringToNSData())
    }
    
    func establishConnection() {
        con = CFController(hostname: "testnet-seed.bitcoin.schildbach.de", port: 18333, network: NetworkMagicBytes.magicBytes())
        
        //con = CFController(hostname: "seed.tbtc.petertodd.org", port: 18333, network: NetworkMagicBytes.magicBytes())
        //con = CFController(hostname: "192.168.0.10", port: 10000, network: NetworkMagicBytes.magicBytes())
        con.delegate = self
        con.start()
    }
    
    func txGenerateFromLocalDBTest() {
        
        let sendAddress = "2N54g5fR3wvVgynFTxnCuwxxrKsMnTMjmJ6"
        //mfZUjWuPJ4j7PvnNKSPvVuq5NWNUoPx3Pq
        //2N54g5fR3wvVgynFTxnCuwxxrKsMnTMjmJ6
        guard let type = sendAddress.determinOutputScriptTypeWithAddress() else {
            print("Could not determin address type")
            return
        }
        
        var prefix = BitcoinPrefixes.pubKeyPrefix
        
        if type == .P2SH {
            prefix = BitcoinPrefixes.scriptHashPrefix
        }
        
        if let addressHash160 = sendAddress.publicAddressToPubKeyHash(prefix) {
            
            let txConstructor = TransactionDBConstructor(privateKeyPrefix: 0xef, publicKeyPrefix: BitcoinPrefixes.pubKeyPrefix, sendAmount: 3000000, to: RIPEMD160HASH(addressHash160.hexStringToNSData().reversedData), type: type, fee: 90000)
            print(txConstructor.transaction?.bitcoinData.toHexString() ?? "no val")
        }
        
    }
    
    func setupContentView() {
        
        scrollView = BIScrollView(frame: self.view.frame)
        scrollView.isPagingEnabled = true
        scrollView.delaysContentTouches = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        self.view.addSubview(scrollView)
        
        let size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        let contentRect = CGRect(x: 0, y: 0, width: size.width * 3, height: size.height)
        let contentView = UIView(frame: contentRect)
        
        txHistoryView = BITransactionHistoryView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        txHistoryView.delegate = self
        txHistoryView.backgroundColor = UIColor.backgroundWhite()
        txHistoryView.setTransactionHistoryTable()
        contentView.addSubview(txHistoryView)
        
        
        let sendTopView = BISendTopView(frame: CGRect(x: size.width, y: 0, width: size.width, height: size.height))
        sendTopView.delegate = self
        sendTopView.backgroundColor = .clear
        contentView.addSubview(sendTopView)
        
        let receiveTopView = BIReceiveTopView(frame: CGRect(x: size.width * 2, y: 0, width: size.width, height: size.height))
        receiveTopView.backgroundColor = UIColor.backgroundWhite()
        
        contentView.addSubview(receiveTopView)
        
        let statusViewHeight = size.height / 4
        
        topStatusView = BITopStatusView(frame: CGRect(x: size.width, y: 0, width: size.width, height: statusViewHeight))
        topStatusView.backgroundColor = .white
        
        let balance = TransactionDataStoreManager.calculateBalance()
        let balanceInBTC: Double = Double(balance) / 100000000
        topStatusView.setupStatusLabel(text: String(balanceInBTC) + "tBTC")
        
        contentView.addSubview(topStatusView)
        
        sendTopView.setupSendLabel(statusViewHeight)
        receiveTopView.setupReceiveLabel(statusViewHeight)
        
        receiveTopView.setupAddressQRCode(key.publicAddress)
        receiveTopView.setupAddresLabel(key.publicAddress)
 
        scrollView.addSubview(contentView)
        scrollView.contentSize = contentView.frame.size
        scrollView.contentOffset = CGPoint(x: size.width, y: 0)
        
        pageControl.currentPage = 1
        
        self.view.bringSubview(toFront: pageControl)
        
    }
    
    
    //MARK:- UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let diff = scrollView.frame.width - scrollView.contentOffset.x
        if diff <= 0 {
            topStatusView.frame.origin.x = scrollView.contentOffset.x
        } else {
            let halfWidth = scrollView.frame.width / 2.0
            if diff < halfWidth {
                let alpha = (halfWidth - diff) / halfWidth
                topStatusView.alpha = alpha
                pageControl.alpha = alpha
                
            } else {
                topStatusView.alpha = 0.0
                pageControl.alpha = 0.0
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int((scrollView.contentOffset.x + scrollView.frame.size.width / 2) / scrollView.frame.size.width)
    }


    //MARK:- CFControllerDelegate
    func newTransactionReceived() {
        let balance = TransactionDataStoreManager.calculateBalance()
        let balanceInBTC: Double = Double(balance) / 100000000
        topStatusView.changeStatusLabel(text: String(balanceInBTC) + "tBTC")
        
    }
    
    //MARK:- BITransactionHistoryViewDelegate
    func cellDidSelectAt(_ tx: TransactionDetail) {
        self.displayTxDetail = tx
        self.performSegue(withIdentifier: "txDetail", sender: nil)
        
        self.displayTxDetail = nil
    }
    
    //MARK:- BISendTopViewDelegate
    func qrScanButtonTapped() {
        self.performSegue(withIdentifier: "scanQR", sender: nil)
    }
    
    func enterAddressButtonTapped() {
        txGenerateFromLocalDBTest()
        //self.performSegue(withIdentifier: "pay", sender: nil)
        /*if let addressHash160 = "mfZUjWuPJ4j7PvnNKSPvVuq5NWNUoPx3Pq".publicAddressToPubKeyHash(key.publicKeyPrefix) {
            let txConstructor = TransactionDBConstructor(privateKeyPrefix: 0xef, publicKeyPrefix: 0x6f, sendAmount: 1000000, to: RIPEMD160HASH(addressHash160.hexStringToNSData().reversedData), fee: 90000)
            //print(txConstructor.transaction?.bitcoinData.toHexString() ?? "no val")
            print(txConstructor.transaction?.bitcoinData.toHexString())
            //con.sendTransaction(transaction: txConstructor.transaction!)
        }*/

    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "txDetail" {
            let txDetailViewController = segue.destination as! BITransactionDetailViewController
            txDetailViewController.txDetail = displayTxDetail
            
            
        }
    }


    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

