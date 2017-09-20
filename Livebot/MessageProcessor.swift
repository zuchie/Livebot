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

struct MessageProcessorResult {
  var date: Date?
  var placeName: String?
  var personName: String?
  var organizationName: String?
}

class MessageProcessor {
  static var shared = MessageProcessor()
  
  func process(_ message: String) -> Observable<Bot> {
    let processedMessage = merge(dataDetector(message), nlp(message))

    return Observable.just(processedMessage)
      .flatMap { [weak self] processed -> Observable<Bot> in
        // Weather bot
        if message.lowercased().contains("weather") {
          return self?.prepareWeatherBot(message, processed) ?? .error(MessageProcessorError.prepareBotFailed)
        }
        // TODO: Test other bots.
        
        return .error(MessageProcessorError.unknownBot(message))
      }
  }
  
  private func prepareWeatherBot(_ message: String, _ processed: MessageProcessorResult) -> Observable<Bot> {
    var place: String
    var dayDelta: Int
    if processed.placeName != nil {
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
    
    let bot = Weather()
    bot.request.pathComponent = path
    bot.request.parameters = [
      ("q", place),
      ("appid", bot.request.apiKey)
    ]
    
    return Observable.just(Bot.weather(bot))
  }
  
  private func getDayDelta(_ firstDate: Date, _ secondDate: Date) -> Int {
    let calendar = Calendar.current
    
    let day1 = calendar.component(.day, from: firstDate)
    let day2 = calendar.component(.day, from: secondDate)
    
    return day2 - day1
  }
  
  private func merge(_ resultWithDate: MessageProcessorResult, _ resultWithOthers: MessageProcessorResult) -> MessageProcessorResult {
    return MessageProcessorResult(date: resultWithDate.date,
                                  placeName: resultWithOthers.placeName,
                                  personName: resultWithOthers.personName,
                                  organizationName: resultWithOthers.organizationName)
  }
  
  // NSDataDetector couldn't detect addresses in format "city", e.g. San Jose
  // it can only detect addresses in format "city/City, STATE", e.g. san jose, CA
  // To detect date.
  private func dataDetector(_ text: String) -> MessageProcessorResult {
    let text = text
    //text = "Weather in san jose, CA tomorrow"
    let types: NSTextCheckingResult.CheckingType = [.address, .date, .link, .phoneNumber]
    let range = NSRange(location: 0, length: text.utf16.count)
    guard let detector = try? NSDataDetector(types: types.rawValue) else {
      print("Couldn't create Data Detector")
      fatalError()
    }
    
    var matchResult = MessageProcessorResult()
    
    detector.enumerateMatches(in: text, options: [], range: range) { result, _, _ in
      
      if result?.resultType == .date, let date = result?.date {
        print("date: \(date)")
        matchResult.date = date
      } else {
        print("Couldn't find a match")
      }
    }
    
    return matchResult
  }
  
  // To detect city name because it doesn't need to include STATE in text.
  // TODO: "Weather in San Francisco on Sunday" will be processed in "San Francisco on Sunday - PersonalName"?
  // Unless it's "Weather in San Francisco, on Sunday"
  private func nlp(_ text: String) -> MessageProcessorResult {
    let text = text
    let tagScheme = NSLinguisticTagSchemeNameType
    let taggerOptions: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation, .omitOther, .joinNames]
    let tagger = NSLinguisticTagger(tagSchemes: [tagScheme], options: Int(taggerOptions.rawValue))
    tagger.string = text
    let range = NSRange(location: 0, length: text.utf16.count)
    
    var result = MessageProcessorResult()
    
    tagger.enumerateTags(in: range, scheme: tagScheme, options: taggerOptions) {
      tag, tokenRange, _, _ in
      let token = (text as NSString).substring(with: tokenRange)
      print("\(token): \(tag)")
      
      switch tag {
      case NSLinguisticTagPlaceName:
        result.placeName = token
      case NSLinguisticTagPersonalName:
        result.personName = token
      case NSLinguisticTagOrganizationName:
        result.organizationName = token
      default:
        break
      }
    }
    
    return result
  }

}
