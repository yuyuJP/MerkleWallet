//
//  TransactionDetailTableViewCell.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/07/01.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import UIKit

public class TransactionDetailTableViewCell: UITableViewCell {
    
    public var titleLabel: UILabel = UILabel()
    public var infoLabel: UILabel = UILabel()
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(titleLabel)
        self.addSubview(infoLabel)
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
        
        let width = self.bounds.width / 2 - xMargin
        let height: CGFloat = self.bounds.height
        
        titleLabel .frame = CGRect(x: xMargin, y: 0.0, width: width, height: height)
        titleLabel.backgroundColor = .clear
        //titleLabel.textColor = .gray
        
        infoLabel.frame = CGRect(x: self.bounds.width / 2.0, y: 0.0, width: width, height: height)
        infoLabel.backgroundColor = .clear
        infoLabel.textColor = .lightGray
        infoLabel.textAlignment = .right
    }
}
