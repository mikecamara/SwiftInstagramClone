//
//  FeedVC.swift
//  StPaul
//
//  Created by Mike Camara on 12/01/2016.
//  Copyright © 2016 Mike Camara. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import Foundation

import FBSDKCoreKit
import FBSDKLoginKit

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var progressBar: UIProgressView!
    
    
    @IBOutlet weak var logOutBtn: UIBarButtonItem!
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSelectorImage: UIImageView!
    var posts = [Post]()
    
    var imageSelected = false
    
    var imagePicker: UIImagePickerController!
    
    
    var isAscending = true
    
    
    // Store data locally and temporarily with this variable
    // What static does is make one instance of it publicly, globally available
    static var imageCache = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //self.tableView.allowsMultipleSelectionDuringEditing = false;
        
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        
        
        self.progressBar.hidden = true
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        tableView.estimatedRowHeight = 366
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        // this is a closure that keeps runnin over and over
        // concept of instant syncing
        // Listens to any changes made to the database in this specific path
        // Data from firebase come as a snapshot as you can see below
        DataService.ds.REF_POSTS.queryOrderedByChild("likes").observeEventType(.Value, withBlock: { snapshot in
            
            
            //print(snapshot.value)
            // Empty array in case there are posts in it
            self.posts = []
            
            // snapshot or FDataSnapshot is how firebase send their objetcs
            
            // .all objects is an array of objects contained in firebase
            // Parsing Firebase data - grabbing snapshot and all the children
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                // Grabbing key from the objects
                for snap in snapshots {
                    print("SNAP: \(snap)")
                    
                    // Converting the data from json objects to dictonary
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        // Grabbing the values of the Keys
                        let key = snap.key
                        // Create a new post
                        let post = Post(postKey: key, dictionary: postDict)
                        // Add post to array of Posts
                        self.posts.append(post)
                    }
                }
            }
            // Refresh new data
            self.tableView.reloadData()
        })
        // End of talking to Firebase
        // this was how we downloaded our posts from firebase
        
        
        //Facebook picture
        
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            
            cell.request?.cancel()
            
            var img: UIImage?
            
            var lblName = NSUserDefaults.standardUserDefaults().stringForKey("userName")
            
            print(lblName)
            
            
            if let url = post.imageUrl {
                // I'm using the name of the class instead self because it's publicly available and Im grabbing the unique instance of it
                img = FeedVC.imageCache.objectForKey(url) as? UIImage
            }
            
            cell.configureCell(post, img: img)
            
            return cell
        } else {
            return PostCell()
        }
    }
    
    
    
    
    // This func sets a height for each row
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        
        if post.imageUrl == nil {
            return 150
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageSelectorImage.image = image
        imageSelected = true
    }
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func makePost(sender: AnyObject) {
        
        
        
        
        // create a standard verification to check if the textfield is not nil, otherwise don't do anything and don't let the user proceed
        if let txt = postField.text where txt != "" {
            // Check if is there an image, but it will always have the camera, in the future improve to check if it is different from the camera icon
            
            
            if let  img = imageSelectorImage.image where imageSelected == true {
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlStr)!
                
                
                
                
                //as smartphone images can be huge, let's use the following to convert to JPEG and to minimal size
                // 0 means fully compressed and 1 means no compressed at all
                let imgData = UIImageJPEGRepresentation(img, 0.2)!
                
                
                // Convert String into data - standard encoding formart for strings
                let keyData = "17ADIKPX8c19f27a622fe6d5707c8d14e8177454".dataUsingEncoding(NSUTF8StringEncoding)!
                
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                
                
                Alamofire.upload(
                    .POST,
                    url,
                    multipartFormData: { multipartFormData in
                        
                        multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName:"image", mimeType: "image/jpg")
                        
                        multipartFormData.appendBodyPart(data: keyData, name: "key")
                        
                        multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                        
                    },
                    encodingCompletion: { encodingResult in
                        
                        
                        switch encodingResult {
                            
                        case .Success(let upload, _, _):
                            
                            
                            // The following code is the progress bar
                            self.progressBar.hidden = false
                            
                            
                            upload.progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                                print(totalBytesRead)
                                
                                dispatch_async(dispatch_get_main_queue()) {
                                    
                                    var uploadProgress:Float = Float(totalBytesRead) / Float(totalBytesExpectedToRead)
                                    
                                    self.progressBar.setProgress(uploadProgress, animated: true)
                                    
                                }
                            }
                            
                            // end of progress bar code
                            
                            upload.responseJSON { response in
                                
                                
                                
                                
                                if let info = response.result.value as? Dictionary<String,AnyObject> {
                                    
                                    
                                    if let links = info["links"] as? Dictionary<String,AnyObject> {
                                        
                                        
                                        
                                        if let imgLink = links["image_link"] as? String {
                                            
                                            
                                            
                                            print("LINK: \(imgLink)")
                                            self.postToFirebase(imgLink)
                                            self.progressBar.hidden = true
                                            self.progressBar.progress = 0
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        case.Failure(let error):
                            
                            print(error)
                        }
                    }
                )
                
                
                
            } else {
                
                // In case there is no image only post the text which is compulsory
                self.postToFirebase(nil)
                
            }
        }
        
        
    }
    
    // This is how to post to Firebase
    func postToFirebase(imgUrl: String?) {
        
        self.progressBar.hidden = false
        
        let timestamp = FirebaseServerValue.timestamp()
        
        //I stopped here, have to cahnge the order of this timestamp
        
        // Create the format data you want
        var post: Dictionary<String, AnyObject> = [
            "description": self.postField.text!,
            "likes":0,
            "timestamp":timestamp,
            "flags":0,
            "username": NSUserDefaults.standardUserDefaults().stringForKey("userName")!
        ]
        
        
        
        // Add the url if there is one
        if imgUrl != nil {
            post["imageUrl"] = imgUrl!
            
            
            
        }
        // Create a new database entry
        // Add a new item to the array(object) of posts, which is URL based - creates a new child
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        
        firebasePost.setValue(post)
        
        
        
        // Reset posting fields
        postField.text = ""
        imageSelectorImage.image = UIImage(named: "camera")
        imageSelected = false
        
      
        
        
        
    }
    
    @IBAction func logoutUser(sender: AnyObject) {
        
        
        
        
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_UID)
        
        let loginPage = self.storyboard?.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
        self.presentViewController(loginPage, animated: true, completion: nil)
        // let loginPageNav = UINavigationController(rootViewController: loginPage)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //appDelegate.window?.rootViewController = loginPageNav
        appDelegate.window?.rootViewController = loginPage
        
        
    }
    
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    
    
}








