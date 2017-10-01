//
//  ViewController.swift
//  Livebot
//
//  Created by Zhe Cui on 8/7/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyJSON

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, BindableType {
  @IBOutlet weak var chatTableView: UITableView!
  @IBOutlet weak var message: UITextView!
  @IBOutlet weak var sendButton: UIButton!
  
  private let bag = DisposeBag()
  internal var viewModel: ChatViewModel!
  
  private struct DataSource {
    var text: String?
    var weather: Weather?
  }
  
  private var dataSource = [DataSource]()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    chatTableView.delegate = self
    chatTableView.dataSource = self
    message.delegate = self
    
    registerForKeyboardNotifications()
    
    let weatherCellNib = UINib(nibName: "WeatherTableViewCell", bundle: nil)
    chatTableView.register(weatherCellNib, forCellReuseIdentifier: "weatherCell")
  
    let textCellNib = UINib(nibName: "TextTableViewCell", bundle: nil)
    chatTableView.register(textCellNib, forCellReuseIdentifier: "textCell")
    
    
    //chatTableView.estimatedRowHeight = 44
    //chatTableView.rowHeight = UITableViewAutomaticDimension
  }

  override func viewWillDisappear(_ animated: Bool) {
    unregisterForKeyboardNotifications()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  private func prepareDataSource(from text: String?, _ weather: Weather?) -> DataSource {
    return DataSource(text: text, weather: weather)
  }
  
  private func scrollToBottom() {
    let indexPath = IndexPath(row: dataSource.count - 1, section: 0)
    chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
  }
  
  func bindViewModel() {
    // Query message
    sendButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .filter { (self.message.text ?? "").characters.count > 0 }
      .subscribe(onNext: {
        let data = self.prepareDataSource(from: self.message.text, nil)
        self.dataSource.append(data)
        self.chatTableView.reloadData()
        self.scrollToBottom()
      })
      .disposed(by: bag)
    
    // Answer message
    sendButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .flatMap {
        return self.viewModel.createRequest(message: self.message.text)
      }
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { result in
        // TODO: process json to tableView
        let weather = Weather()
          weather.cityName = result["name"].string ?? "Unknown"
          weather.temperature = result["main"]["temp"].int ?? -1000
          weather.humidity = result["main"]["humidity"].int ?? 0
          weather.icon = result["weather"][0]["icon"].string ?? "e"
          weather.date = result["dt"].int?.dateFormat ?? "Unknown"
          //weather.request = Request.empty
        
        self.dataSource.append(self.prepareDataSource(from: nil, weather))
        self.chatTableView.reloadData()
        self.scrollToBottom()
        
        print(result)
      }, onError: { error in
        // TODO: Error handling, don't freeze app when error.
        switch error {
        case let MessageProcessorError.missingInfo(message, bot):
          print("== bot: \(bot), missing info from: \(message)")
        case let MessageProcessorError.unknownBot(message):
          self.dataSource.append(self.prepareDataSource(from: message, nil))
          self.chatTableView.reloadData()
          self.scrollToBottom()
          
          print("== unknown bot: \(message)")
        case APIControllerError.invalidURL:
          print("## invalid URL")
        case APIControllerError.invalidURLComponents:
          print("## invalid URL components")
        default:
          print("** other error: \(error)")
        }
      })
      .disposed(by: bag)
  }

  private func configureCell(_ cell: UITableViewCell, _ data: DataSource) {
    if let weather = data.weather {
      guard let weatherCell = cell as? WeatherTableViewCell else {
        fatalError()
      }

      weatherCell.icon.text = iconNameToChar(icon: weather.icon)
      weatherCell.cityName.text = weather.cityName
      weatherCell.temperature.text = weather.temperature.description + "℃"
      weatherCell.humidity.text = weather.humidity.description + "%"
      weatherCell.date.text = weather.date
    }
    if let text = data.text {
      cell.textLabel?.text = text
    }
    
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let data = dataSource[indexPath.row]
    var cell: UITableViewCell
    
    if data.weather != nil {
      // TODO: Configure weather cell
      cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath)
    } else {
      // TODO: Configure text cell
      cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath)
    }

    configureCell(cell, data)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let data = dataSource[indexPath.row]
    let weatherCellHeight: CGFloat = 512.0
    let textCellHeight: CGFloat = 44.0
    
    if data.weather != nil {
      return weatherCellHeight
    } else {
      return textCellHeight
    }
  }
  
  // Keyboard
  private func registerForKeyboardNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow(notification:)),
      name: .UIKeyboardWillShow,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide(notification:)),
      name: .UIKeyboardWillHide,
      object: nil
    )
  }

  private func unregisterForKeyboardNotifications() {
    NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
  }

  func keyboardWillShow(notification: Notification) {
    let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue.size
    
    if self.view.frame.origin.y == 0 {
      self.view.frame.origin.y -= keyboardSize.height
    }
    /*
    let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
    chatTableView.contentInset = contentInsets
    chatTableView.scrollIndicatorInsets = contentInsets
    
    var rect = self.view.frame
    rect.size.height -= keyboardSize.height
    
    if !rect.contains(self.message.frame.origin) {
      chatTableView.scrollRectToVisible(message.frame, animated: true)
    }
    */
  }
  
  func keyboardWillHide(notification: Notification) {
    let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue.size

    if self.view.frame.origin.y != 0 {
      self.view.frame.origin.y += keyboardSize.height
    }

    /*
    let contentInsets = UIEdgeInsets.zero
    
    chatTableView.contentInset = contentInsets
    chatTableView.scrollIndicatorInsets = contentInsets
    */
  }
  
}

