//
//  TextTableViewCell.swift
//  Livebot
//
//  Created by Zhe Cui on 9/21/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit

class TextTableViewCell: UITableViewCell {
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    self.textLabel?.textAlignment = .right
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
