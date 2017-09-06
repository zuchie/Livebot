//
//  Scene+ViewController.swift
//  Livebot
//
//  Created by Zhe Cui on 9/6/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit

extension Scene {
  func viewController() -> UIViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    switch self {
    case .chat(let viewModel):
      let nc = storyboard.instantiateViewController(withIdentifier:
        "Chat") as! UINavigationController
      var vc = nc.viewControllers.first as! ChatViewController
      vc.bindViewModel(to: viewModel)
      return nc
    } }
}
