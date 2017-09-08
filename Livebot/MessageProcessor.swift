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
}

typealias TagSchemes = [String]
typealias TagScheme = String
typealias TaggerOptions = NSLinguisticTagger.Options

enum MessageType {
  case weather(TagSchemes, TagScheme, TaggerOptions)
}

class MessageProcessor {
  
  static var shared = MessageProcessor()
  //private let bag = DisposeBag()
  
  private let messageTypes = [
    "weather": MessageType.weather(
      [NSLinguisticTagSchemeNameTypeOrLexicalClass],
      NSLinguisticTagPlaceName,
      [.omitWhitespace, .omitPunctuation, .joinNames]
    )
  ]
  
  func process(_ message: String) -> Observable<Bot> {
    if message.lowercased().contains("weather") {
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
    }
    
    // TODO: Test other bots.
    
    return .error(MessageProcessorError.unknownBot(message))
  }
  
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
      tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "en"),
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
