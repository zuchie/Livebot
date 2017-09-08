//
//  MessageProcessor.swift
//  Livebot
//
//  Created by Zhe Cui on 9/7/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation
import RxSwift

enum MessageProcessorError: Error {
  case unknownBot(String)
}

class MessageProcessor {
  
  static var shared = MessageProcessor()
  
  func process(_ message: String) -> Observable<Bot> {
    
    // TODO: Replace placeholder
    let city = "San Jose"
    
    // TODO: Use NLP to get weather, pathComponent, and parameters.
    if message.lowercased().contains("weather") {
      let bot = Weather()
      bot.request.pathComponent = "weather"
      bot.request.parameters = [
        ("q", city),
        ("appid", bot.request.apiKey),
        ("units", "metric")
      ]
      
      return Observable.just(Bot.weather(bot))
    }
    
    // TODO: Test other bots.
    return .error(MessageProcessorError.unknownBot(message))
  }
}
