//
//  ChatViewModel.swift
//  Livebot
//
//  Created by Zhe Cui on 9/5/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation
import RxSwift

typealias JSON = [String: Any]
struct ChatViewModel {
  let messageService: MessageServiceType
  let bag = DisposeBag()
  
  init(messageService: MessageServiceType) {
    self.messageService = messageService
  }
  
  func onCreateRequest<T: Any>(message: Message) -> Observable<T> {
    return self.messageService.findBot(from: message)
      .flatMap { bot in
        ApiaiAPI.shared.makeApiaiRequest(token: bot.rawValue, userSays: message)
      }
  }
  
}
