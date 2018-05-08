//
//  StatisticViewController.swift
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

class StatisticViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var statisticTable: UITableView!

    var prefix: String!
    var nextContent: AWSContent? = nil

    fileprivate var contents: [AWSContent]?
    fileprivate var didLoadAllContents: Bool!
    fileprivate var dateFormatter: DateFormatter!
    fileprivate var marker: String?
    fileprivate var manager: AWSUserFileManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tabbar = tabBarController as! BaseTabBarController
        nextContent = tabbar.nextContent
        prefix = nextContent?.key as Any as! String + "statistic/"
        print("print the prefix: \(prefix)")

        statisticTable.delegate = self
        statisticTable.dataSource = self

        // Sets up the date formatter.
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale.current

        statisticTable.estimatedRowHeight = statisticTable.rowHeight
        statisticTable.rowHeight = UITableViewAutomaticDimension
        didLoadAllContents = false
        manager = AWSUserFileManager.defaultUserFileManager()

        contents = []

        self.refreshContents()
        self.updateUserInterface()
        self.loadMoreContents()

    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let contents = self.contents {
            return contents.count
        }
        return 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "statisticCell")
        var content: AWSContent? = nil
        if indexPath.row < contents!.count {
            content = contents![indexPath.row]
        }
        var foldername = content!.key.components(separatedBy: "/")
        cell.textLabel?.text = foldername[4]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "clickOnCsv", sender: contents![indexPath.row])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextPage = segue.destination as! SecondStatisticViewController
        nextPage.nextContent = (sender as! AWSContent)
    }

    fileprivate func refreshContents() {
        marker = nil
        loadMoreContents()
    }

    fileprivate func loadMoreContents() {

        manager.listAvailableContents(withPrefix: prefix, marker: marker) {[weak self] (contents: [AWSContent]?, nextMarker: String?, error: Error?) in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.showSimpleAlertWithTitle("Error", message: "Failed to load the list of contents.", cancelButtonTitle: "OK")
                print("Failed to load the list of contents. \(error)")
            }
            if let contents = contents, contents.count > 0 {
                print("The contents of file !!!!!: \(contents)")
                strongSelf.contents = contents
                if let nextMarker = nextMarker, !nextMarker.isEmpty {
                    strongSelf.didLoadAllContents = false
                } else {
                    strongSelf.didLoadAllContents = true
                }
                strongSelf.marker = nextMarker
            } else {
                print("No group find down in this user, please create a new group")
            }
            strongSelf.updateUserInterface()
        }
    }


    fileprivate func updateUserInterface() {
        DispatchQueue.main.async {
            self.statisticTable.reloadData()
        }
    }

    @IBAction func clickUpdatae(_ sender: UIBarButtonItem) {
        self.refreshContents()
        self.updateUserInterface()
        self.loadMoreContents()
    }
}


extension StatisticViewController {

    fileprivate func showSimpleAlertWithTitle(_ title: String, message: String, cancelButtonTitle cancelTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

}
