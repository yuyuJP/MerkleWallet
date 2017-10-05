//
//  BITransactionHistoryView.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/07/01.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import UIKit

public protocol BITransactionHistoryViewDelegate {
    func cellDidSelectAt(_ tx: TransactionDetail)
    func showWifButtonTapped()
}


class BITransactionHistoryView: UIView, UITableViewDelegate, UITableViewDataSource, BISettingsTopViewDelegate {
    
    private var sectionTitles = ["Transaction History"]
    
    private var txDetails: [TransactionDetail] = []
    
    private var tableView: UITableView!
    
    public var contentView: BISettingsTopView!
    
    private let contentViewHeight: CGFloat = 96.0
    private var firstOffset: CGFloat = 0.0
    
    public var delegate: BITransactionHistoryViewDelegate? = nil
    
    override public func draw(_ rect: CGRect) {
        
    }
    
    public func reloadTxHistoryView() {
        txDetails = []
    
        for tx in TransactionInfo.loadAll().reversed() {
            let txDetail = TransactionDetail(tx: tx, pubKeyPrefix: BitcoinPrefixes.pubKeyPrefix, scriptHashPrefix: BitcoinPrefixes.scriptHashPrefix)
            //print("From: \(txDetail.fromAddresses) To: \(txDetail.toAddresses) Amount: \(txDetail.amount) TXID: \(tx.txHash)")
            txDetails.append(txDetail)
        }
        
        self.tableView.reloadData()
    }
    
    public func setTransactionHistoryTable() {
        
        for tx in TransactionInfo.loadAll().reversed() {
            let txDetail = TransactionDetail(tx: tx, pubKeyPrefix: BitcoinPrefixes.pubKeyPrefix, scriptHashPrefix: BitcoinPrefixes.scriptHashPrefix)
            //print("From: \(txDetail.fromAddresses) To: \(txDetail.toAddresses) Amount: \(txDetail.amount) TXID: \(tx.txHash)")
            txDetails.append(txDetail)
        }

        
        let contentViewRect = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: contentViewHeight)
        let tableViewRect = CGRect(x: 0.0, y: contentViewHeight, width: self.frame.size.width, height: self.frame.size.height)
        
        tableView = UITableView(frame: tableViewRect)
        tableView.backgroundColor = .clear
        tableView.register(TransactionHistoryDisplayTableViewCell.self, forCellReuseIdentifier: "Cell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        contentView = BISettingsTopView(frame: contentViewRect)
        contentView.delegate = self
        contentView.backgroundColor = UIColor.backgroundWhite()
        
        /*var inset: UIEdgeInsets = tableView.contentInset
        inset.top = contentViewHeight
        tableView.contentInset = inset
        
        var indicatorInset: UIEdgeInsets = tableView.scrollIndicatorInsets
        indicatorInset.top = contentViewHeight
        tableView.scrollIndicatorInsets = indicatorInset
        
        firstOffset = -contentViewHeight*/
        
        self.addSubview(tableView)
        self.addSubview(contentView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return txDetails.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TransactionHistoryDisplayTableViewCell
        
        //cell.backgroundColor = UIColor.backgroundWhite()
        cell.backgroundColor = UIColor.backgroundWhite()
        
        
        let tx = txDetails[indexPath.row]
        
        if tx.isSpentTransaction {
            cell.txActionLabel.text = "Sent"
            cell.txActionLabel.textColor = UIColor.sentRed()
        } else {
            cell.txActionLabel.text = "Received"
            cell.txActionLabel.textColor = UIColor.receivedGreen()
        }
        
        if let timestamp = tx.timestamp {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            cell.timeLabel.text = formatter.string(from: timestamp as Date)
            
        } else {
            cell.timeLabel.text = "--/--"
        }
        
        cell.amountLabel.text = String(Double(tx.amount) / 100000000) + " BTC"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let txDetail = txDetails[indexPath.row]
        txDetail.confirmation = MatchingTransactionHashInfo.comfirmations(txDetail.txId)
        
        delegate?.cellDidSelectAt(txDetail)
    }
    
    //MARK:- BISettingsTopViewDelegate 
    func showPrivateKeyButtonTapped() {
        delegate?.showWifButtonTapped()
    }
    
    /*
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
     let diff = scrollView.contentOffset.y - fset
     if diff <= contentViewHeight && diff >= 0.0 {
     contentView.frame.origin.y = -diff
     } else if diff > contentViewHeight {
     contentView.frame.origin.y = -contentViewHeight
     } else if diff < 0.0 {
     contentView.frame.origin.y = 0.0
     }
     }
     */
    
}
