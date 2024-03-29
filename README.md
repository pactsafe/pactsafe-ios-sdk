![Ironclad Logo](Additional%20Documentation/images/ironclad-logo.png)


# Ironclad Clickwrap iOS SDK
- [Ironclad Clickwrap iOS SDK](#ironclad-clickwrap-ios-sdk)
  - [Requirements](#requirements)
  - [Installation](#installation)
    - [Swift Package Manager](#swift-package-manager)
    - [CocoaPods](#cocoapods)
    - [Carthage](#carthage)
    - [GitHub](#github)
  - [Notes Before Getting Started](#notes-before-getting-started)
    - [Demo iOS App](#demo-ios-app)
    - [Debug Mode](#debug-mode)
    - [Test Mode](#test-mode)
    - [Data Types](#data-types)
  - [Configure and Initialize the Ironclad Clickwrap SDK](#configure-and-initialize-the-ironclad-clickwrap-sdk)
  - [PSClickWrapView](#psclickwrapview)
    - [Preloading Clickwrap Data](#preloading-clickwrap-data)
    - [Loading Your Clickwrap](#loading-your-clickwrap)
      - [Interface Builder](#interface-builder)
        - [IBOutlet your Clickwrap](#iboutlet-your-clickwrap)
        - [Loads Contracts Into Your Clickwrap](#loads-contracts-into-your-clickwrap)
      - [Programmatically](#programmatically)
      - [Configure Contracts Link Tap Behavior](#configure-contracts-link-tap-behavior)
        - [Import Safari Services](#import-safari-services)
        - [Configure PSClickWrapView UITextView Delegate](#configure-psclickwrapview-uitextview-delegate)
        - [Implement UITextViewDegate Protocol and Method](#implement-uitextviewdegate-protocol-and-method)
      - [Check if Checkbox is Selected](#check-if-checkbox-is-selected)
      - [Sending Acceptance](#sending-acceptance)
      - [PSClickWrapViewDelegate](#psclickwrapviewdelegate)
  - [Checking Acceptance](#checking-acceptance)
    - [Using the signedStatus Method](#using-the-signedstatus-method)
    - [Using the PSAcceptanceViewController](#using-the-psacceptanceviewcontroller)
      - [What it Looks Like](#what-it-looks-like)
      - [Setting It Up](#setting-it-up)
      - [PSAcceptanceViewControllerDelegate](#psacceptanceviewcontrollerdelegate)
        - [Receive Notice of Acceptance](#receive-notice-of-acceptance)
    - [Using signedStatus Method and Present Alert](#using-signedstatus-method-and-present-alert)
  - [Sending Activity Manually](#sending-activity-manually)
  - [Customizing Acceptance Data](#customizing-acceptance-data)
    - [Connection Data](#connection-data)
    - [Custom Data](#custom-data)
      - [Adding Additional Custom Data](#adding-additional-custom-data)


## Requirements

- Xcode 11 or higher
- Target iOS 10.0 or higher
- Swift 5.0+
- Ironclad Clickwrap Published Contracts in Public Group
- Ironclad Clickwrap Group Key
- Ironclad Clickwrap Site Access ID
- Ironclad Clickwrap API Access

## Installation

### Swift Package Manager
You can use the [Swift Package Manager](https://swift.org/package-manager/) to install the Ironclad Clickwrap SDK:

https://github.com/pactsafe/pactsafe-ios-sdk.git

### CocoaPods
You can use [CocoaPods](http://cocoapods.org/) to install the Ironclad Clickwrap SDK by adding it to your Podfile:

```swift
platform :ios, '10.0'
use_frameworks!

target 'MyApp' do
	pod 'PactSafe', '~> 1.0.1'
end
```

### Carthage
You can use [Carthage](https://github.com/Carthage/Carthage) to install the Ironclad Clickwrap SDK by adding it to your Cartfile:

```swift
github "pactSafe/pactsafe-ios-sdk" ~> 1.0.1
```

### GitHub
Use the [GitHub repo](https://github.com/pactsafe/pactsafe-ios-sdk) to download the entire framework manually.



## Notes Before Getting Started

### Demo iOS App
As you follow along in this guide, you may want to look at the Ironclad Embedded Clickwrap iOS Demo App as an example. You can pull down the [demo app here in GitHub](https://github.com/pactsafe/pactsafe-ios-sdk-demo).

### Debug Mode
Something not quite working the way you expect or you need additional information as to what might not be working? Simply enable the `debugMode` property on `PSApp.shared` to print additional information.

```swift
PSApp.shared.debugMode = true
```
### Test Mode
Optionally, set `testMode` to true as you are testing your implementation. This allows you to delete test data in your Ironclad Clickwrap site.

Note: Don't forget to remove this line before you are finished!

```swift
PSApp.shared.testMode = true
```

### Data Types

Before you start to implement, you will want to become familiar with a few data types used by the iOS SDK.

| Name             | Description                                                  |
| ---------------- | ------------------------------------------------------------ |
| PSSignerID       | `PSSignerID` is a typealias for String.                      |
| PSSigner         | `PSSigner` is a structure that you'll use to send over your signer information. You must include a signer ID (`PSSignerID`) when needing to send data to Ironclad Clickwrap. You can optionally pass over additional custom data with a `PSCustomData` struct, which is covered below. |
| PSCustomData     | `PSCustomData` is a structure that holds additional information about the activity. Please see the properties that are available to be set in the [Customizing Acceptance Data](#customizing-acceptance-data) section. |
| PSGroup          | `PSGroup` is a structure that holds information about a speciifc group (uses Ironclad Clickwrap group key) that is loaded from the Ironclad Clickwrap API. |
| PSContract       | `PSContract` is a structure that holds information about contracts within a Ironclad Clickwrap group (`PSGroup`). |
| PSConnectionData | The `PSConnectionData` structure holds information about the current connection [Customizing Acceptance Data](#customizing-acceptance-data) section. |



## Configure and Initialize the Ironclad Clickwrap SDK

In order to use the Ironclad Clickwrap SDK, you’ll need to import PactSafe into your UIApplicationDelegate:

```swift
import PactSafe
```

Using the SDK also requires authentication, which you’ll want to set up in your `application:didFinishLaunchingWithOptions` delegate.

Note: You **<u>must</u>** configure your Ironclad Clickwrap Site Access ID before using the PSApp shared instance!

```swift
PSApp.shared.configure(siteAccessId: "yourSiteAccessId")
```



## PSClickWrapView

The easiest way of getting started with using the Ironclad Clickwrap is by utilizing our PSClickWrapView class to dynamically load your contracts into a UIView. The PSClickWrapView class conforms to the UIView class, which allows you to easily customize and format the clickwrap as needed.

### Preloading Clickwrap Data

Since your `PSClickWrapView` class will load contracts for the specified Ironclad Clickwrap group, you may want to preload the data using your group key before displaying the clickwrap. By preloading, a user will be less likely see loading when they get to the screen that contains the PSClickWrapView.

To preload your Ironclad Clickwrap group data, you can use the `preload` method on the PSApp shared instance within your AppDelegate. Example below:

```swift
// Do this after you configure your PSApp shared instance!
PSApp.shared.preload(withGroupKey: "example-group-key")
```

By using the `preload` method, the data is stored using the iOS URLCache class in memory only.

### Loading Your Clickwrap

The PSClickWrapView class is built on top of a UIView, which gives you flexibility in your implementation. You can implement in the following ways:

- **Interface Builder** - add the custom class to a UIView within your storyboard that will load your Ironclad Clickwrap.
- **Programmatically** - programmatically gives you the most flexibility implementing the Ironclad Clickwrap into your project. 

#### Interface Builder
With an empty view in your storyboard, simply subclass the UIView with the PSClickWrapView class. Once you subclass the UIView, you’ll need to do some configuring of the ClickWrap within your view controller.

*Note: Don't forget to import PactSafe into your view controller.*

##### IBOutlet your Clickwrap
Make sure to create an IBOutlet to your PSClickWrapView UIView in order to customize it.

##### Loads Contracts Into Your Clickwrap
In order to get contracts to load into your clickwrap, you’ll need to use the `loadContracts` method, where you'll pass in your Ironclad Clickwrap group key.

```swift
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    myClickWrap.loadContracts(withGroupKey: "example-mobile-app-group")
}
```

Once loaded, your clickwrap might look something like this:

![Example Loaded Clickwrap](Additional%20Documentation/images/clickwrap-loaded-example.png)

#### Programmatically
To use the `PSClickWrapView` class programmatically, you can use the default initializer that accept a frame with a `CGRect` size as you normally would while using UIView.

```swift
// Example of what might be in your UIViewController.
private var clickWrap: PSClickWrapView?

override func viewDidLoad() {
    super.viewDidLoad()
    configureClickWrap()
}

private func configureClickwrap() {
    clickWrap = PSClickWrapView(frame: CGRect.zero)
    guard let clickWrap = clickWrap else { return }
    clickWrap.loadContracts(withGroupKey: "your-group-key")
    // Insert your PSClickWrapView and do any additional setup.
}
```




#### Configure Contracts Link Tap Behavior
The `PSClickWrapView` loads the text and links into a `UITextView`, which gives you flexibility for customizing link tap behavior. By default, `UITextView` will take users out of your app and into Safari. If you'd rather keep users in your app, you can use a `UITextViewDelegate` to adjust the default behavior.

##### Import Safari Services
Within the view controller where you configured your clickwrap, you’ll need to import SafariServices.

```swift
import SafariServices
```

##### Configure PSClickWrapView UITextView Delegate
The PSClickWrapView contains a property `textView` that exposes the UITextView that holds your acceptance language and links to your terms.

```swift
// Assign the delegate to your view controller
myClickWrap.textView.delegate = self
```

##### Implement UITextViewDegate Protocol and Method
Having assigned the delegate to your ViewController, you’ll need to add the UITextViewDelegate to your ViewController and use the `shouldInteractWith URL` method.

```swift
extension MyViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let safariVc = SFSafariViewController(url: URL)
        present(safariVc, animated: true, completion: nil)
        return false
    }
}
```

#### Check if Checkbox is Selected
Before letting a user submit the form, you may want to make sure that the checkbox is selected. To do so, you can monitor the value of the checkbox when you configure your clickwrap.

```swift
// Can be used after you load your clickwrap (e.g., after you call loadContracts).
myClickWrap.checkbox.valueChanged = { (isChecked) in
    // If checked, enable (true) your UIButton submit button otherwise ensure it's disabled (false). You may want to also adjust the style of your button here as well.
    if isChecked {
    	self.yourSubmitButton.isEnabled = true
    } else {
    	self.yourSubmitButton.isEnabled = false
    }
}
```

#### Sending Acceptance
When using `PSClickWrapView`, you can easily send an "agreed" event once they have accepted your contracts. To do this, you'll pass along a `PSSigner` to the `sendAgreed` method on your `PSClickWrapView` class.

```swift
/// PSClickWrapView has a method 'sendAgreed' that allows you to easily send acceptance using a signer id and any custom data.
let signer = PSSigner(signerId: signerId, customData: customData)
myClickWrap.sendAgreed(signer: signer) { (response, error) in
    if error == nil {
        // Use PSCustomData to send additional data about the activity
        var customData = PSCustomData()
        customData.firstName = firstNameText
        customData.lastName = lastNameText

        // Create the signer with the specified id and custom data.
        let signer = PSSigner(signerId: emailAddressText, customData: customData)
                
        // Use the sendAgreed method on the clickwrap to send acceptance.
        self.pactSafeClickWrap.sendAgreed(signer: signer) { (error) in
            if error == nil {
                // Handle next step
            } else {
                // Handle error
            }
        }
    } else {
        // Handle error
    }
}
```

#### PSClickWrapViewDelegate

You can optionally use the `PSClickWrapViewDelegate` protocol to receive events for your `PSClickWrapView`. The following methods are available to be used:

| Method Definition                                 | Description                                                | Optional |
| ------------------------------------------------- | ---------------------------------------------------------- | -------- |
| `clickWrapRendered(withGroup groupData: PSGroup)` | Triggered when a group has loaded and provides group data. | No       |
| `errorLoadingGroup(error: Error?)`                | Triggered when there's an error loading the group data.    | Yes      |


## Checking Acceptance

We provide a few of ways checking acceptance and optionally presenting information if major version changes have been published. The following are three potential options you may choose to use:

- Using the signedStatus method
- Using a PSAcceptanceViewController
- Using signedStatus Method and Present Alert

### Using the signedStatus Method

The `signedStatus` method gives you the opportunity to check on the status of acceptance within a specific Ironclad Clickwrap group.

```swift
let signerId = "test@pactafe.com"
let psGroupKey = "example-group-key"

// The signedStatus method will return a boolean of whether the specified signer id has accepted all contracts within the group key. If they do need to accept a more recent version, the IDs of contracts will be returned in an array [String].
ps.signedStatus(for: signerId, groupKey: psGroupKey) { (needsAcceptance, contractIds) in 
    if needsAcceptance {
        // Handle showing acceptance needed.
    } else {
        self.segueHome()
    }
}
```

### Using the PSAcceptanceViewController
You can optionally choose to utilize the `PSAcceptanceViewController` in order to conveniently present to your users which contracts had major changes, what the changes were (if change summary is provided within Ironclad Clickwrap), and an opportunity to accept them.

#### What it Looks Like
We provide a simple implementation that can be easily customized to incorporate your brand styling. More on styling later in the documentation.

![Example PSAcceptanceViewController](Additional%20Documentation/images/psacceptanceviewcontroller-example.png "PSAcceptanceViewController")

#### Setting It Up
```swift
// Set up your PSApp.shared instance for use.
let ps = PSApp.shared

// Set the Ironclad Clickwrap group key you plan to check.
let groupKey: String = "example-group-key"

/**
 * Use the signedStatus method to get acceptance information.
 * You'll pass in the signer id that you want to check for and your group key.
 * The method will return whether any acceptance is needed and the contract ids that need acceptance.
*/
ps.signedStatus(for: signerId, in: groupKey) { (needsAcceptance, contractIds) in
    if needsAcceptance {
        // Call the PSAcceptanceViewController with the group key, signer id, and contract ids that need to be accepted.
        let psAcceptanceVc = PSAcceptanceViewController(groupKey, signerId, contractIds)
        // Since PSAcceptanceViewController conforms to UIViewController, you can configure your presentation.
        psAcceptanceVc.modalPresentationStyle = .automatic
        psAcceptanceVc.modalTransitionStyle = .coverVertical
        self.present(psAcceptanceVc, animated: true, completion: nil)
    } else {
        // No acceptance is needed, so move them to where they should go.
        self.segueToHome()
    }
}

```

#### PSAcceptanceViewControllerDelegate

You can use the `PSAcceptanceViewControllerDelegate` to receive events associated with the `PSAcceptanceViewController`.

Available methods when you adopt to the protocol:

| Method Definition                       | Description                                                  | Optional |
| --------------------------------------- | ------------------------------------------------------------ | -------- |
| `receivedAcceptance()`                  | Triggered when a successful submission of acceptance has been sent. | Yes      |
| `errorSendingAcceptance(error: Error?)` | Triggered when there's an issue with sending acceptance.     | Yes      |
| `checkboxIsSelected(_ checked: Bool)`   | Triggered when the checkbox is checked or unchecked.         | Yes      |
| `errorLoadingGroup(error: Error?)`      | Triggered when there's an error loading the Ironclad Clickwrap group for the `PSClickWrapView`. | Yes      |



##### Receive Notice of Acceptance

You'll probably want to know if the user checked the box and then clicked submit. You'll need to adopt a `PSAcceptanceViewControllerDelegate` protocol to your ViewController and implement the `receivedAcceptance` method to know acceptance was received. Implementation may look something like this:

```swift
extension MyViewController: PSAcceptanceViewControllerDelegate {
    func receivedAcceptance() {
        // Take your action here
        loginUser()
    }
}
```

### Using signedStatus Method and Present Alert
You may want a more simple approach of presenting that acceptance is needed or need greater customization. To get details around acceptance status, we provide two methods `signedStatus` and `loadGroup` that help you get the appropriate information for displaying to a user.

```swift
/// Get the status for a specific signer in a group.
ps.signedStatus(for: signerId, groupKey: groupKey) { (needsAcceptance, contractIds) in
    if needsAcceptance {
        self.showContractUpdates(forSignerId: signerId, password: passwordText)
    } else {
        // Handle next step
    }
}

private func showContractUpdates(forSignerId signerId: String,
                                 password passwordText: String,
                                 filterContractIds: [String]? = nil) {
                                 
    self.ps.loadGroup(groupKey: self.groupKey) { (groupData, error) in
        guard let groupData = groupData, let contractsData = groupData.contractData else { return }
        self.psGroupData = groupData
        var titlesOfContracts = [String]()    
        var updatedContractsMessage: String = "We've updated the following: "
        if let cidsFilter = filterContractIds {
            contractsData.forEach { (key, value) in
                if cidsFilter.contains(key) { titlesOfContracts.append(value.title) }
            }
        } else {
            contractsData.forEach { (key, value) in
                titlesOfContracts.append(value.title)
            }
        }
        let contractTitles = titlesOfContracts.map { String($0) }.joined(separator: " and ")
        updatedContractsMessage.append(contractTitles)
        updatedContractsMessage.append(".\n \n Please agree to these changes.")
                                              
        let alert = self.updatedTermsAlert("Updated Terms", message: updatedContractsMessage, email: signerId, password: passwordText)
        self.present(alert, animated: true, completion: nil)
        }
    }
```

By getting these details and using a UIAlertController, you could show an alert for the user that there have been updated terms and provide them a few available actions.



![Example UIAlert](Additional%20Documentation/images/login-with-alert.png "UIAlert")





## Sending Activity Manually

There may be times when you need to send an activity event manually. Doing so just requires using the `sendActivity` method on your Ironclad Clickwrap shared instance.

Here's an example method that would allow you to send acceptance:

```swift
func send(for signer: PSSigner) {
    PSApp.shared.sendActivity(.agreed, signer: signer, group: groupData) { (error) in
        if error !== nil {
            print("Error sending acceptance.")
        }
    }
}
```



## Customizing Acceptance Data

By default, when you send an activity event with the SDK, some additional information about the device will be sent to Ironclad Clickwrap.

There are two parts of data that will be sent as part of the activity event, which you may want to reference as you are implementing the SDK.

- Connection Data
- Custom Data

### Connection Data
Below, you'll find information on what to expect the SDK to send over as part of the activity event as "Connection Data", which is viewable within a Ironclad Clickwrap activity record. Many of the properties are set upon initialization except the optional properties (marked optional below) and use the following Apple APIs: `UIDevice`, `Locale`, and `TimeZone`. If you need further information about these properties, please reach out to us directly.

| Property                | Description                                                  | Overridable |
| ----------------------- | ------------------------------------------------------------ | ----------- |
| `clientLibrary`         | The client library name being used that is sent as part of the activity. | No          |
| `clientVersion`         | The client library version being used that is sent as part of the activity. | No          |
| `deviceFingerprint`     | The unique identifier that is unique and usable to this device. | No          |
| `environment`           | The mobile device category being used (e.g,. tablet or mobile). | No          |
| `operatingSystem`       | The operating system and version of the device.              | No          |
| `screenResolution`      | The screen resolution of the device.                         | No          |
| `browserLocale`         | The current locale identifier of the device.                 | Yes         |
| `browserTimezone`       | The current time zone identifier of the device.              | Yes         |
| `pageDomain` (Optional) | The domain of the page being viewed. *Note: This is normally for web pages but is available to be populated if needed.* | Yes         |
| `pagePath` (Optional)   | The path of the page being viewed. *Note: This is normally for web pages but is available to be populated if needed.* | Yes         |
| `pageQuery` (Optional)  | The query path on the page being viewed. *Note: This is normally for web pages but is available to be populated if needed.* | Yes         |
| `pageTitle` (Optional)  | The title of the page being viewed. *Note: This is normally for web pages but is available to be populated if you'd like to use the title of the screen where the Ironclad Clickwrap activity is occurring.* | Yes         |
| `pageUrl` (Optional)    | The URL of the page being viewed. Note: This is normally for web pages but is available to be populated if needed. | Yes         |
| `referrer` (Optional)   | The referred of the page being viewed. *Note: This is normally for web pages but is avaialble to be populated if needed.* | Yes         |



### Custom Data

Custom Data can hold additional information that you'd like to pass over that will be appended to the activity event. By adding Custom Data to the event, you'll be able to search and filter within the Ironclad Clickwrap web app, which is especially beneficial when you have many activity events.

Before sending an activity event, you may want to customize properties on `PSCustomData` that can be set. Please note that properties such as `firstName`, `lastName`, `companyName`, and `title` are reserved properties on `PSCustomData` for Ironclad Clickwrap platform usage only (e.g., seeing the name of an individual within the Ironclad Clickwrap app) but can be set by you.

| Property        | Description                                                  | Overridable |
| --------------- | ------------------------------------------------------------ | ----------- |
| `firstName`     | First Name is a reserved property for custom data in Ironclad Clickwrap but can be set. | Yes         |
| `lastName`      | Last Name is a reserved property for custom data in Ironclad Clickwrap but can be set. | Yes         |
| `companyName`   | Company Name is a reserved property for custom data in Ironclad Clickwrap but can be set. | Yes         |
| `title`         | Title is a reserved property for custom data in Ironclad Clickwrap but can be set. | Yes         |

#### Adding Additional Custom Data

When you need to add your own custom data properties and values, you can easily do so by utilizing the `add(withKey key: String, value: Any)` method on `PSCustomData`, which accepts a key as a `String `and value of `Any`.

Example adding your own custom data:

```swift
var customData = PSCustomData()
customData.firstName = firstNameText
customData.lastName = lastNameText
customData.add(withKey: "myCustomKey", value: "myCustomValue")
customData.add(withKey: "mySecondCustomKey", value: "mySecondCustomValue")
```

You can also remove a previously add key and value by using the method `remove(forKey key: String)`, which removes the value based on the key you previously used.
