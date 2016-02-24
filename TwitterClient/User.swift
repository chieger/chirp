//
//  User.swift
//  TwitterClient
//
//  Created by Charles Hieger on 2/23/16.
//  Copyright © 2016 Charles Hieger. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var name: NSString?
    var screenname: NSString?
    var profileUrl: NSURL?
    var tagLine: NSString?
    
    init(dictionary: NSDictionary) {
        
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        
        let profileUrlString = dictionary["profile_image_url"] as? String
        if let profileUrlString = profileUrlString {
            profileUrl = NSURL(string: profileUrlString)
        }
        
        tagLine = dictionary["description"] as? String
    }

}
