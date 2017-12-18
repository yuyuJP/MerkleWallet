//
//  BITransactionDetailViewController.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/07/01.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import UIKit

class BITransactionDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var tableTitle = ["", NSLocalizedString("TO", comment: ""), NSLocalizedString("FROM", comment: ""), ""]
    private let generalContents = [NSLocalizedString("ID", comment: ""),
                                   NSLocalizedString("Date", comment: ""),
                                   NSLocalizedString("Fee", comment: ""),
                                   NSLocalizedString("Confirmations", comment: "")]
    private var toContents: [String] = []
    private var fromContents: [String] = []
    private var isSpentTransaction = true
    private var txIdStr = ""
    private var dateStr = "--/--"
    private var feeStr = ""
    private var confStr = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    public var txDetail: TransactionDetail? = nil


    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let txDetail = txDetail {
            toContents = txDetail.toAddresses
            fromContents = txDetail.fromAddresses
            isSpentTransaction = txDetail.isSpentTransaction
            txIdStr = txDetail.txId
            if txDetail.fee == -1 {
                feeStr = "--"
            } else {
                feeStr = String(Double(txDetail.fee) / 100000000)
            }
            
            
            if let timestamp = txDetail.timestamp {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
                dateStr = formatter.string(from: timestamp as Date)
            }
            
            confStr = String(txDetail.confirmation)
            
        } else {
            print("Tx detail is nil. Make sure you passed a proper value.")
        }
        
        tableView.register(TransactionDetailTableViewCell.self, forCellReuseIdentifier: "Cell")
        //tableView.backgroundColor = UIColor.backgroundWhite()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TransactionDetailTableViewCell
        
        switch indexPath.section {
        case 0:
            let action = isSpentTransaction ? NSLocalizedString("Sent", comment: "") : NSLocalizedString("Received", comment: "")
            let textColor = isSpentTransaction ? UIColor.sentRed() : UIColor.receivedGreen()
            cell.selectionStyle = .none
            cell.titleLabel.text = action
            cell.titleLabel.textColor = textColor
            cell.infoLabel.text = ""
            cell.textLabel?.text = ""
            
        case 1:
            cell.titleLabel.text = ""
            cell.infoLabel.text = ""
            cell.textLabel?.text = toContents[indexPath.row]
            cell.textLabel?.textColor = .gray
            
        case 2:
            cell.titleLabel.text = ""
            cell.infoLabel.text = ""
            cell.textLabel?.text = fromContents[indexPath.row]
            cell.textLabel?.textColor = .gray
            
        case 3:
            cell.titleLabel.text = generalContents[indexPath.row]
            cell.titleLabel.textColor = .gray
            cell.textLabel?.text = ""
            
            if indexPath.row == 0 {
                cell.infoLabel.text = txIdStr
            } else if indexPath.row == 1 {
                cell.selectionStyle = .none
                cell.infoLabel.text = dateStr
            } else if indexPath.row == 2 {
                cell.selectionStyle = .none
                cell.infoLabel.text = feeStr
            } else if indexPath.row == 3 {
                cell.selectionStyle = .none
                cell.infoLabel.text = confStr
            }
            
        default: break
            
        }
        
        return cell
        
}
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableTitle[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableTitle.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
            
        case 1:
            return toContents.count
            
        case 2:
            return fromContents.count
            
        case 3:
            return generalContents.count
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 1:
            showActionSheetWithCopyMessage(copyString: toContents[indexPath.row])
        case 2:
            showActionSheetWithCopyMessage(copyString: fromContents[indexPath.row])
        case 3:
            if indexPath.row == 0 {
                showActionSheetWithCopyMessage(copyString: txIdStr)
            }
        default:
            break
        }
    
    }
    
    func showActionSheetWithCopyMessage(copyString: String) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let copyAction = UIAlertAction(title: NSLocalizedString("copyClip", comment: ""), style: .default, handler: {
            (result : UIAlertAction) -> Void in
            let board = UIPasteboard.general
            //board.setValue(copyString, forPasteboardType: "public.text")
            board.string = copyString
            //print("copy \(copyString) to clipboard.")
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {
            (result : UIAlertAction) -> Void in
            
        })
        
        alert.addAction(copyAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }

    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
