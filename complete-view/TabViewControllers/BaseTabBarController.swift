//
//  BaseTabBarController.swift
//  complete-view
//
//  Created by Sunshine on 2018/5/7.
//  Copyright © 2018年 Sunshine. All rights reserved.
//

import UIKit
import AWSS3
import AWSMobileHubContentManager
import MobileCoreServices


class BaseTabBarController: UITabBarController {

    var prefix: String! = ""
    var content: AWSContent? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        print(content?.key as Any)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
