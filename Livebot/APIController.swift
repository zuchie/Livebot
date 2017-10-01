//
//  APIController.swift
//  Livebot
//
//  Created by Zhe Cui on 9/7/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftyJSON
import RxAlamofire

enum APIControllerError: Error {
  case invalidURLComponents
  case invalidURL
}

class APIController {
  /// The shared instance
  static var shared = APIController()
  
  /**
   *  Method to make a request with RxCocoa
   */
  func makeRequest(
    baseURL: URL,
    pathComponent: String,
    params: [String: String],
    headers: [String: String]
  ) -> Observable<JSON> {
    
    let url = baseURL.appendingPathComponent(pathComponent)
        
    return data(.get, url, parameters: params, headers: headers)
      .map { JSON(data: $0) }
    
  }
  
}

