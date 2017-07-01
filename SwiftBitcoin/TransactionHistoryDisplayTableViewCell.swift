//
//  TransactionHistoryDisplayTableViewCell.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/07/01.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import UIKit

public class TransactionHistoryDisplayTableViewCell: UITableViewCell {
    
    public var txActionLabel: UILabel = UILabel()
    public var timeLabel: UILabel = UILabel()
    public var amountLabel: UILabel = UILabel()
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(txActionLabel)
        self.addSubview(timeLabel)
        self.addSubview(amountLabel)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let xMargin: CGFloat = 20.0
        let yMargin: CGFloat = 10.0
        let width = self.bounds.width / 2 - xMargin
        let height = self.bounds.height / 2 - yMargin
        
        let lowerY = yMargin + height
        
        txActionLabel.frame = CGRect(x: xMargin, y: yMargin, width: width, height: height)
        txActionLabel.backgroundColor = .clear
        //txActionLabel.textColor = UIColor.sentRed()
        
        timeLabel.frame = CGRect(x: xMargin, y: lowerY, width: width, height: height)
        timeLabel.backgroundColor = .clear
        timeLabel.textColor = .lightGray
        
        amountLabel.frame = CGRect(x: self.bounds.width / 2.0, y: yMargin, width: width, height: height)
        amountLabel.backgroundColor = .clear
        amountLabel.textColor = .gray
        amountLabel.textAlignment = .right
    }
    
}
