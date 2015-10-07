//
//  LinkLabel.swift
//  MTLLinkLabel
//
//  Created by HiraiKokoro on 2015/10/06.
//  Copyright © 2015年 HiraiKokoro. All rights reserved.
//

import UIKit

public typealias LinkSelection = (NSURL) -> Void

public protocol LinkLabelDelegate: NSObjectProtocol {
    
    func linkAttributeForLinkLabel(linkLabel: LinkLabel, checkingType: NSTextCheckingType) -> [String: AnyObject]
    
    func linkLabelExecuteLink(linkLabel: LinkLabel, text: String, result: NSTextCheckingResult) -> Void
    
    func linkLabelCheckingLinkType() -> NSTextCheckingTypes
}

public extension LinkLabelDelegate {
    
    func linkLabelExecuteLink(linkLabel: LinkLabel, var text: String, result: NSTextCheckingResult) -> Void {
        
        if result.resultType.contains(.Link) {
            
            let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]+"
            if NSPredicate(format: "SELF MATCHES '\(pattern)'").evaluateWithObject(text) {
                UIApplication.sharedApplication().openURL(NSURL(string: "mailto:" + text)!)
                return
            }
            
            if !text.hasPrefix("http://") && !text.hasPrefix("https://") {
                text = "http://" + text
            }
            guard let url = NSURL(string: text) else { return }
            UIApplication.sharedApplication().openURL(url)
            
        }
        else if result.resultType.contains(.PhoneNumber) {
            let telURLString = "tel:" + text
            UIApplication.sharedApplication().openURL(NSURL(string: telURLString)!)
        }
    }
    
    func linkAttributeForLinkLabel(linkLabel: LinkLabel, checkingType: NSTextCheckingType) -> [String: AnyObject] {
        return [
            NSForegroundColorAttributeName: linkLabel.tintColor,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
        ]
    }
    
    func linkLabelCheckingLinkType() -> NSTextCheckingTypes {
        return NSTextCheckingType.Link.rawValue
            | NSTextCheckingType.PhoneNumber.rawValue
    }
}

public class LinkLabel: UILabel {
    
    public weak var delegate: LinkLabelDelegate?
    
    override public var text: String? {
        didSet {
            guard let str = text else {
                super.attributedText = nil
                return
            }
            let mAttributedString = NSMutableAttributedString(string: str)
            if let text = self.text {
                if text.characters.count > 0 {
                    mAttributedString.addAttribute(
                    NSFontAttributeName,
                        value: self.font,
                        range: NSMakeRange(0, text.characters.count)
                    )
                }
            }
            
            super.text = nil
            self.attributedText = mAttributedString
        }
    }
    
    override public var attributedText: NSAttributedString? {
        didSet {
            self.reloadAttributedString()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self.dummyDelegate
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self.dummyDelegate
    }
    
    // MARK: - Add custome link
    
    public func addLink(url: NSURL, range: NSRange, linkColor: UIColor? = nil, selection: LinkSelection?) -> LinkLabel {
        self.customLinks.append(CustomLink(url: url, range: range, linkColor: linkColor ?? self.tintColor ?? UIColor.blackColor(), selection: selection))
        self.reloadAttributedString()
        return self
    }
    
    public func removeLink(url: NSURL, range: NSRange) -> LinkLabel {
        self.customLinks = self.customLinks.filter{!($0.url.path == url.path && $0.range.location == range.location && $0.range.length == range.length)}
        self.reloadAttributedString()
        return self
    }
    
    // MARK: - touch
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let location = touches.first?.locationInView(self) else { return }
        guard let textContainer = self.textView?.textContainer else { return }
        let index = layoutManager.glyphIndexForPoint(location, inTextContainer: textContainer)
        
        self.searchCustomeLink(index, inCustomeLinks: self.customLinks) { (linkOrNil) -> Void in
            
            if let link = linkOrNil {
                let mAttributedString = NSMutableAttributedString(attributedString: self.attributedText!)
                mAttributedString.addAttribute(NSBackgroundColorAttributeName, value: UIColor(white: 0.0, alpha: 0.1), range: link.range)
                self.attributedText = mAttributedString
                return
            }
            
            self.searchResult(index, inResults: self.lastCheckingResults) { (resultOrNil) -> Void in
                
                guard let result = resultOrNil else {
                    return
                }
                
                let mAttributedString = NSMutableAttributedString(attributedString: self.attributedText!)
                mAttributedString.addAttribute(NSBackgroundColorAttributeName, value: UIColor(white: 0.0, alpha: 0.1), range: result.range)
                self.attributedText = mAttributedString
            }
        }
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let location = touches.first?.locationInView(self) else { return }
        guard let textContainer = self.textView?.textContainer else { return }
        let index = layoutManager.glyphIndexForPoint(location, inTextContainer: textContainer)
        
        self.searchCustomeLink(index, inCustomeLinks: self.customLinks) { (linkOrNil) -> Void in
            if let link = linkOrNil {
                link.selection?(link.url)
                return
            }
            
            self.searchResult(index, inResults: self.lastCheckingResults) { (resultOrNil) -> Void in
                
                guard let result = resultOrNil else {
                    return
                }
                
                self.delegate?.linkLabelExecuteLink(
                    self,
                    text: (self.attributedText!.string as NSString).substringWithRange(result.range),
                    result: result
                )
            }
        }
        
        if let count = self.attributedText?.string.characters.count {
            if count > 0 {
                let mAttributedString = NSMutableAttributedString(attributedString: self.attributedText!)
                mAttributedString.removeAttribute(NSBackgroundColorAttributeName, range: NSMakeRange(0, count))
                self.attributedText = mAttributedString
            }
        }
    }
    
    override public func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        
        if let count = self.attributedText?.string.characters.count {
            if count > 0 {
                let mAttributedString = NSMutableAttributedString(attributedString: self.attributedText!)
                mAttributedString.removeAttribute(NSBackgroundColorAttributeName, range: NSMakeRange(0, count))
                self.attributedText = mAttributedString
            }
        }
    }
    
    // MARK: - Private
    
    private class DelegateObject: NSObject, LinkLabelDelegate {}
    
    private struct CustomLink {
        let url: NSURL
        let range: NSRange
        let linkColor: UIColor
        let selection: LinkSelection?
    }
    
    private var textStorage: NSTextStorage?
    private let layoutManager = NSLayoutManager()
    private var textView: UITextView?
    private var lastCheckingResults = [NSTextCheckingResult]()
    private var customLinks = [CustomLink]()
    private let dummyDelegate = DelegateObject()
    
    private func reloadAttributedString() {
        self.lastCheckingResults = self.searchLink(attributedText?.string ?? "")
        
        super.attributedText = self.makeAttrbutedStringForCheckingResults(
            self.lastCheckingResults,
            attributedStringOrNil: self.mekeAttributeStringForCustomLink(
                self.customLinks,
                attributedStringOrNil: self.attributedText
            )
        )
        
        self.textStorage?.removeLayoutManager(self.layoutManager)
        if let attributedString = self.attributedText {
            self.textStorage = NSTextStorage(attributedString: attributedString)
        }
        else {
            self.textStorage = nil
        }
        self.textStorage?.addLayoutManager(self.layoutManager)
        
        self.textView = self.makeTextView()
        self.layoutManager.addTextContainer(self.textView!.textContainer)
    }
    
    private func searchLink(string: String) -> [NSTextCheckingResult] {
        
        guard let linkType = self.delegate?.linkLabelCheckingLinkType() else { return [] }
        guard let dataDetector = try? NSDataDetector(types: linkType) else { return [] }
        
        return dataDetector.matchesInString(string, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, string.characters.count))
    }
    
    private func searchResult(index: Int, inResults: [NSTextCheckingResult], completion: (NSTextCheckingResult?) -> Void) {
        for result in inResults {
            if result.range.location <= index && result.range.location + result.range.length > index {
                completion(result)
                return
            }
        }
        completion(nil)
    }
    
    private func searchCustomeLink(index: Int, inCustomeLinks: [CustomLink], completion: (CustomLink?) -> Void) {
        for result in inCustomeLinks {
            if result.range.location <= index && result.range.location + result.range.length > index {
                completion(result)
                return
            }
        }
        completion(nil)
    }
    
    private func mekeAttributeStringForCustomLink(customLinks: [LinkLabel.CustomLink], attributedStringOrNil: NSAttributedString?) -> NSAttributedString? {
        
        return self.mekeAttributeStringA(attributedStringOrNil, objects: customLinks, f: {(customLink) -> ([String: AnyObject], NSRange) in
            return (
                [NSForegroundColorAttributeName: customLink.linkColor],
                customLink.range
            )
        })
    }
    
    private func makeAttrbutedStringForCheckingResults(checkingResults: [NSTextCheckingResult], attributedStringOrNil: NSAttributedString?) -> NSAttributedString? {
        
        return self.mekeAttributeStringA(attributedStringOrNil, objects: checkingResults, f: {(result) -> ([String: AnyObject], NSRange) in
            return (
                self.delegate?.linkAttributeForLinkLabel(
                    self,
                    checkingType: result.resultType
                ) ?? [String: AnyObject](),
                result.range
            )
        })
    }
    
    private func mekeAttributeStringA<T>(attributedStringOrNil: NSAttributedString?, objects: [T], f: T -> ([String: AnyObject], NSRange)) -> NSAttributedString? {
        
        guard let attributedString = attributedStringOrNil else { return nil }
        guard let first = objects.first else { return attributedString }
        
        let mAttributeString = NSMutableAttributedString(attributedString: attributedString)
        let t = f(first)
        mAttributeString.addAttributes(t.0, range: t.1)
        
        return self.mekeAttributeStringA(
            mAttributeString,
            objects: {() -> [T] in
                var cr = objects
                cr.removeFirst()
                return cr
            }(),
            f: f
        )
    }
    
    private func makeTextView() -> UITextView {
        let textView = self.textView ?? UITextView(frame: self.bounds, textContainer: NSTextContainer(size: self.frame.size))
        textView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        textView.userInteractionEnabled = false
        textView.font = self.font
        textView.textContainer.lineFragmentPadding = 0.0
        textView.textContainerInset = UIEdgeInsetsZero
        textView.hidden = true
        self.addSubview(textView)
        return textView
    }
}
