//
//  WeatherTableViewCell.swift
//  Livebot
//
//  Created by Zhe Cui on 9/21/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {
  @IBOutlet weak var icon: UILabel!
  @IBOutlet weak var cityName: UILabel!
  @IBOutlet weak var temperature: UILabel!
  @IBOutlet weak var humidity: UILabel!
  @IBOutlet weak var date: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    style()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  private func style() {
    self.contentView.backgroundColor = UIColor.aztec
    cityName.textColor = UIColor.ufoGreen
    temperature.textColor = UIColor.cream
    humidity.textColor = UIColor.cream
    icon.textColor = UIColor.cream
    date.textColor = UIColor.cream
    
    Appearance.applyBottomLine(to: cityName, date)
  }

}
