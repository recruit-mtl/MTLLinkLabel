#<img src="https://s3-ap-northeast-1.amazonaws.com/mtl-link-label/mtl_link_label.png" width="850" alt="MTLLinkLabel" />

[![Badge w/ Version](https://cocoapod-badges.herokuapp.com/v/MTLLinkLabel/badge.png)](https://cocoadocs.org/docsets/MTLLinkLabel) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)

<img src="https://s3-ap-northeast-1.amazonaws.com/mtl-link-label/example.gif" width="186" height="333" />

MTLLinkLabel is linkable UILabel. Written in Swift.

## Requirements

- iOS 8.0+
- Xcode 7.3+

## Installation

### [Carthage](https://github.com/Carthage/Carthage)

You can install Carthage with Homebrew.

```bash
$ brew update
$ brew install carthage
```
specify it in your `Cartfile`

`github "recruit-mtl/MTLLinkLabel"`

And run `carthage`

```bash
$ carthage update --platform ios
```

### [CocoaPods](https://cocoapods.org)

```bash
$ pod init
```

specify it in your `Podfile`

```ruby
platform :ios, '8.0'

target 'MTLLinkLabelExample' do

  use_frameworks!

  pod 'MTLLinkLabel', '~> 0.1.6'

end
```

And run `CocoaPods`

```bash
$ pod install
```

## Usage

You can use MTLLinkLabel in Storyboard or XIB. 

#####Drag and drop UILabel in your view.

<img src="https://s3-ap-northeast-1.amazonaws.com/mtl-link-label/ib1.png" width="258">

#####Change UILabels custom class to 'LinkLabel', and Change module to 'MTLLinkLabel'.

<img src="https://s3-ap-northeast-1.amazonaws.com/mtl-link-label/ib2.png" width="259">

You must change labels userInteractionEnabled property to true. Because, this labels properties default value is false.

<img src="https://s3-ap-northeast-1.amazonaws.com/mtl-link-label/ib3.png" width="239">

```swift
label.userInteractionEnabled = true
```

#####Assign String to LinkLabels 'text' property.

```swift
label.text = "Hello. https://github.com/recruit-mtl/MTLLinkLabel"
```

> Hello. [https://github.com/recruit-mtl/MTLLinkLabel](https://github.com/recruit-mtl/MTLLinkLabel)

--

### Add custom link

You can add custom link in LinkLabel with range and Action at the time of the link selection. 

```swift
let range = (text as NSString).rangeOfString("1829")
        
cell.label.addLink(
	NSURL(string: "https://www.google.co.jp/#q=1829")!, 
	range: range, 
	linkAttribute: [
		NSForegroundColorAttributeName: UIColor.redColor(),
		NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
	]
) { (url) -> Void in
	
	let alert = UIAlertController(title: nil, message: url.absoluteString, preferredStyle: UIAlertControllerStyle.ActionSheet)
	alert.addAction(UIAlertAction(title: "Go", style: .Default, handler: { (action) -> Void in
		UIApplication.sharedApplication().openURL(url)
	}))
	alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
	self.presentViewController(alert, animated: true, completion: nil)
}
```

--

### Delegate

LinkLabelDelegate methods are optional method.

The default implementation is implemented in protocol extension.

```swift
public extension LinkLabelDelegate {
    
    func linkLabelExecuteLink(linkLabel: LinkLabel, text: String, result: NSTextCheckingResult) -> Void {
        
        if result.resultType.contains(.Link) {
            
            let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]+"
            if NSPredicate(format: "SELF MATCHES '\(pattern)'").evaluateWithObject(text) {
                UIApplication.sharedApplication().openURL(NSURL(string: "mailto:" + text)!)
                return
            }
            
            let httpText = !text.hasPrefix("http://") && !text.hasPrefix("https://") ? "http://" + text : text
            
            guard let url = NSURL(string: httpText) else { return }
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
    
    func linkDefaultAttributeForCustomeLink(linkLabel: LinkLabel) -> [String: AnyObject] {
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
```


## Licence

[MIT](https://github.com/recruit-mtl/MTLLinkLabel/blob/master/LICENSE)

## Author
- [kokoron: Twitter](https://twitter.com/kokoron)
- [kokoron: github](https://github.com/kokoron)