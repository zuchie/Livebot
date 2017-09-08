//
//  MessageService.swift
//  Livebot
//
//  Created by Zhe Cui on 9/5/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation
import RxSwift

struct MessageService: MessageServiceType {
  
  @discardableResult
  func findBot(from message: Message) throws -> Observable<Bot> {
    return try MessageProcessor.process(message)
  }
}
