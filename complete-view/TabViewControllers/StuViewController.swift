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

    var content: AWSContent? = nil
    var prefix: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tabbar = tabBarController as! BaseTabBarController
        content = tabbar.content
        print("Student View Controller: content.key is")
        print(content?.key as Any)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
