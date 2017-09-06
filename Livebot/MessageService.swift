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
  func findBot(from message: Message) -> Observable<Bot> {
    // TODO: let weather = ["weather"], scan weather array.
    if message.lowercased().contains("weather") {
      return Observable.just(Bot.weather)
    }
    // TODO: Test other bots. 
    return .error(MessageServiceError.unknownBot)
  }
}
