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
  var newlyCreatedTweet: Tweet? {get set}
}

class ComposeViewController: UIViewController {
  
  @IBOutlet weak var characterCountLabel: UILabel!
  @IBOutlet weak var tweetTextView: SZTextView!
  @IBOutlet weak var tweetButton: UIButton!
  
  var delegate: ComposeViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tweetTextView.delegate = self
    setupNavigationController()
    disableTweetButton()
    print(User.currentUser?.profileImageUrl)
  }
  
  @IBAction func didTapBack(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func didTapTweet(sender: AnyObject) {
    let parameters = ["status": tweetTextView.text]
    TwitterClient.sharedTwitterClient().composeTweet(parameters, success: { (tweet: Tweet) in
    }) { (error: NSError) in
      print(error.localizedDescription)
    }
    // Assemble new tweet
    let newTweetDictionary = NSDictionary()
    let newTweet = Tweet(dictionary: newTweetDictionary)
    newTweet.text = tweetTextView.text
    newTweet.username = User.currentUser?.username
    newTweet.screenname = User.currentUser?.screenname
    newTweet.profileImageUrl = User.currentUser?.profileImageUrl
    delegate?.newlyCreatedTweet = newTweet
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func setupNavigationController() {
    navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
    navigationController?.navigationBar.shadowImage = UIImage()
    navigationItem.rightBarButtonItem?.tintColor = UIColor.twitterBlueColor()
  }
  
  func disableTweetButton() {
    tweetButton.enabled = false
    tweetButton.backgroundColor = UIColor.lightGrayColor()
    tweetButton.layer.cornerRadius = 10
  }
  
  func enableTweetButon() {
    tweetButton.enabled = true
    tweetButton.backgroundColor = UIColor.twitterBlueColor()
  }
}

extension ComposeViewController: UITextViewDelegate {
  func textViewDidChange(textView: UITextView) {
    if tweetTextView.text.isEmpty {
      disableTweetButton()
      let numberOfCharactersAllowed = 140
      characterCountLabel.text = String(numberOfCharactersAllowed)
    } else {
      let characterCount = tweetTextView.text.characters.count
      characterCountLabel.text = String(Int(140 - characterCount))
      enableTweetButon()
    }
  }
}
