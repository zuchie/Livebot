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
  
  func bindViewModel() {
    sendButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .flatMap {
        return self.viewModel.createRequest(message: self.message.text)
      }
      .subscribe(onNext: { result in
        // TODO: process json to tableView
        print(result)
      }, onError: { error in
        // TODO: Error handling, don't freeze app when error.
        switch error {
        case let MessageProcessorError.missingInfo(message, bot):
          print("== bot: \(bot), missing info from: \(message)")
        case let MessageProcessorError.unknownBot(message):
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

  fileprivate func configureCell(_ cell: UITableViewCell) {
    cell.textLabel?.text = "cell"
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)

    configureCell(cell)
    
    return cell
  }
  
}

