//
//  ProfileViewController.swift
//  TwitterClient
//
//  Created by Charlie Hieger on 4/13/16.
//  Copyright © 2016 Charles Hieger. All rights reserved.
//

import UIKit
import AFNetworking

class ProfileViewController: UIViewController {
  
  @IBOutlet weak var profileBackgroundImageView: UIImageView!
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var screennameLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var followingCountLabel: UILabel!
  @IBOutlet weak var followersCountLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  
  var tweets = [Tweet]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = self
    
    if let profileBackgroundImageUrl = User.currentUser?.profileBackgroundImageUrl {
      profileBackgroundImageView.setImageWithURL(profileBackgroundImageUrl)
    }
    profileBackgroundImageView.backgroundColor = UIColor.twitterBlueColor()
    if let profileImageUrl = User.currentUser?.profileImageUrl {
      profileImageView.setImageWithURL(profileImageUrl)
    }
    usernameLabel.text = User.currentUser?.username
    screennameLabel.text = User.currentUser?.screenname
    descriptionLabel.text = User.currentUser?.tagline
    locationLabel.text = User.currentUser?.location
    updateCountLabel(followersCountLabel, count: User.currentUser?.followersCount)
    updateCountLabel(followingCountLabel, count: User.currentUser?.followingCount)
    print(User.currentUser?.dictionary)
    
    TwitterClient.sharedTwitterClient().getUserTimeline({ (tweets: [Tweet]) in
      self.tweets = tweets
      self.tableView.reloadData()
    }) { (error: NSError) in
      print(error.localizedDescription)
    }
  }
  
  func updateCountLabel(label: UILabel, count: Int?) {
    label.hidden = (count == 0)
    if let count = count {
      label.text = String(count)
    }
  }
  
  func updateButton(button: UIButton, selected: Bool?) {
    if let selected = selected {
      button.selected = selected
    }
  }
}

extension ProfileViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tweets.count
  }
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("ProfileTweetCell", forIndexPath: indexPath) as! ProfileTweetCell
    cell.tweet = tweets[indexPath.row]
    return cell
  }
  
}



