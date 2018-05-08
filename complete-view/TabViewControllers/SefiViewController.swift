//
//  SefiViewController.swift
//  complete-view
//
//  Created by Sunshine on 2018/5/6.
//  Copyright © 2018年 Sunshine. All rights reserved.
//

import UIKit
import AWSS3
import AWSMobileHubContentManager
import MobileCoreServices

import ObjectiveC

let UserFilesUploadsDirectoryName = "uploads"

class SefiViewController: UIViewController{

    @IBOutlet weak var sefiImageView: UIImageView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var imageUploadProgress: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!

    // Here we want to load the file to the private/user-id/source/
    var prefix: String! = "\(UserFilesUploadsDirectoryName)/"

    fileprivate var manager: AWSUserFileManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        manager = AWSUserFileManager.defaultUserFileManager()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }

    // MARK: select Image from Library
    @IBAction func selectImageFromLibrary(_ sender: UITapGestureRecognizer) {
        showImagePicker()
    }

    fileprivate func showImagePicker() {
        let imagePickerController: UIImagePickerController = UIImagePickerController()
        imagePickerController.mediaTypes =  [kUTTypeImage as String, kUTTypeMovie as String]
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }

    // MARK: Upload an Image
    @IBAction func uploadButtonTabbed(_ sender: UIButton) {
        guard let image = sefiImageView.image else {return}
        self.askForImagename(UIImagePNGRepresentation(image)!)
    }

    fileprivate func askForImagename(_ data: Data) {
        let alertController = UIAlertController(title: "File Name", message: "Please specify the image name.", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        let doneAction = UIAlertAction(title: "Done", style: .default) {[unowned self] (action: UIAlertAction) in
            let specifiedKey = alertController.textFields!.first!.text!
            if specifiedKey.characters.count == 0 {
                self.showSimpleAlertWithTitle("Error", message: "The file name cannot be empty.", cancelButtonTitle: "OK")
                return
            } else {
                let key: String = "\(self.prefix!)\(specifiedKey)"
                print(key)
                print(data)
                self.uploadWithData(data, forKey: key)
            }
        }
        alertController.addAction(doneAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    // Upload the files
    fileprivate func uploadWithData(_ data: Data, forKey key: String) {
        let localContent = manager.localContent(with: data, key: key)
        uploadLocalContent(localContent)
    }

    fileprivate func uploadLocalContent(_ localContent: AWSLocalContent) {
        localContent.uploadWithPin(onCompletion: false, progressBlock: {[weak self] (content: AWSLocalContent, progress: Progress) in
                guard self != nil else { return }
            }, completionHandler: {[weak self] (content: AWSLocalContent?, error: Error?) in
                guard let strongSelf = self else { return }
                if let error = error {
                    print("Failed to upload an object. \(error)")
                    strongSelf.showSimpleAlertWithTitle("Error", message: "Failed to upload an object.", cancelButtonTitle: "OK")
                }
        })
    }
}

extension SefiViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]){

        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        // Handle image uploads
        if mediaType.isEqual(to: kUTTypeImage as String) {
        }

        if let image = (info[UIImagePickerControllerOriginalImage] as? UIImage){
            sefiImageView.image = image
        }

        dismiss(animated:true, completion: nil)
    }

}

extension SefiViewController {
    fileprivate func showSimpleAlertWithTitle(_ title: String, message: String, cancelButtonTitle cancelTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}
