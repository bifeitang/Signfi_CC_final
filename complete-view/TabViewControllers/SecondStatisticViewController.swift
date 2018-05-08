//
//  SecondStatisticViewController.swift
//  complete-view
//
//  Created by Sunshine on 2018/5/8.
//  Copyright © 2018年 Sunshine. All rights reserved.
//

import Foundation
import UIKit
import AWSS3
import AWSAuthCore
import AWSAuthUI
import AWSMobileHubContentManager

class SecondStatisticViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var csvFileNmae: UILabel!
    @IBOutlet weak var studentStatisticTableView: UITableView!

    var prefix: String!
    var downloadFileName: String!
    var downloadCsv: String!
    var nextContent: AWSContent? = nil
    var dictStudents = [String:String]()
    var arrayStudents = NSMutableArray()

    fileprivate var manager: AWSUserFileManager!
    fileprivate var contents: [AWSContent]?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        manager = AWSUserFileManager.defaultUserFileManager()

        print("??? The key of final csv file is \(nextContent?.key as Any)")
        prefix = nextContent?.key

        var filename = prefix.components(separatedBy: "/")
        csvFileNmae.text = filename[4]
        downloadFileName = filename[4]

        self.downloadContent(content: self.nextContent!, pinOnCompletion: true)

        if self.downloadCsv != nil {
            //let readings = fullText.componentsSeparatedByString("\n") as [String]
            let readings = self.downloadCsv.components(separatedBy: "\n") as [String]

            //componentsSeparatedByString("\n") as [String]
            for i in 1..<readings.count {
                print(readings[i])
                let clientData = readings[i].components(separatedBy: "\r")
                print(clientData)
                dictStudents["Name"] = "\(clientData[0])"
                dictStudents["Present"] = "\(clientData[1])"
                arrayStudents.add(dictStudents)
            }

            print("\n\n get array students: \(arrayStudents)")
        }

        // Download the csv file which will be reffered later in this example
    }

    func downloadContent(content: AWSContent, pinOnCompletion: Bool) -> Void {
        nextContent?.download( with: .always, pinOnCompletion: pinOnCompletion, progressBlock: {(content: AWSContent?, progress: Progress?) -> Void in
            // Handle progress feedback
            print("The file is downloading")
        }, completionHandler: {(content: AWSContent?, data: Data?, error: Error?) -> Void in
            if let error = error {
                print("Failed to download a content from a server.\(error)")
                // Handle error here
                return
            }
                // Handle successful download here
                print("\n\n !!!! Suppose to get new data here ")
                if let csv = String(data: data!, encoding: .utf8){
                    print("\n\n get the downloadcsv here \(self.downloadCsv) \n\n ")
                    self.downloadCsv = csv
                }
                print("\n\n get the downloadcsv here \(self.downloadCsv) \n\n ")
        } )
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayStudents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "studentCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? StudentPresenceTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }

        let student = arrayStudents[indexPath.row]
        cell.studentName.text = "\((student as AnyObject).object(forKey:"Name")!)"
        let isPresent = "\((student as AnyObject).object(forKey:"Present")!)"
        if isPresent == "0" {
            cell.imageView?.image = UIImage(named: "icon-cross")
        } else {
            cell.imageView?.image = UIImage(named: "icon-check")
        }

        return cell
    }
}


extension SecondStatisticViewController {

    fileprivate func showSimpleAlertWithTitle(_ title: String, message: String, cancelButtonTitle cancelTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

}
