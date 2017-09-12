//
//  ViewController.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/10/15.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, BITransactionHistoryViewDelegate, BISendTopViewDelegate, BIQRCodeReadViewControllerDelegate, BIPayViewControllerDelegate, UIScrollViewDelegate, CFControllerDelegate, BIReceiveTopViewDelegate {

    private var con : CFController!
    private var key : BitcoinTestnet!
    
    
    var scrollView: BIScrollView!
    var topStatusView: BITopStatusView!
    var txHistoryView: BITransactionHistoryView!
    
    var displayTxDetail: TransactionDetail? = nil
    
    var txSentTimer: Timer? = nil
    var activityIndicatorView: UIActivityIndicatorView!
    
    var pendingTx: Transaction? = nil
    
    var transactionAdded = false
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userKey = UserKeyInfo.loadAll().first {
        
            key = BitcoinTestnet(privateKeyHex: userKey.privateKey, publicKeyHex: userKey.uncompressedPublicKey)
            
        } else {
            key = BitcoinTestnet()
            
            let newUserKeyInfo = UserKeyInfo.create(key: key)
            newUserKeyInfo.save()
        }
        
        if let _ = BlockChainInfo.loadItem() {
            //print("blk chain info: \(blkChainInfo)")
        } else {
            let blkInfo = BlockInfo.createGenesis(startingBlockHash, with: startingBlockHeight)
            blkInfo.save()
        }
        
        //print("latest block height: \(latestBlockHeight), hash: \(latestBlockHash)")

        
        bloomFilterSet(publicKeyHex: key.publicKeyHexString, publicKeyHashHex: key.publicKeyHashHex)
        
        establishConnection()

        self.view.backgroundColor = UIColor.backgroundWhite()
        pageControl.currentPageIndicatorTintColor = UIColor.themeColor()
        
        setupContentView()
        setupIndicatorView()
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
        
        let nodeAddress = BitcoinTestnetNodes.randomNode

        if con != nil {
            con = nil
        }
        
        con = CFController(hostname: nodeAddress, port: 18333, network: NetworkMagicBytes.magicBytes())
        con.delegate = self
        con.start()
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
        receiveTopView.delegate = self
        receiveTopView.backgroundColor = UIColor.backgroundWhite()
        
        contentView.addSubview(receiveTopView)
        
        let statusViewHeight = size.height / 4
        
        topStatusView = BITopStatusView(frame: CGRect(x: size.width, y: 0, width: size.width, height: statusViewHeight))
        topStatusView.backgroundColor = .white
        
        let balance = TransactionDataStoreManager.calculateBalance()
        let balanceInBTC: Double = Double(balance) / 100000000
        topStatusView.setupStatusLabel(text: String(balanceInBTC) + "tBTC")
        topStatusView.setupProgressBar()
        
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
    
    func setupIndicatorView() {
        
        activityIndicatorView = UIActivityIndicatorView(frame: self.view.frame)
        activityIndicatorView.backgroundColor = .black
        activityIndicatorView.alpha = 0.3
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.activityIndicatorViewStyle = .whiteLarge
        
        self.view.addSubview(activityIndicatorView)
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
    
    func updateBlanceLabel() {
        let balance = TransactionDataStoreManager.calculateBalance()
        let balanceInBTC: Double = Double(balance) / 100000000
        self.topStatusView.changeStatusLabel(text: String(balanceInBTC) + "tBTC")
    }
    
    func displayAlert(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (result : UIAlertAction) -> Void in
            //Called, when AlertController is dismissed.
        }))
        self.present(alert, animated: true, completion: nil)
    }


    //MARK:- CFControllerDelegate
    func newTransactionReceived() {
        //self.txHistoryView.reloadTxHistoryView()
        self.transactionAdded = true
    }
    
    func transactionSendRejected(message: String) {
        print("tx rejected REASON: \(message)")
        
        pendingTx = nil
        
        txSentTimer?.invalidate()
        txSentTimer = nil
        activityIndicatorView.stopAnimating()
        
        displayAlert(title: "Transaction Rejected", message: message)
    }
    
    func transactionPassedToNode() {
        let timeout: TimeInterval = 5
        txSentTimer = Timer.scheduledTimer(timeInterval: timeout, target: self, selector: #selector(ViewController.txSuccessfullySent(_:)), userInfo: nil, repeats: false)
    }
    
    func blockSyncStarted() {
        DispatchQueue.main.async {
            self.topStatusView.changeStatusLabel(text: "Syncing...")
        }
    }
    
    func blockSyncProgressChanged(progress: Float) {
        DispatchQueue.main.async {
            self.topStatusView.changeProgressBar(CGFloat(progress))
        }
    }
    
    func blockSyncCompleted() {
        DispatchQueue.main.async {
            self.topStatusView.disposeProgressBar()
            self.updateBlanceLabel()
            if self.transactionAdded {
                self.txHistoryView.reloadTxHistoryView()
                self.transactionAdded = false
            }
        }
        
    }
    
    func connectionError() {
        self.con = nil
        establishConnection()
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
        self.performSegue(withIdentifier: "pay", sender: nil)
    }
    
    //MARK:- BIPayViewControllerDelegate
    func paymentCanceled() {
        //Do nothing here.
    }
    
    func broadcastTransaction(tx: Transaction) {
        //broadcast tx
        //print(tx.bitcoinData.toHexString())
        sendTransactionToNode(tx: tx)
    }
    
    //MARK:- BIQRCodeReadViewControllerDelegate
    func propagateTransaction(tx: Transaction) {
        //broadcast tx
        sendTransactionToNode(tx: tx)
    }
    
    //MARK:- BIReceieveTopViewDelegate
    func addressLabelTapped() {
        showActionSheetWithCopyMessage(copyString: key.publicAddress)
    }
    
    func showActionSheetWithCopyMessage(copyString: String) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let copyAction = UIAlertAction(title: "Copy address to clipboard", style: .default, handler: {
            (result : UIAlertAction) -> Void in
            let board = UIPasteboard.general
            board.setValue(copyString, forPasteboardType: "public.text")
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (result : UIAlertAction) -> Void in
            
        })
        
        alert.addAction(copyAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }

    
    //
    
    func sendTransactionToNode(tx: Transaction) {
        activityIndicatorView.startAnimating()
        pendingTx = tx
        
        self.con.sendTransaction(transaction: tx)
    }

    func txSuccessfullySent(_ timer: Timer) {
        print("tx successfully sent!!")
        
        if let tx = pendingTx {
            TransactionDataStoreManager.add(tx: tx)
        } else {
            assert(false, "Pending tx is nil.")
        }
        
        txSentTimer?.invalidate()
        txSentTimer = nil
        activityIndicatorView.stopAnimating()
        
        DispatchQueue.main.async {
            self.updateBlanceLabel()
            self.txHistoryView.reloadTxHistoryView()
        }
    }
    
    @IBAction func pageControlTapped(_ sender: Any) {
        let page = self.pageControl.currentPage
        
        var bounds = self.scrollView.bounds
        bounds.origin.x = bounds.width * CGFloat(page)
        bounds.origin.y = 0
        
        self.scrollView.scrollRectToVisible(bounds, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "txDetail" {
            let txDetailViewController = segue.destination as! BITransactionDetailViewController
            txDetailViewController.txDetail = displayTxDetail
            
        } else if segue.identifier == "pay" {
            let payViewController = segue.destination as! BIPayViewController
            payViewController.delegate = self
            
        } else if segue.identifier == "scanQR" {
            let qrCodeReadViewController = segue.destination as! BIQRCodeReadViewController
            qrCodeReadViewController.delegate = self
        }
     }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

