//
//  SceneTransitionType.swift
//  Livebot
//
//  Created by Zhe Cui on 9/6/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation

enum SceneTransitionType {
  // you can extend this to add animated transition types,
  // interactive transitions and even child view controllers!
  
  case root       // make view controller the root view controller
  case push       // push view controller to navigation stack
  case modal      // present view controller modally
}
