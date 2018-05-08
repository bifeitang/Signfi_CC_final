//
//  StuViewController.swift
//  complete-view
//
//  Created by Sunshine on 2018/5/7.
//  Copyright © 2018年 Sunshine. All rights reserved.
//

import UIKit
import AWSS3
import AWSMobileHubContentManager
import MobileCoreServices

class StuViewController: UIViewController {

    var nextcontent: AWSContent? = nil
    var prefix: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tabbar = tabBarController as! BaseTabBarController
        nextcontent = tabbar.nextContent
        print("Student View Controller: content.key is")
        print(nextcontent?.key as Any)

        // Do any additional setup after loading the view.
    }

}
