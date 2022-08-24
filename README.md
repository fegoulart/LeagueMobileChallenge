# LeagueMobileChallenge 

## Architecture
* [Clean Architecture Based](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) 
* UI pattern: MVP with Adapter conforming to ViewDelegate + MVC 
* Modular Architecture Design: Separate module (PostLoader) responsible for both Remote and Local Repository that can be tested without simulator + iOS specific target
* [Architectural diagrams](https://drive.google.com/file/d/1RiLrma3DdoF-Fk5_QEKeVhMagSQe5mq9/view?usp=sharing)

### MVP with Adapter conforming to ViewDelegate
* View delegates messages via a protocol
* Adapter conforms to ViewDelegate and translates event to Domain requests/commands
* Presenter holds a reference to an Abstract View type in the form of a protocol
* Example diagram:

[MVP example diagram](https://www.filepicker.io/api/file/SYyWMPykTPEoQxqvz4j2)

### Some Design Patterns present in project:
* Adapter
* Composite
* Decorator
* Delegate
* Factory
* Mapper

### Implementation details
* Networking implemented with URLSession
* User data caching implemented with CoreData (with cache expiration logic) 

## Dependencies
* [swiftlint](https://github.com/realm/SwiftLint) - coding style  

## Requirements
* XCode 13
* iOS 13.0

### Possible improvements:

* [Tuist Implementation](https://tuist.io)
* ViewCode implementation (currently it is with Storyboard)
* Secure api token storage (e.g. Keychain)
* Async api token retrieval (currently it is synchronous)
* Post Local Caching (not only for User data) 
* UI Tests
* Automatic build / deploy pipeline (e.g.: Fastlane) 
* Add an app icon 
* Dark mode
* Implement accessibility features
* Ipad / MacOS / WatchOs version
* UI improvements (e.g.: dynamic cell height) 
