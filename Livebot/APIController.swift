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
    method: String = "GET",
    apiKey: String,
    baseURL: URL,
    pathComponent: String,
    params: [(String, String)]) -> Observable<JSON> {
    
    let url = baseURL.appendingPathComponent(pathComponent)
    guard let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true) else {
      return .error(APIControllerError.invalidURLComponents)
    }
    
    if method == "GET" {
      let queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1) }
      urlComponents.queryItems = queryItems
    } else {
      print("Not a GET request")
      //let jsonData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
      //request.httpBody = jsonData
    }
    
    var request = URLRequest(url: url)
    guard let requestURL = urlComponents.url else {
      return .error(APIControllerError.invalidURL)
    }
    request.url = requestURL
    request.httpMethod = method
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    return URLSession.shared.rx.data(request: request).map { JSON(data: $0) }
  }
  
}

