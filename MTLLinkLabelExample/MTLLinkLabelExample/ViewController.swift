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
        
        self.linkLabel.text = "Hello, world! http://google.com こんにちは！ \n😀 Link for Apple"
        
        self.linkLabel.addLink(NSURL(string: "http://apple.com")!, range: (self.linkLabel.text! as NSString).rangeOfString("Link for Apple")) { (url) -> Void in
            
            let alert = UIAlertController(title: nil, message: url.path, preferredStyle: UIAlertControllerStyle.ActionSheet)
            alert.addAction(UIAlertAction(title: "Go", style: .Default, handler: { (action) -> Void in
                UIApplication.sharedApplication().openURL(url)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

