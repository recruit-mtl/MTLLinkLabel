//
//  TableViewCell.swift
//  MTLLinkLabelExample
//
//  Created by HiraiKokoro on 2015/10/10.
//  Copyright (c) 2016, Recruit Holdings Co., Ltd.
//

import UIKit
import MTLLinkLabel

class TableViewCell: UITableViewCell {
    
    @IBOutlet var label: LinkLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
