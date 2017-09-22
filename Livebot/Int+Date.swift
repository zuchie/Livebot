//
//  DateFormatter.swift
//  Livebot
//
//  Created by Zhe Cui on 9/21/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation

extension Int {
  
  // Convert from Date to date string
  var dateFormat: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd, EE, h a"
    
    return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(self)))
  }
}
