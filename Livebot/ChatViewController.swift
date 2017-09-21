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
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  private func prepareDataSource(from text: String?, _ weather: Weather?) -> DataSource {
    return DataSource(text: text, weather: weather)
  }
  
  func bindViewModel() {
    sendButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .flatMap {
        return self.viewModel.createRequest(message: self.message.text)
      }
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { result in
        // TODO: process json to tableView
        let weather = Weather(
          cityName: result["name"].string ?? "Unknown",
          temperature: result["main"]["temp"].int ?? -1000,
          humidity: result["main"]["humidity"].int ?? 0,
          icon: result["weather"]["icon"].string ?? "e",
          request: Request.empty
        )
        
        self.dataSource.append(self.prepareDataSource(from: self.message.text, weather))
        self.chatTableView.reloadData()
        
        print(result)
      }, onError: { error in
        // TODO: Error handling, don't freeze app when error.
        switch error {
        case let MessageProcessorError.missingInfo(message, bot):
          print("== bot: \(bot), missing info from: \(message)")
        case let MessageProcessorError.unknownBot(message):
          self.dataSource.append(self.prepareDataSource(from: message, nil))
          self.chatTableView.reloadData()
          
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

  fileprivate func configureCell(_ cell: UITableViewCell, _ index: IndexPath) {
    let data = dataSource[index.row]
    
    cell.textLabel?.text = data.text
    
    if data.weather != nil {
      // TODO: Configure weather cell
    } else {
      // TODO: Configure normal cell
    }
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)

    configureCell(cell, indexPath)
    
    return cell
  }
  
}

