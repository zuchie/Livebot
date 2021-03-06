//
//  ChatViewModel.swift
//  Livebot
//
//  Created by Zhe Cui on 9/5/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

struct ChatViewModel {
    
  func createRequest(message: String) -> Observable<JSON> {
    return MessageProcessor.shared.process(message)
      .map { bot -> Request in
        switch bot {
        case .weather(let request):
          return request
        }
      }
      .flatMap { request in
        return APIController.shared.makeRequest(
          baseURL: request.url,
          pathComponent: request.pathComponent,
          params: request.parameters,
          headers: request.headers
        )
    }
  }
}
