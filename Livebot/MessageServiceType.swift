//
//  MessageServiceType.swift
//  Livebot
//
//  Created by Zhe Cui on 9/5/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation
import RxSwift


enum MessageServiceError: Error {
  case unknownBot
}


protocol MessageServiceType {
  @discardableResult
  func findBot(from message: Message) throws -> Observable<Bot>
}
