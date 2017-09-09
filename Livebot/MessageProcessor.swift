//
//  MessageProcessor.swift
//  Livebot
//
//  Created by Zhe Cui on 9/7/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation
import RxSwift

enum MessageProcessorError: Error {
  case unknownBot(String)
  case invalidAddress
}

typealias TagSchemes = [String]
typealias TagScheme = String
typealias TaggerOptions = NSLinguisticTagger.Options

enum MessageType {
  case weather(TagSchemes, TagScheme, TaggerOptions)
}

struct DataDetected {
  var addresses = [[String: String]]()
  var dates = [String]()
  var links = [String]()
  var phoneNumbers = [String]()
}

class MessageProcessor {
  
  static var shared = MessageProcessor()
  
  private let messageTypes = [
    "weather": MessageType.weather(
      [NSLinguisticTagSchemeNameType /*NSLinguisticTagSchemeNameTypeOrLexicalClass*/],
      NSLinguisticTagPlaceName,
      [.omitWhitespace, .omitPunctuation, .omitOther, .joinNames]
    )
  ]
  
  func process(_ message: String) -> Observable<Bot> {
    if message.lowercased().contains("weather") {
      return dataDetector(message)
        .flatMap { place -> Observable<Bot> in
          guard let city = place.addresses.first?[NSTextCheckingCityKey] else {
            print("Couldn't find city")
            return .error(MessageProcessorError.invalidAddress)
          }
          
          let bot = Weather()
          bot.request.pathComponent = "weather"
          bot.request.parameters = [
            ("q", city),
            ("appid", bot.request.apiKey),
            ("units", "metric")
          ]
          
          return Observable.just(Bot.weather(bot))
      }

      /*
      return nlp(message, "weather")
        .flatMap { place -> Observable<Bot> in
          let bot = Weather()
          bot.request.pathComponent = "weather"
          bot.request.parameters = [
            ("q", place),
            ("appid", bot.request.apiKey),
            ("units", "metric")
          ]
          
          return Observable.just(Bot.weather(bot))
        }
      */
    }
    
    // TODO: Test other bots.
    
    return .error(MessageProcessorError.unknownBot(message))
  }
  
  // NSDataDetector couldn't detect addresses in format "city", e.g. San Jose
  // it can only detect addresses in format "city/City, STATE", e.g. san jose, CA
  // To detect date.
  private func dataDetector(_ text: String) -> Observable<DataDetected> {
    var text = text
    text = "Weather in san jose, CA tomorrow"
    let types: NSTextCheckingResult.CheckingType = [.address, .date, .link, .phoneNumber]
    let range = NSRange(location: 0, length: text.utf16.count)
    let detector = try? NSDataDetector(types: types.rawValue)
    
    var data = DataDetected()
    
    return Observable.create { observer in
      detector?.enumerateMatches(in: text, options: [], range: range) { result, flags, _ in
        guard let match = result else {
          return observer.onError(MessageProcessorError.unknownBot(text))
        }
        
        if match.resultType == .address {
          guard let addressComponents = match.addressComponents else {
            print("No address components")
            return observer.onError(MessageProcessorError.invalidAddress)
          }
          
          data.addresses.append(addressComponents)
          return observer.onNext(data)
        }
      }
      return Disposables.create()
    }
  }
  
  // To detect city name because it doesn't need to include STATE in text.
  private func nlp(_ text: String, _ type: String) -> Observable<String> {
    let text = text
    var tagSchemes: TagSchemes
    var tagScheme: TagScheme
    var taggerOptions: TaggerOptions
    guard let messageType = messageTypes[type] else {
      return .error(MessageProcessorError.unknownBot(text))
    }
    switch messageType {
    case let .weather(schemes, scheme, options):
      tagSchemes = schemes
      tagScheme = scheme
      taggerOptions = options
    }
    
    let tagger = NSLinguisticTagger(
      tagSchemes: tagSchemes, // NSLinguisticTagger.availableTagSchemes(forLanguage: "en"),
      options: Int(taggerOptions.rawValue)
    )
    tagger.string = text
    let range = NSRange(location: 0, length: text.utf16.count)

    return Observable.create { observer in
      tagger.enumerateTags(in: range, scheme: tagSchemes.first!, options: taggerOptions) {
        tag, tokenRange, _, _ in
        let token = (text as NSString).substring(with: tokenRange)
        print("\(token): \(tag)")
        
        if tag == tagScheme {
          observer.onNext(token)
        }
      }
      return Disposables.create()
    }
  }

}
