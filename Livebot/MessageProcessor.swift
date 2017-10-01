//
//  MessageProcessor.swift
//  Livebot
//
//  Created by Zhe Cui on 9/7/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift

enum MessageProcessorError: Error {
  case unknownBot(String)
  case missingInfo(String, String)
  case queryBeyond(String, String)
  case prepareBotFailed
  //case invalidAddress
}

struct Request {
  var baseURL: String
  var url: URL {
    return URL(string: baseURL)!
  }
  var pathComponent: String
  var parameters: [String: String]
  var headers: [String: String]
}

struct MessageProcessorResult {
  var date: Date?
  var placeName: String?
  var personName: String?
  var organizationName: String?
}

class MessageProcessor {
  static var shared = MessageProcessor()
  let bag = DisposeBag()
  
  func process(_ message: String) -> Observable<Bot> {
    if message.lowercased().contains("weather") {
      return doAPIaiNLP(message)
        .flatMap { [weak self] processed -> Observable<Bot> in
          // Weather bot
          return self?.prepareWeatherBot(message, processed) ?? .error(MessageProcessorError.prepareBotFailed)
        }
    } else { // TODO: Test other bots.
      return .error(MessageProcessorError.unknownBot(message))
    }
  }
  
  func doAPIaiNLP(_ text: String) -> Observable<MessageProcessorResult> {
    let request = Request(
      baseURL: "https://api.api.ai/v1",
      pathComponent: "query",
      parameters: [
        "v": "20150910",
        "lang": "en",
        "sessionId": "1234567890",
        "query": text
      ],
      headers: [
        "Authorization": "Bearer 5e4ca032835746629ad895a8117de97b",
        "Content-Type": "application/json"
      ]
    )
    
    var results = MessageProcessorResult()
    
    return APIController.shared.makeRequest(
      baseURL: request.url,
      pathComponent: request.pathComponent,
      params: request.parameters,
      headers: request.headers
    )
    .map { json in
      let params = json["result"]["parameters"]
      results.placeName = params["geo-city"].string
      
      // Convert from date string to Date
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      guard let ISODate = params["date"].string,
        let date = dateFormatter.date(from: ISODate) else {
          
        return results
      }
      
      results.date = date
      
      return results
    }

  }
  
  private func prepareWeatherBot(_ message: String, _ processed: MessageProcessorResult) -> Observable<Bot> {
    var place: String
    var dayDelta: Int
    if processed.placeName != nil, processed.placeName != "" {
      place = processed.placeName!
    } else {
      print("Couldn't find city, use current location")
      // TODO: Replace placeholder with current location city name.
      place = "San Jose"
    }
    
    if processed.date != nil {
      dayDelta = getDayDelta(Date(), processed.date!)
    } else {
      print("Couldn't find date, use current date")
      dayDelta = 0
    }
    
    var path = ""
    switch dayDelta {
    case 0:
      path = "weather"
    case 1...5:
      path = "forecast"
    default:
      return .error(MessageProcessorError.queryBeyond(message, "weather"))
    }
    
    let request = Request(
      baseURL: "http://api.openweathermap.org/data/2.5",
      pathComponent: path,
      parameters: [
        "q": place,
        "appid": "fdbfbda8ea64d823d88305440f63caf7",
        "units": "metric"
      ],
      headers: [:]
    )
    
    return Observable.just(Bot.weather(request))
  }
  
  private func getDayDelta(_ firstDate: Date, _ secondDate: Date) -> Int {
    let calendar = Calendar.current
    
    let day1 = calendar.component(.day, from: firstDate)
    let day2 = calendar.component(.day, from: secondDate)
    
    return day2 - day1
  }
  
}
