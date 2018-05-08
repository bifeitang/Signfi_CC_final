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

class StatisticViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {

    var content: AWSContent? = nil
    var prefix: String!

    let s3Bucket = "signfi-statistics-mobilehub"
    let statisiticKey = "Sambit/group1.csv"

    let list = ["Jason", "Peter", "Mary"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(list.count)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.value2, reuseIdentifier: "StudentCell")
        return cell
    }

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {

    }


    @IBOutlet weak var statisticTabelView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let tabbar = tabBarController as! BaseTabBarController
        content = tabbar.content
        print("Student View Controller: content.key is")
        print(content?.key as Any)


        /*let getAttendenceCsv = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("sefi1.csv")

        let transferManager = AWSS3TransferManager.default()

        if let downloadRequest = AWSS3TransferManagerDownloadRequest(){
            downloadRequest.bucket = s3Bucket
            downloadRequest.key = statisiticKey
            downloadRequest.downloadingFileURL = getAttendenceCsv

            transferManager.download(downloadRequest).continueWith(block:
                { (task: AWSTask<AnyObject>) -> Any? in
                if let error = task.error{
                    //fatalError(error.localizedDescription)
                    print(error)
                } else {
                    print(task.result as Any)
                    }
                return nil
            })
        }*/

        /*guard let csvPath = Bundle.main.path(forResource: "fileName", ofType: "csv") else { return }

        do {
            let csvData = try String(contentsOfFile: csvPath, encoding: String.Encoding.utf8)
            let csv = csvData.

            for row in csv {
                print(row)
            }
        } catch{
            print(error)
        }*/

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func readStringFromURL(stringURL:String)-> String!{
        if let url = NSURL(string: stringURL) {
            do {
                return try String(contentsOf: url as URL, encoding: String.Encoding.utf8)
            } catch {
                print("Cannot load contents")
                return nil
            }
        } else {
            print("String was not a URL")
            return nil
        }
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
