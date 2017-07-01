//
//  BITransactionDetailViewController.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/07/01.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import UIKit

class BITransactionDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var tableTitle = ["", "TO:", "FROM:", ""]
    private let generalContents = ["ID", "Dete", "Fee", "Confirmations"]
    private var toContents: [String] = ["my3TE7S7ou4UxYLj5HXcLVsiTt32th4qeN"]
    private var fromContents: [String] = ["my3TE7S7ou4UxYLj5HXcLVsiTt32th4qeN"]
    private var isSpentTransaction = true
    
    @IBOutlet weak var tableView: UITableView!


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TransactionDetailTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.backgroundColor = UIColor.backgroundWhite()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TransactionDetailTableViewCell
        
        switch indexPath.section {
        case 0:
            let action = isSpentTransaction ? "Sent" : "Received"
            let textColor = isSpentTransaction ? UIColor.sentRed() : UIColor.receivedGreen()
            cell.titleLabel.text = action
            cell.titleLabel.textColor = textColor
            
        case 1:
            cell.textLabel?.text = toContents[indexPath.row]
            cell.textLabel?.textColor = .gray
            
        case 2:
            cell.textLabel?.text = fromContents[indexPath.row]
            cell.textLabel?.textColor = .gray
            
            
        case 3:
            cell.titleLabel.text = generalContents[indexPath.row]
            cell.titleLabel.textColor = .gray
            
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
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
