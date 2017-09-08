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

class APIController {
  /// The shared instance
  static var shared = APIController()
  
  /*
  init() {
    Logging.URLRequests = { request in
      return true
    }
  }
  */
  
  //MARK: - Api Calls
  /*
  func currentWeather(city: String) -> Observable<Bot.WeatherResult> {
    // Placeholder call
    /*
     return Observable.just(Weather(cityName: city,
     temperature: 20,
     humidity: 90,
     icon: iconNameToChar(icon: "01d")))
     */
    
    return buildRequest(pathComponent: "weather", params: [("q", city)])
      .map { json in
        return Bot.WeatherResult(
          cityName: json["name"].string ?? "Unkown",
          temperature: json["main"]["temp"].int ?? -1000,
          humidity: json["main"]["humidity"].int ?? 0,
          icon: iconNameToChar(icon: json["weather"][0]["icon"].string ?? "e")
        )
    }
  }
  */
  //MARK: - Private Methods
  
  /**
   * Private method to build a request with RxCocoa
   */
  func buildRequest(
    method: String = "GET",
    apiKey: String,
    baseURL: URL,
    pathComponent: String,
    params: [(String, String)]) -> Observable<JSON> {
    
    let url = baseURL.appendingPathComponent(pathComponent)
    var request = URLRequest(url: url)
    //let keyQueryItem = URLQueryItem(name: "appid", value: apiKey)
    //let unitsQueryItem = URLQueryItem(name: "units", value: "metric")
    let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!
    
    if method == "GET" {
      let queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1) }
      //queryItems.append(keyQueryItem)
      //queryItems.append(unitsQueryItem)
      urlComponents.queryItems = queryItems
    } else {
      print("Not a GET request")
      //urlComponents.queryItems = [keyQueryItem, unitsQueryItem]
      
      //let jsonData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
      //request.httpBody = jsonData
    }
    
    request.url = urlComponents.url!
    request.httpMethod = method
    
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let session = URLSession.shared
    
    return session.rx.data(request: request).map { JSON(data: $0) }
  }
  
}

