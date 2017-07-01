//
//  BITransactionHistoryView.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/07/01.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import UIKit

//Temporary struct
public struct TMP_TransactionDetail {
    
    public let isSpentTransaction: Bool
    public let fromAddresses: [String]
    public let toAddresses: [String]
    public let amount: Int64
    public let fee: Int64
    public let txId: String
    
    public init() {
        self.isSpentTransaction = false
        self.fromAddresses = ["from-address1", "from-address2"]
        self.toAddresses = ["to-address1", "to-address2"]
        self.amount = 100000000
        self.fee = 9000
        self.txId = "transactionID"
    }
}


public protocol BITransactionHistoryViewDelegate {
    func cellDidSelectAt(_ indexPath: IndexPath)
}


class BITransactionHistoryView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    private var sectionTitles = ["Transaction History"]
    
    private var txDetails: [TMP_TransactionDetail] = []
    
    private var tableView: UITableView!
    
    public var contentView: BISettingsTopView!
    
    private let contentViewHeight: CGFloat = 99.0
    private var firstOffset: CGFloat = 0.0
    
    public var delegate: BITransactionHistoryViewDelegate? = nil
    
    override public func draw(_ rect: CGRect) {
        
    }
    
    public func setTransactionHistoryTable() {
        let txDetail = TMP_TransactionDetail()
        txDetails.append(txDetail)
        txDetails.append(txDetail)
        
        
        /*
         for _ in 0 ..< 20 {
            txDetails.append(txDetail)
        }
        */
        
        
        let contentViewRect = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: contentViewHeight)
        let tableViewRect = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
        
        tableView = UITableView(frame: tableViewRect)
        tableView.backgroundColor = .clear
        tableView.register(TransactionHistoryDisplayTableViewCell.self, forCellReuseIdentifier: "Cell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        contentView = BISettingsTopView(frame: contentViewRect)
        contentView.backgroundColor = UIColor.backgroundWhite()
        //contentView.backgroundColor = UIColor.themeColor()
        //contentView.alpha = 0.9
        
        var inset: UIEdgeInsets = tableView.contentInset
        inset.top = contentViewHeight
        tableView.contentInset = inset
        
        var indicatorInset: UIEdgeInsets = tableView.scrollIndicatorInsets
        indicatorInset.top = contentViewHeight
        tableView.scrollIndicatorInsets = indicatorInset
        
        firstOffset = -contentViewHeight
        
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
        
        cell.txActionLabel.text = "Sent"
        cell.txActionLabel.textColor = UIColor.sentRed()
        cell.timeLabel.text = "5/20"
        cell.amountLabel.text = "-1.5tBTC"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.cellDidSelectAt(indexPath)
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
