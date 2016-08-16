//
//  ViewController.swift
//  AlamofireDemo
//
//  Created by zm_iOS on 16/7/5.
//  Copyright © 2016年 zm_iOS. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        request(.GET, "https://www.baidu.com/").responseData { (responce) in
            switch responce.result {
            case .Success(let value):
                NSLog("Success: \(value)")
                
            case .Failure(let error):
                NSLog("Error: \(error)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

