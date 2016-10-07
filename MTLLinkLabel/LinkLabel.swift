//
//  LinkLabel.swift
//  MTLLinkLabel
//
//  Created by HiraiKokoro on 2015/10/06.
//  Copyright (c) 2016, Recruit Holdings Co., Ltd.
//

import UIKit

public typealias LinkSelection = (URL) -> Void

/**
 
 LinkLabels delegate protocol
 
 */
public protocol LinkLabelDelegate: NSObjectProtocol {
    
    /**
     
     It is possible to specify the Attribute for NSTextCheckingType
     
     - Parameter:
        - linkLabel:    Target LinkLabel
        - checkingType: NSTextCheckingType
     
     - Returns: NSAttributedStrings attribute object
     
    */
    func linkAttributeForLinkLabel(_ linkLabel: LinkLabel, checkingType: NSTextCheckingResult.CheckingType) -> [String: AnyObject]
    
    /**
     
     It is possible to specify the Attribute for custome links
     
     - Parameter:
        - linkLabel:    Target LinkLabel
     
     - Returns: NSAttributedStrings attribute object
     
     */
    func linkDefaultAttributeForCustomeLink(_ linkLabel: LinkLabel) -> [String: AnyObject]
    
    /**
     
     It is possible to specify the Action for text and NSTextCheckingResult
     
     - Parameter:
        - linkLabel:    Target LinkLabel
        - text:         Target text
        - result:       Target NSTextCheckingResult
     
     */
    func linkLabelExecuteLink(_ linkLabel: LinkLabel, text: String, result: NSTextCheckingResult) -> Void
    
    /**
     
     It is possible to specify the allowed NSTextCheckingTypes
     
     - Returns: NSTextCheckingTypes
     
     */
    func linkLabelCheckingLinkType() -> NSTextCheckingTypes
    
}

public extension LinkLabelDelegate {
    
    func linkLabelExecuteLink(_ linkLabel: LinkLabel, text: String, result: NSTextCheckingResult) -> Void {
        
        if result.resultType.contains(.link) {
            
            let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]+"
            if NSPredicate(format: "SELF MATCHES '\(pattern)'").evaluate(with: text) {
                UIApplication.shared.openURL(URL(string: "mailto:" + text)!)
                return
            }
            
            let httpText = !text.hasPrefix("http://") && !text.hasPrefix("https://") ? "http://" + text : text
            
            guard let url = URL(string: httpText) else { return }
            UIApplication.shared.openURL(url)
            
        }
        else if result.resultType.contains(.phoneNumber) {
            let telURLString = "tel:" + text
            UIApplication.shared.openURL(URL(string: telURLString)!)
        }
    }
    
    func linkAttributeForLinkLabel(_ linkLabel: LinkLabel, checkingType: NSTextCheckingResult.CheckingType) -> [String: AnyObject] {
        return [
            NSForegroundColorAttributeName: linkLabel.tintColor,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue as AnyObject
        ]
    }
    
    func linkDefaultAttributeForCustomeLink(_ linkLabel: LinkLabel) -> [String: AnyObject] {
        return [
            NSForegroundColorAttributeName: linkLabel.tintColor,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue as AnyObject
        ]
    }
    
    func linkLabelCheckingLinkType() -> NSTextCheckingTypes {
        return NSTextCheckingResult.CheckingType.link.rawValue
            | NSTextCheckingResult.CheckingType.phoneNumber.rawValue
    }
}

open class LinkLabel: UILabel {
    
    /// link labels delegate
    open weak var delegate: LinkLabelDelegate?
    
    /// Text for this label
    override open var text: String? {
        didSet {
            
            guard let str = text else {
                super.attributedText = nil
                self.customLinks.removeAll()
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
    
    /// Attributed text for this label
    override open var attributedText: NSAttributedString? {
        didSet {
            self.customLinks.removeAll()
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
    
    /**
     
     Add link in this label
     
     - Parameter:
        - url:              URL
        - range:            Range of link
        - linkAttribute:    NSAttributedStrings attribute object for link
        - selection:        Action at the time of the link selection
     
     - Returns: this LinkLabel
     
     */
    open func addLink(_ url: URL, range: NSRange, linkAttribute: [String: AnyObject]? = nil, selection: LinkSelection?) -> LinkLabel {
        self.customLinks.append(
            CustomLink(
                url: url,
                range: range,
                linkAttribute: linkAttribute ?? self.delegate?.linkDefaultAttributeForCustomeLink(self) ?? [String: AnyObject](),
                selection: selection
            )
        )
        self.reloadAttributedString()
        return self
    }
    
    /**
     
     Remove link in this label
     
     - Parameter:
        - url:              URL
        - range:            Range of link
     
     - Returns: this LinkLabel
     
     */
    open func removeLink(_ url: URL, range: NSRange) -> LinkLabel {
        self.customLinks = self.customLinks.filter{!($0.url.path == url.path && $0.range.location == range.location && $0.range.length == range.length)}
        self.reloadAttributedString()
        return self
    }
    
    // MARK: - touch
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        guard let textContainer = self.textView?.textContainer else { return }
        
        self.textView?.textContainer.size = self.textView!.frame.size
        
        let index = layoutManager.glyphIndex(for: location, in: textContainer)
        
        self.searchCustomeLink(index, inCustomeLinks: self.customLinks) { (linkOrNil) -> Void in
            
            if let link = linkOrNil {
                let mAttributedString = NSMutableAttributedString(attributedString: self.attributedText!)
                mAttributedString.addAttribute(NSBackgroundColorAttributeName, value: UIColor(white: 0.0, alpha: 0.1), range: link.range)
                super.attributedText = mAttributedString
                return
            }
            
            self.searchResult(index, inResults: self.lastCheckingResults) { (resultOrNil) -> Void in
                
                guard let result = resultOrNil else { return }
                
                let mAttributedString = NSMutableAttributedString(attributedString: self.attributedText!)
                mAttributedString.addAttribute(NSBackgroundColorAttributeName, value: UIColor(white: 0.0, alpha: 0.1), range: result.range)
                super.attributedText = mAttributedString
            }
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        guard let textContainer = self.textView?.textContainer else { return }
        
        self.textView?.textContainer.size = self.textView!.frame.size
        
        let index = layoutManager.glyphIndex(for: location, in: textContainer)

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
                    text: (self.attributedText!.string as NSString).substring(with: result.range),
                    result: result
                )
            }
        }
        
        // NSAttributedStrings range length is NSStrings lenhgth. I can't use "Swift.String.charactors.count".
        let count = ((self.attributedText?.string ?? "") as NSString).length

        if count > 0 {
            let mAttributedString = NSMutableAttributedString(attributedString: self.attributedText!)
            mAttributedString.removeAttribute(NSBackgroundColorAttributeName, range: NSMakeRange(0, count))
            super.attributedText = mAttributedString
        }
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let count = self.attributedText?.string.characters.count {
            if count > 0 {
                let mAttributedString = NSMutableAttributedString(attributedString: self.attributedText!)
                mAttributedString.removeAttribute(NSBackgroundColorAttributeName, range: NSMakeRange(0, count))
                super.attributedText = mAttributedString
            }
        }
    }
    
    // MARK: - Private
    
    fileprivate class DelegateObject: NSObject, LinkLabelDelegate {}
    
    fileprivate struct CustomLink {
        let url: URL
        let range: NSRange
        let linkAttribute: [String: AnyObject]
        let selection: LinkSelection?
    }
    
    fileprivate var textStorage: NSTextStorage?
    fileprivate let layoutManager = NSLayoutManager()
    fileprivate var textView: UITextView?
    fileprivate var lastCheckingResults = [NSTextCheckingResult]()
    fileprivate var customLinks = [CustomLink]()
    fileprivate let dummyDelegate = DelegateObject()
    
    fileprivate func reloadAttributedString() {
        self.lastCheckingResults = self.searchLink(attributedText?.string ?? "")
        
        let a = self.makeAttrbutedStringForCheckingResults(
            self.lastCheckingResults,
            attributedStringOrNil: self.mekeAttributeStringForCustomLink(
                self.customLinks,
                attributedStringOrNil: self.attributedText
            )
        )
        
        super.attributedText = a
        
        self.textStorage?.removeLayoutManager(self.layoutManager)
        if let attributedString = self.attributedText {
            let ma = NSMutableAttributedString(attributedString: attributedString)
            
            ma.addAttribute(NSFontAttributeName, value: self.font, range: NSMakeRange(0, (ma.string as NSString).length))
            self.textStorage = NSTextStorage(attributedString: ma)
        }
        else {
            self.textStorage = nil
        }
        self.textStorage?.addLayoutManager(self.layoutManager)
        
        self.textView = self.makeTextView()
        self.layoutManager.addTextContainer(self.textView!.textContainer)
    }
    
    fileprivate func searchLink(_ string: String) -> [NSTextCheckingResult] {
        
        guard let linkType = self.delegate?.linkLabelCheckingLinkType() else { return [] }
        guard let dataDetector = try? NSDataDetector(types: linkType) else { return [] }
        
        return dataDetector.matches(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, (string as NSString).length))
    }
    
    fileprivate func searchResult(_ index: Int, inResults: [NSTextCheckingResult], completion: (NSTextCheckingResult?) -> Void) {
        for result in inResults {
            if result.range.location <= index && result.range.location + result.range.length > index {
                completion(result)
                return
            }
        }
        completion(nil)
    }
    
    fileprivate func searchCustomeLink(_ index: Int, inCustomeLinks: [CustomLink], completion: (CustomLink?) -> Void) {
        for result in inCustomeLinks {
            if result.range.location <= index && result.range.location + result.range.length > index {
                completion(result)
                return
            }
        }
        completion(nil)
    }
    
    fileprivate func mekeAttributeStringForCustomLink(_ customLinks: [LinkLabel.CustomLink], attributedStringOrNil: NSAttributedString?) -> NSAttributedString? {
        
        return self.mekeAttributeStringA(attributedStringOrNil, objects: customLinks, f: {(customLink) -> ([String: AnyObject], NSRange) in
            return (
                customLink.linkAttribute,
                customLink.range
            )
        })
    }
    
    fileprivate func makeAttrbutedStringForCheckingResults(_ checkingResults: [NSTextCheckingResult], attributedStringOrNil: NSAttributedString?) -> NSAttributedString? {
        
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
    
    fileprivate func mekeAttributeStringA<T>(_ attributedStringOrNil: NSAttributedString?, objects: [T], f: (T) -> ([String: AnyObject], NSRange)) -> NSAttributedString? {
        
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
    
    fileprivate func makeTextView() -> UITextView {
        let textView = self.textView ?? UITextView(frame: self.bounds, textContainer: NSTextContainer(size: self.frame.size))
        textView.isEditable = true
        textView.isSelectable = true
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        textView.font = self.font
        textView.textContainer.lineBreakMode = self.lineBreakMode
        textView.textContainer.lineFragmentPadding = 0.0
        textView.textContainerInset = UIEdgeInsets.zero
        textView.isUserInteractionEnabled = false
        textView.isHidden = true
        self.addSubview(textView)
        return textView
    }
}
