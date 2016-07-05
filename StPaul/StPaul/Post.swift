//
//  Post.swift
//  StPaul
//
//  Created by Mike Camara on 12/01/2016.
//  Copyright © 2016 Mike Camara. All rights reserved.
//

import Foundation
import Firebase

class Post {

    // ! required ?optional
    private var _postDescription: String!
    private var _imageUrl: String?
    private var _likes: Int!
    private var _username: String!
    private var _postKey: String!
    private var _profileImageUrl: String?
    private var _flags: Int!
    
    var binRef: Firebase!
    
    // Hold a reference to the post
    private var _postRef: Firebase!
     private var _postRefFlag: Firebase!
    
    var postDescription: String {
        return _postDescription
    }
    
    var imageUrl: String? {
        return _imageUrl
    }

    var profileImageUrl: String? {
        return _profileImageUrl
    }
    
    var username: String {
        return _username
    }
    
    var postKey: String {
        return _postKey
    }
    
    
    var likes: Int {
        return _likes
    }
    
    var flags: Int {
        return _flags
    }
    
    init(description: String, imageUrl: String?, profileImageUrl: String?, username: String) {
        self._postDescription = description
        self._imageUrl = imageUrl
        self._profileImageUrl = profileImageUrl
        self._username = username
    }
    
    // Create another initializer for whenever downloading data from Firebase we create a new post object and we pass to a dictionary that we get from Firebase so we can use the data, better practice than handle it from the viewController
    
    init(postKey: String, dictionary: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let likes = dictionary["likes"] as? Int {
            self._likes = likes
        }
        
        if let flags = dictionary["flags"] as? Int {
            self._flags = flags
        }
        
        if let imageUrl = dictionary["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
        
        if let profileImageUrl = dictionary["profileImageUrl"] as? String{
            self._profileImageUrl = profileImageUrl
        }
        
        if let desc = dictionary["description"] as? String {
            self._postDescription = desc
        }
        
        if let username = dictionary["username"] as? String {
            self._username = username
        }
        
        // create a reference to the post
        self._postRef = DataService.ds.REF_POSTS.childByAppendingPath(self._postKey!)    // Add a like
        
        
        // create a reference to the post
        self._postRefFlag = DataService.ds.REF_POSTS.childByAppendingPath(self._postKey!)    // Add a like

     

    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
            
            
            
        } else {
            _likes = _likes - 1
        }
        // Save it on the Firebase database, setValue replaces whatever you put in it
        _postRef.childByAppendingPath("likes").setValue(_likes)
    }
    
    func adjustFlags(addFlag: Bool) {
        if addFlag {
            _flags = _flags + 1
            
            
        } else {
            _flags = _flags - 1
        }
        // Save it on the Firebase database, setValue replaces whatever you put in it
        _postRefFlag.childByAppendingPath("flags").setValue(_flags)
    }

    

}
