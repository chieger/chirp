//
//  ComposeViewController.swift
//  TwitterClient
//
//  Created by Charlie Hieger on 3/29/16.
//  Copyright © 2016 Charles Hieger. All rights reserved.
//

import UIKit
import SZTextView

protocol ComposeViewControllerDelegate {
  var tweets: [Tweet] {get set}
  var tableView: UITableView! {get set}
}

class ComposeViewController: UIViewController, UITextViewDelegate {
  
  @IBOutlet weak var tweetTextView: SZTextView!
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var tweetButton: UIButton!
  
  var delegate: ComposeViewControllerDelegate?
  var blueColorTwitter: UIColor = UIColor(red: 64/255, green: 153/255, blue: 255/255, alpha: 1.0)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tweetTextView.delegate = self
    tweetButton.enabled = false
    tweetButton.backgroundColor = UIColor.lightGrayColor()
    backButton.tintColor = blueColorTwitter
    tweetButton.layer.cornerRadius = 20
  }
  
  func textViewDidChange(textView: UITextView) {
    print("I am typing in me TextView")
    if tweetTextView.text.isEmpty {
      tweetButton.enabled = false
      tweetButton.backgroundColor = UIColor.lightGrayColor()
      tweetButton.layer.shadowOpacity = 0
    } else {
      tweetTextView.text.characters.count
      tweetButton.enabled = true
      UIView.animateWithDuration(0.2, animations: {
        self.tweetButton.backgroundColor = self.blueColorTwitter
        }, completion: { (Bool) in
          self.tweetButton.layer.shadowColor = UIColor.darkGrayColor().CGColor
          self.tweetButton.layer.shadowOffset = CGSize(width: 2, height: 2)
          self.tweetButton.layer.shadowOpacity = 1.0
      })
    }
  }
  
  @IBAction func didPressBack(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func didTapTweet(sender: AnyObject) {
    let tweetText = tweetTextView.text
    let parameters = ["status": tweetText]
    let newTweet = [Tweet(dictionary: parameters)]
    TwitterClient.sharedTwitterClient().composeTweet(parameters, success: { (tweet: Tweet) in
      self.delegate?.tweets = newTweet + (self.delegate?.tweets)!
      self.delegate?.tableView.reloadData()
      self.dismissViewControllerAnimated(true, completion: nil)
    }) { (error: NSError) in
      print(error.localizedDescription)
    }
  }
}
