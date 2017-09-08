//
//  Bot.swift
//  Livebot
//
//  Created by Zhe Cui on 9/5/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation

struct Request {
  var baseURL: String
  var url: URL {
    return URL(string: baseURL)!
  }
  var apiKey: String
  var pathComponent: String
  var parameters: [(String, String)]
  
  static let empty = Request(baseURL: "", apiKey: "", pathComponent: "", parameters: [])
}

enum Bot {
  case weather(Weather)
}

class Weather {
  struct Result {
    var cityName = "Unknown"
    var temperature = -1000
    var humidity = 0
    var icon: String = iconNameToChar(icon: "e")
  }

  var request = Request(
    baseURL: "http://api.openweathermap.org/data/2.5",
    apiKey: "fdbfbda8ea64d823d88305440f63caf7",
    pathComponent: "",
    parameters: []
  )
  
  var result = Result()
  
}

/**
 * Maps an icon information from the API to a local char
 * Source: http://openweathermap.org/weather-conditions
 */
public func iconNameToChar(icon: String) -> String {
  switch icon {
  case "01d":
    return "\u{f11b}"
  case "01n":
    return "\u{f110}"
  case "02d":
    return "\u{f112}"
  case "02n":
    return "\u{f104}"
  case "03d", "03n":
    return "\u{f111}"
  case "04d", "04n":
    return "\u{f111}"
  case "09d", "09n":
    return "\u{f116}"
  case "10d", "10n":
    return "\u{f113}"
  case "11d", "11n":
    return "\u{f10d}"
  case "13d", "13n":
    return "\u{f119}"
  case "50d", "50n":
    return "\u{f10e}"
  default:
    return "E"
  }
}
