# XChange

> One day Swift project that uses currency exchange API and lets to select and see/persist exchange rates. 

## Features
- Exchange rate application utilizing REST API, with available currency and amount custom inputs.
- Simple localization examples (app UI doesnt have much text to work with). 
- Uses Realm object oriented local persistence storage.
- Quick and responsive UI. Most potential UX issues are addressed
- Dark mode support ^^ (Who doesnt like dark mode?)
- Used Libraries list with licenses is in Settings (iOS)
- Unit tests for public methods and features

## Technical specifications
Used tech for development
- [Swift] - app programming language
- [Xcode] - Version 12.4 (12D4e)
- [CocoaPods] - in order to use handy libraries
- [RealmSwift] - local object oriented persistence storage
- [RxSwift] - reactive extensions for Swift

Also there is a possibility to use RxCocoa for demonstrative functions, if want to play around.

## Installation and launch

Clone / Download & Unpack and run the project via `XChange.xcworkspace` file, as we use cocoapods.
You may need to set development team settings and address other Xcode complains at first start.
You can run project in iPhone, iPad simulators or devices with iOS 13 or higher.

Had to gitignore Pods directory due to large file issue with Realm pod: https://github.com/realm/realm-cocoa/issues/7157
Close Xcode, and from terminal:
```
cd project_path
pod install
```

> Have questions? Contact me:  nonpensavo@gmail.com

   [Swift]: <https://developer.apple.com/swift/>
   [Xcode]: <https://developer.apple.com/documentation/xcode/>
   [RealmSwift]: <https://docs.mongodb.com/realm/sdk/ios/>
   [RxSwift]: <https://github.com/ReactiveX/RxSwift>
   [CocoaPods]: <https://guides.cocoapods.org/using/getting-started.html>
   [Google Drive File]: <https://drive.google.com/file/d/1G8N4Aa8MmR2RbJ2AoHdtOTgZNack5q9L/view?usp=sharing>

