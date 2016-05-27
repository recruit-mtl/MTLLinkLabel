//
//  TableViewController.swift
//  MTLLinkLabelExample
//
//  Created by HiraiKokoro on 2015/10/10.
//  Copyright (c) 2016, Recruit Holdings Co., Ltd.
//

import UIKit

class TableViewController: UITableViewController {
    
    private let texts = [
        "The house in which Dr. Johnson was born, at Lichfield—where his father, it is well known, kept a small bookseller’s shop, and where he was partly educated—stood on the west side of the market-place. In the centre of the market-place is a colossal statue of Johnson, seated upon a square pedestal: it is by Lucas, and was executed at the expense of the Rev. Chancellor Law, in 1838. By the side of a footpath leading from Dam-street to Stow, formerly stood a large willow, said to have been planted by Johnson. It was blown down, in 1829; but one of its shoots was preserved and planted upon the same spot: it was in the year 1848 a large tree, known in the town as Johnson’s Willow.",
        "Mr. Lomax, who for many years kept a bookseller’s shop—“The Johnson’s Head,” in Bird-street, Lichfield, possessed several articles that formerly belonged to Johnson, which have been handed down by a clear and indisputable ownership. Amongst them is his own Book of Common Prayer, in which are written, in pencil, the four Latin lines printed in Strahan’s edition of the Doctor’s Prayers. There are, also, a sacrament-book, with Johnson’s wife’s name in it, in his own handwriting; an autograph letter of the Doctor’s to Miss Porter; two tea-spoons, an ivory tablet, and a breakfast table; a Visscher’s Atlas, paged by the Doctor, and a manuscript index; Davies’s Life of Garrick, presented to Johnson by the publisher; a walking cane; and a Dictionary of Heathen Mythology, with the Doctor’s MS. corrections. His wife’s wedding-ring, afterwards made into a mourning-ring; and a massive chair, in which he customarily sat, were also in Mr. Lomax’s possession.",
        "Among the few persons living in the year 1848 who ever saw Dr. Johnson, was Mr. Dyott, of Lichfield: this was seventy-four years before, or in 1774, when the Doctor and Boswell, on their tour into Wales, stopped at Ashbourne, and there visited Mr. Dyott’s father, who was then residing at Ashbourne Hall.",
        "This text has been taken from http://www.gutenberg.org/files/50156/50156-h/50156-h.htm"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return texts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TableViewCell

        let text = texts[indexPath.row]
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = cell.label.font.pointSize * 1.5
        paragraphStyle.maximumLineHeight = cell.label.font.pointSize * 1.5
        
        cell.label.attributedText = NSAttributedString(string: text, attributes: [
            NSForegroundColorAttributeName: UIColor.darkGrayColor(),
            NSParagraphStyleAttributeName: paragraphStyle
        ])
        
        let range = (text as NSString).rangeOfString("1829")
        
        cell.label.addLink(NSURL(string: "https://www.google.co.jp/#q=1829")!, range: range, linkAttribute: [
            NSForegroundColorAttributeName: UIColor.redColor(),
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
        ]) { (url) -> Void in
            let alert = UIAlertController(title: nil, message: url.absoluteString, preferredStyle: UIAlertControllerStyle.ActionSheet)
            alert.addAction(UIAlertAction(title: "Go", style: .Default, handler: { (action) -> Void in
                UIApplication.sharedApplication().openURL(url)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        let range2 = (text as NSString).rangeOfString("Doctor")
        
        cell.label.addLink(NSURL(string: "https://www.google.co.jp/#q=Doctor")!, range: range2, linkAttribute: [
            NSForegroundColorAttributeName: UIColor.redColor(),
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
            ]) { (url) -> Void in
                let alert = UIAlertController(title: nil, message: url.absoluteString, preferredStyle: UIAlertControllerStyle.ActionSheet)
                alert.addAction(UIAlertAction(title: "Go", style: .Default, handler: { (action) -> Void in
                    UIApplication.sharedApplication().openURL(url)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
        }

        return cell
    }

}
