//
//  ViewController.swift
//  MTLLinkLabelExample
//
//  Created by HiraiKokoro on 2015/10/07.
//  Copyright © 2015年 MTL. All rights reserved.
//

import UIKit
import MTLLinkLabel

class ViewController: UIViewController, LinkLabelDelegate {
    
    @IBOutlet private var linkLabel: LinkLabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.linkLabel.delegate = self
        self.linkLabel.text = "Hello, world! http://google.com こんにちは！ \n😀 09097043483 kokoro@enw.jp"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

