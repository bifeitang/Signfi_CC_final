//
//  StatisticViewController.swift
//  complete-view
//
//  Created by Sunshine on 2018/5/6.
//  Copyright © 2018年 Sunshine. All rights reserved.
//

import UIKit
import AWSS3
import AWSMobileHubContentManager
import MobileCoreServices

class StatisticViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var content: AWSContent? = nil
    var prefix: String!

    var dictClients = [String:String]()
    var arrayClients = NSMutableArray()



    @IBOutlet weak var statisticTabelView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let tabbar = tabBarController as! BaseTabBarController
        content = tabbar.content
        print("Student View Controller: content.key is")
        print(content?.key as Any)

        statisticTabelView.delegate = self
        statisticTabelView.dataSource = self

        let path = Bundle.main.path(forResource: "clients", ofType: "txt")
        let filemgr = FileManager.default
        if filemgr.fileExists(atPath:path!){
            do{
                let fullText = try String(contentsOfFile: path!,encoding:String.Encoding.utf8)

                //let readings = fullText.componentsSeparatedByString("\n") as [String]
                let readings = fullText.components(separatedBy: "\n") as [String]

                //componentsSeparatedByString("\n") as [String]
                for i in 1..<readings.count {
                    print(readings[i])
                    let clientData = readings[i].components(separatedBy: "\t")
                    print(clientData)
                    dictClients["Name"] = "\(clientData[0])"
                    dictClients["Present"] = "\(clientData[1])"
                    arrayClients.add(dictClients)//addObjects(dictClients)
                }

            }catch let error as NSError{
                print("Error: \(error)")
            }
        }

        self.title = "number of students:\(arrayClients.count)"

        

    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arrayClients.count
    }


    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "StudentCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? customStudentCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }

        let client = arrayClients[indexPath.row]
        cell.studentName.text = "\((client as AnyObject).object(forKey:"Name")!)"
        let present = "\((client as AnyObject).object(forKey:"Present")!)"
        if(present == "0") {
            cell.imageStatus.image = UIImage(named: "icon-check")
        } else {
            cell.imageStatus.image = UIImage(named: "icon-cross")
        }


        return cell
    }

    class myCell: UITableViewCell {
        @IBOutlet weak var studentName: UIImageView!

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
