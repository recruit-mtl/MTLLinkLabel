# MTLLinkLabel 

[![Badge w/ Version](https://cocoapod-badges.herokuapp.com/v/MTLLinkLabel/badge.png)](https://cocoadocs.org/docsets/MTLLinkLabel) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

MTLLinkLabel is linkable UILabel

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

  pod 'MTLLinkLabel', '~> 0.1.5'

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



## Licence

[MIT](https://github.com/recruit-mtl/MTLLinkLabel/blob/master/LICENSE)

## Author

[kokoron](https://github.com/kokoron)