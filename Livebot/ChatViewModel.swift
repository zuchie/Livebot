//
//  ChatViewModel.swift
//  Livebot
//
//  Created by Zhe Cui on 9/5/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation
import RxSwift

//typealias MyJSON = [String: Any]
struct ChatViewModel {
  let messageService: MessageServiceType
  let bag = DisposeBag()
  
  init(messageService: MessageServiceType) {
    self.messageService = messageService
  }
  
  /*
  func onCreateRequest<T: Any>(message: Message) -> Observable<T> {
    return self.messageService.findBot(from: message)
      .flatMap { bot in
        //ApiaiAPI.shared.makeApiaiRequest(token: bot.rawValue, userSays: message)
        switch bot {
        case .weather(let botQuery):
          return botQuery
        default:
          return Observable.error(MessageServiceError.unknownBot)
        }
        /*
        APIController.shared.buildRequest(
          apiKey: query.apiKey,
          baseURL: query.url,
          pathComponent: query.pathComponent,
          params: query.parameters
        )
        */
      }
  }
  */
  
  func onCreateRequest(message: Message) throws -> Observable<Request> {
    return try self.messageService.findBot(from: message)
      .map { bot in
        switch bot {
        case .weather(let requestBot):
          return requestBot.request
        }
      }
  }
}
