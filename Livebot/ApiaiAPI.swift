//
//  ApiaiAPI.swift
//  Livebot
//
//  Created by Zhe Cui on 9/5/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation
import AI
import RxSwift

class ApiaiAPI {
  static let shared = ApiaiAPI()
  
  //private(set) var response: QueryResponse?
  private(set) var error: Error?

  enum ApiaiError: Error {
    case requestFailed
  }
  
  // NOTE: Create observer in order to return Observable, can't
  // return Observable from AI.sharedService.textRequest(_:) itself.
  func makeApiaiRequest<T: Any>(token: String, userSays: String) -> Observable<T> {
    AI.configure(clientAccessToken: token)
    
    return Observable.create { observer in
      AI.sharedService.textRequest(userSays)
        .success { (response) -> Void in
          guard let result = response as? T else {
            fatalError()
          }
          observer.onNext(result)
        }
        .failure { (error) -> Void in
          observer.onError(error)
        }
        //observer.onCompleted()
      
      return Disposables.create()
    }
  }
}
