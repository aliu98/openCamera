//
//  ComposeViewController.swift
//  surplusapp
//
//  Created by Student on 3/29/17.
//  Copyright © 2017 Student. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class ComposeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var postTitleField: UITextField!
    @IBOutlet weak var amountSlider: UISlider!
    @IBOutlet weak var photoImageView: UIImageView!
    
    var name:String = ""
    var amount:Float = 0
    
    var ref:FIRDatabaseReference?
    var storage:FIRStorageReference?
    
    var camDidOpen:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        amountSlider.minimumValue = 0
        amountSlider.maximumValue = 5
        amount = amountSlider.value
        postTitleField.text = "Write title here"
        //postID = "1"
        ref = FIRDatabase.database().reference()
        storage = FIRStorage.storage().reference()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        if photoImageView.image == nil {
            if self.camDidOpen==true{
                presentingViewController?.dismiss(animated: true, completion: nil)
            } else{
                self.loadCamera()
            }
        }
    }
    
    //function that opens the camera
    func loadCamera() {
       if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
        
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.camDidOpen = true
            self.present(imagePicker, animated: true, completion: nil)
        
        }
    }
    
    //takes the picture taken to be displayed
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo:[NSObject : AnyObject]!){
        photoImageView.image = image
        
        self.dismiss(animated: true, completion: nil);
    }
  
    @IBAction func slideAction(_ sender: Any) {
        amount = amountSlider.value
    }
    
    @IBAction func createPost(_ sender: Any) {
        guard (postTitleField.text != "") else{
            //TODO: Pop up an error message: "You need a title"
            postTitleField.text = "failed, type a title here"
            return
        }
        
        guard (photoImageView.image != nil ) else{
            //TODO: popup
            return
        }
        
        name = postTitleField.text!
        //photo = photoImageView.image
        
        
        //post the data to the firebase database
   
        let post = ref?.child("Posts").childByAutoId()
        
        post?.child("title").setValue(name)
        post?.child("amount").setValue(amount)
        
        let date = Date()
        // convert Date to TimeInterval (typealias for Double)
        let timepassed = date.timeIntervalSince1970
        post?.child("time").setValue(timepassed)
        
        post?.child("omw").setValue(0)
        post?.child("flags").setValue(0) //Use 2 for testing, but remember to SWITCH THIS BACK!!!!!!!!!!-------------------------------------------------
        
        // convert to Integer
     
        let ID:String = (post?.key)!
        
        print("The post ID is: \(ID)")
        
        let data = UIImagePNGRepresentation(photoImageView.image!) as NSData!
        let photoref =
            storage?.child("Posts").child("\(ID).jpg")
        
        let uploadTask = photoref?.put(data as! Data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            let downloadURL = metadata.downloadURL
        }
        //post?.child("photoID").setValue(ID)

        
        //dismisses the popover, putting us back to the ViewController screen.
        presentingViewController?.dismiss(animated: true, completion: nil)
        
        //postID = "2"
    }
    
    @IBAction func cancelPost(_ sender: Any) {
        
        //dismisses the popover, putting us back to the ViewController screen.
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
   // override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        //segue.
        // Pass the selected object to the new view controller.
 //   }
    

}
