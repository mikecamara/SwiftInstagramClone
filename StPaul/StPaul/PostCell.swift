//
//  PostCell.swift
//  StPaul
//
//  Created by Mike Camara on 12/01/2016.
//  Copyright © 2016 Mike Camara. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var binImage: UIImageView!
    @IBOutlet weak var flagImage: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showCaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    
    var post: Post!
    
    // Create alamofire request and store it
    var request: Request?
    
    var likeRef: Firebase!
    
    var flagRef: Firebase!
    
    var userNameRef: Firebase!
    
    var binRef: Firebase!
    
    var binRefUser: Firebase!
    
    var puxa2: String!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.userInteractionEnabled = true
        
        let flagTap = UITapGestureRecognizer(target: self, action: "flagTapped:")
        flagImage.addGestureRecognizer(flagTap)
        flagImage.userInteractionEnabled = true
        
        let binTap = UITapGestureRecognizer(target: self, action: "binTapped:")
        binImage.addGestureRecognizer(binTap)
        binImage.userInteractionEnabled = false
        
        binImage.hidden = true
        
    }
    
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        showCaseImg.clipsToBounds = true
    }
    
    func configureCell(post: Post, img: UIImage?) { // Pass image as well if it exists
        
        // Get reference to the likes based on the url of Firebase path
        likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
        flagRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("flags").childByAppendingPath(post.postKey)
        
        
        userNameRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("username").childByAppendingPath(post.postKey)
        
        let userNameDefault = NSUserDefaults.standardUserDefaults().stringForKey("userName")!
        
        
        
        binRef = DataService.ds.REF_POSTS.childByAppendingPath(post.postKey)
        binRefUser = DataService.ds.REF_USER_CURRENT.childByAppendingPath(post.postKey)
        
        
        
        
        
        binRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            // If there is no likes in our array leave it empty, In Firebase if a data don't exist is a NSNull, it's a Firebase thing
            let userNameTest2 = snapshot.value.valueForKey("username")
            
            self.puxa2 = String(userNameDefault)

            
        
    })
    
    
        // Check likes
        binRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            // If there is no likes in our array leave it empty, In Firebase if a data don't exist is a NSNull, it's a Firebase thing
            let userNameTest = snapshot.value.valueForKey("username")
            var puxa = String(userNameTest!)
            
            
            if puxa == self.puxa2 {
            
                print("tudo igual")
                self.binImage.hidden = false
                self.binImage.userInteractionEnabled = true

                
            } else {
            
            print("tudo diferente")
                
            }
        })
        
        
    
        self.post = post
        self.descriptionText.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        self.userNameLbl.text = post.username
        self.profileImg.image = img
        
        
        
        if post.profileImageUrl != nil {
            
            
            
            // Did request, download data, make sure is an image
            request = Alamofire.request(.GET, post.profileImageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                
                if err == nil {
                    // Then we have a cache image
                    let img = UIImage(data: data!)!
                    self.profileImg.image = img
                    // Add to our cache
                    FeedVC.imageCache.setObject(img, forKey: self.post.profileImageUrl!)
                    
                    
                } else {
                    //After this test Ive realised that I had to chance the info.plist file and set YES to allow arbitrary loads
                    print(err.debugDescription)
                }
                
            })
            
            
        }
        
        
        
        
        
        if post.imageUrl != nil {
            
            // Load image from the cache
            if img != nil {
                self.profileImg.image = img
                self.showCaseImg.image = img
                self.showCaseImg.hidden = false
                
            } else {
                
                // Did request, download data, make sure is an image
                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    
                    if err == nil {
                        // Then we have a cache image
                        let img = UIImage(data: data!)!
                        self.showCaseImg.image = img
                        self.profileImg.image = img
                        // Add to our cache
                        FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl!)
                        self.showCaseImg.hidden = false
                        
                    } else {
                        //After this test Ive realised that I had to chance the info.plist file and set YES to allow arbitrary loads
                        print(err.debugDescription)
                    }
                    
                })
            }
            
            //if there is no imageUrl just hide the image
        } else {
            self.showCaseImg.hidden = true
        }
        
        flagRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            // If there is no likes in our array leave it empty, In Firebase if a data don't exist is a NSNull, it's a Firebase thing
            if let flagDoesNotExist = snapshot.value as? NSNull {
                // This means we have not liked this specific post
                self.flagImage.image = UIImage(named: "unflagged")
            } else {
                self.flagImage.image = UIImage(named: "flagged")
            }
        })
        
        
        // Check likes
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            // If there is no likes in our array leave it empty, In Firebase if a data don't exist is a NSNull, it's a Firebase thing
            if let doesNotExist = snapshot.value as? NSNull {
                // This means we have not liked this specific post
                self.likeImage.image = UIImage(named: "notPrayed")
            } else {
                self.likeImage.image = UIImage(named: "prayed")
            }
        })
        
        
    }
    
    
    // Similar code to the fun configureCell however now we will need to do
    // Change the image and add one like or remove one like, finally add to our array of posts liked
    func likeTapped(sender: UITapGestureRecognizer) {
        // Check likes
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            // If there is no likes in our array leave it empty, In Firebase if a data don't exist is a NSNull, it's a Firebase thing
            if let doesNotExist = snapshot.value as? NSNull {
                // This means we changing the images
                self.likeImage.image = UIImage(named: "prayed")
                // Adjust the likes, and add a like to it
                self.post.adjustLikes(true)
                // Associate that like with our personal user account, store that
                self.likeRef.setValue(true)
                
            } else {
                self.likeImage.image = UIImage(named: "notPrayed")
                // Remove that like
                self.post.adjustLikes(false)
                // Delete the like key
                self.likeRef.removeValue()
            }
        })
    }
    
    // Add a flag tapped func
    // Similar code to the fun configureCell however now we will need to do
    // Change the image and add one like or remove one like, finally add to our array of posts liked
    func flagTapped(sender: UITapGestureRecognizer) {
        
        
        // Check likes
        flagRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            // If there is no likes in our array leave it empty, In Firebase if a data don't exist is a NSNull, it's a Firebase thing
            if let doesNotExist = snapshot.value as? NSNull {
                // This means we changing the images
                self.flagImage.image = UIImage(named: "flagged")
                // Adjust the likes, and add a like to it
                self.post.adjustFlags(true)
                // Associate that like with our personal user account, store that
                self.flagRef.setValue(true)
                
            } else {
                self.flagImage.image = UIImage(named: "unflagged")
                // Remove that like
                self.post.adjustFlags(false)
                // Delete the like key
                self.flagRef.removeValue()
            }
        })
    }
    
    func binTapped(sender: UITapGestureRecognizer) {
                
        binRef.removeValue()
        
    }
    
    
    
}
