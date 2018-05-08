//
//  ViewController.swift
//  complete-view
//
//  Created by Sunshine on 2018/5/5.
//  Copyright © 2018年 Sunshine. All rights reserved.
//

import Foundation
import UIKit
import AWSAuthCore
import AWSAuthUI
import AWSMobileHubContentManager

let UserFilesPrivateDirectoryName = "private"

class MainController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createGroupButton: UIButton!
    @IBOutlet weak var groupsTableView: UITableView!

    var prefix: String!

    fileprivate var contents: [AWSContent]?
    fileprivate var didLoadAllContents: Bool!
    fileprivate var dateFormatter: DateFormatter!
    fileprivate var marker: String?
    fileprivate var manager: AWSUserFileManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Sets up the date formatter.
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale.current

        groupsTableView.estimatedRowHeight = groupsTableView.rowHeight
        groupsTableView.rowHeight = UITableViewAutomaticDimension
        didLoadAllContents = false
        manager = AWSUserFileManager.defaultUserFileManager()

        contents = []

        if (AWSSignInManager.sharedInstance().isLoggedIn) {
            print("The user is already logged in!")
            let userId = AWSIdentityManager.default().identityId!
            self.prefix = "\(UserFilesPrivateDirectoryName)/\(userId)/"
            self.refreshContents()
            self.updateUserInterface()
            self.loadMoreContents()
        }
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let contents = self.contents {
            return contents.count
        }

        return 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("!!!!!!!Inside TableView")
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "groupCell")
        var content: AWSContent? = nil
        if indexPath.row < contents!.count {
            content = contents![indexPath.row]
        }
        var foldername = content!.key.components(separatedBy: "/")
        cell.textLabel?.text = foldername[2]
        return cell
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
                print("!!!! The content of the file is More than 0")
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
        print("!!!! UpdateUserInterface is called")
        DispatchQueue.main.async {
            self.groupsTableView.reloadData()
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func userLoginTapped(_ sender: UIButton) {
        if (AWSSignInManager.sharedInstance().isLoggedIn) {
            gotoLogout()
            loginButton.setTitle("login", for: .normal)
            loginButton.setImage(UIImage(named: "icon-login"), for: .normal)
        }
    }


    @IBAction func userLogoutTapped(_ sender: UIButton) {
        if !(AWSSignInManager.sharedInstance().isLoggedIn) {
            goToLogin()
            loginButton.setTitle("logout", for: .normal)
            loginButton.setImage(UIImage(named: "icon-logout"), for: .normal)
        }
    }
    func goToLogin() {
        print("Handling optional sign-in.")
        if !AWSSignInManager.sharedInstance().isLoggedIn {
            let config = AWSAuthUIConfiguration()
            config.enableUserPoolsUI = true
            config.canCancel = true
            config.logoImage = UIImage(named: "logo")
            config.backgroundColor = UIColor(red:0.62, green:0.86, blue:0.86, alpha:1.0)

            AWSAuthUIViewController.presentViewController(with: self.navigationController!,
                                                          configuration: config,
                                                          completionHandler: { (provider: AWSSignInProvider, error: Error?) in
                                                            if error != nil {
                                                                print("Error occurred: \(String(describing: error))")
                                                            }
                                                            else {
                                                                let userId = AWSIdentityManager.default().identityId!
                                                                self.prefix = "\(UserFilesPrivateDirectoryName)/\(userId)/"
                                                                print("!!!!!!!")
                                                                print(self.prefix)
                                                                self.refreshContents()
                                                                self.updateUserInterface()
                                                                self.loadMoreContents()
                                                            }
            })
        }
    }

    func gotoLogout() {
        if (AWSSignInManager.sharedInstance().isLoggedIn) {
            AWSSignInManager.sharedInstance().logout(completionHandler: {(result: Any?, error: Error?) in
                self.navigationController!.popToRootViewController(animated: false)
            })
        } else {
            assert(false)
        }
    }


}

extension MainController {

    fileprivate func showSimpleAlertWithTitle(_ title: String, message: String, cancelButtonTitle cancelTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

}

