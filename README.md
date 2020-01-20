# PactSafe iOS SDK

1. [Requirements](#requirements)
2. [Getting Started](#getting-started)
	* [Integration](#integration)
	* [Notes for Getting Started](#notes-getting-started)
3. [Usage](#usage)
	* [Set Up Authentication and Initialize](#authentication-and-initialization)
  * [Loading a Clickwrap](#loading-clickwrap)
  * [Checking Acceptance](#checking-acceptance)
  * [Send Activity Manually](#send-activity-manually)
  * [Customizing Acceptance Data](#customizing-acceptance-data)

## Requirements {#requirements}

- Xcode 11 or higher
- Target iOS 10.0 or higher
- Swift 5.0+
- PactSafe Published Contracts in Public Group
- PactSafe Group Key
- PactSafe Site Access ID

## Getting Started {#getting-started}

### Integration {#integration}
#### Swift Package Manager
You can use the [Swift Package Manager](https://swift.org/package-manager/) to install the PactSafe SDK:

https://github.com/pactsafe/pactsafe-ios-sdk.git

#### CocoaPods
You can use [CocoaPods](http://cocoapods.org/) to install the PactSafe SDK by adding it to your Podfile:

```swift
	platform :ios, '10.0'
	use_frameworks!

	target 'MyApp' do
	    pod 'PactSafe', '~> 1.0'
	end
```

#### Carthage
You can use [Carthage](https://github.com/Carthage/Carthage) to install the PactSafe SDK by adding it to your Cartfile:

```swift
	github "PactSafe/pactsafe-ios-sdk" ~> 4.0
```


#### GitHub
Use the [GitHub repo](https://github.com/pactsafe/pactsafe-ios-sdk) to download the entire framework manually.

***

### Notes for Getting Started {#notes-getting-started}

#### Demo iOS App
As you follow along in this guide, you may want to look at the PactSafe iOS Demo App as an example.

#### Debug Mode
Something not quite working the way you expect or you need additional information as to what might not be working? No problem. Simply enable the `debugMode` property on `PSApp.shared`.

```swift
PSApp.shared.debugMode = true
```
#### Test Mode
Optionally, set `testMode` to true as you are testing your implementation. This allows you to delete test data in your PactSafe site.

Note: Don't forget to remove this line before you are finished!

```swift
PSApp.shared.testMode = true
```

## Usage {#usage}

### Set Up Authentication and Initalize the PactSafe SDK {#authentication-and-initialization}
In order to use the PactSafe SDK, you’ll need to import PactSafe into your UIApplicationDelegate:

```swift
import PactSafe
```

Using the SDK also requires authentication, which you’ll want to set up in your `application:didFinishLaunchingWithOptions` delegate.

In order to authenticate, you'll want to use the class `PSAuthentication` with your PactSafe Site Acces ID and assign it to the `authentication` property on `PSApp.shared`.

```swift
PSApp.shared.authentication = PSAuthentication(siteAccessId: yourSiteAccessId)
```

### Loading a Clickwrap {#loading-clickwrap}
The easiest way of getting started with using the PactSafe clickwrap is by utilizing our PSClickWrap class to dynamically load your contracts into a UIView. The PSClickWrap class conforms to the UIView class, which allows you to easily customize and format the clickwrap as needed.

The PSClickWrap class offers your default UIView initializers, giving you flexibility with implementation You can either:

- **Interface Builder** - add the custom class to a UIView within your storyboard that will load your PactSafe clickwrap.
- **Programatically** - programatically gives you the most flexibility getting the PactSafe clickwrap into your project. 

#### Interface Builder
With an empty view in your storyboard, simply subclass the UIView with the PSClickWrap class. Once you subclass the UIView, you’ll need to do some configuring of the ClickWrap within your view controller.

Note: Don't forget to import PactSafe into your view controller.

##### IBOutlet your Clickwrap
Make sure to create an IBOutlet to your PSClickWrap UIView in order to customize it.

##### Loads Contracts Into Your Clickwrap
In order to get contracts to load into your clickwrap, you’ll need to use the loadContracts method, where you'll pass in your PactSafe group key.

```swift
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    myClickWrap.loadContracts(withGroupKey: "example-mobile-app-group")
}
```

Once loaded, your clickwrap might look something like this:

![Example Loaded Clickwrap](./Documentation/images/clickwrap-loaded-example.png "User Flows")

##### Configure Contracts Link Tap Behavior
The PSClickWrap loads the text and links into a UITextView, which gives you some flexibility for customizing link tap behavior. By default, UITextView will take users out of your app and into Safari. If you'd rather keep users in your app, you can use a UITextViewDelegate to adjust the default behavior.

###### Import Safari Services
Within the view controller where you configured your clickwrap, you’ll need to import SafariServices.

```swift
import SafariServices
```

###### Configure Delegate
The PSClickWrap contains a property `textView` that exposes the UITextView that contains your acceptance language.

```swift
myClickWrap.textView.delegate
```

###### Implement UITextViewDegate Protocol and Method
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

#### Check if Checkbox is Selected {#check-checkbox-selected}
Before letting a user submit the form, you may want to make sure that the checkbox is selected. To do so, you can monitor the value of the checkbox when you configure your clickwrap.

```swift
// Can be used after you load your clickwrap (e.g., after you call loadContracts).
myClickWrap.checkbox.valueChanged = { (isChecked) in
    // If checked, enable (true) your UIButton submit button otherwise ensure it's disabled (false)
    if isChecked {
        self.yourSubmitButton.isEnabled = true
    } else {
        self.yourSubmitButton.isEnabled = false
    }
}
```

#### Sending Acceptance
When using PSClickWrap, you can easily send an "agreed" event once they have accepted your contracts. To do this, you'll pass along a signer id and any custom data that you'd like to send to PactSafe.

```swift
/// PSClickWrap has a method 'sendAgreed' that allows you to easily send acceptance using a signer id and any custom data.
myClickWrap.sendAgreed(signerId: signerId, customData: customData) { (data, response, error) in
    if error == nil {
        self.performSegue(withIdentifier: "signUpToHomeSegue", sender: self)
    } else {
        self.formAlert("\(error)")
    }
}
```

## Checking Acceptance {#checking-acceptance}
We provide a few of ways checking acceptance and presenting if major version changes have been published. The following are three potential options.

- Using a PSAcceptanceViewController
- Using signedStatus Method and Present Alert
- Using the signedStatus method

### Using a PSAcceptanceViewController {#psAcceptanceViewController}
You can optionally choose to utilize the PSAcceptanceViewController in order to conveniently present to your users which contracts had major changes, what the changes were (if change summary is provided within PactSafe), and a PSClickWrap for users to easily accept the updated terms.

#### What it Looks Like
We provide a simple implementation that can be easily customized to incorporate your brand styling. More on styling later in the documentation.

![Example PSAcceptanceViewController](./Documentation/images/psacceptanceviewcontroller-example.png "PSAcceptanceViewController")

#### Setting It Up
Getting things set up only takes a few lines of code.

```swift
// Set up your PSApp.shared instance for use.
let ps = PSApp.shared

// Set the PactSafe group key you plan to check.
let groupKey: String = "my-pactsafe-group-key"

/**
 * Use the signedStatus method to get acceptance information.
 * You'll pass in the signer id that you want to check for and your group key.
 * The method will return whether any acceptance is needed and the contract ids that need acceptance.
*/
ps.signedStatus(for: signerId, in: groupKey) { (needsAcceptance, contractIds) in
    if needsAcceptance {
        DispatchQueue.main.async {
            /// Call the PSAcceptanceViewController with the group key, signer id, and contract ids that need to be accepted.
            let psAcceptanceVc = PSAcceptanceViewController(groupKey, signerId, contractIds)
            
            // Since PSAcceptanceViewController conforms to UIViewController, you can configure your presentation.
            psAcceptanceVc.modalPresentationStyle = .automatic
            psAcceptanceVc.modalTransitionStyle = .coverVertical
            self.present(psAcceptanceVc, animated: true, completion: nil)
        }
    } else {
        // No acceptance is needed, so move them to where they should go.
        DispatchQueue.main.async {
            self.segueToHome()
        }
    }
}

```

#### Receive Notice of Acceptance
You'll probably want to know if the user checked the box and then clicked submit. You'll need to adopt a `PSAcceptanceViewControllerDelegate` protocol to your ViewController and implement the `receivedAcceptance` method to know acceptance was received. Implementation may look something like this:

```swift
extension MyViewController: PSAcceptanceViewControllerDelegate {
    func receivedAcceptance() {
        // Take your action here
        loginUser()
    }
}
```

### Using signedStatus Method and Present Alert {#present-alert}
You may want a more simple approach of presenting that acceptance is needed or need greater customization. To get details around acceptance status, we provide two methods `signedStatus` and `getContractDetails` that help you get the appropriate information for displaying to a user.

```swift
/// Get the status for a specific signer in a group.
ps.signedStatus(for: signerId, in: groupKey) { (needsAcceptance, contractIds) in
            
            if needsAcceptance {
                self.ps.loadGroup(groupKey: self.groupKey) { (groupData, error) in
            guard let groupData = groupData else { return }
            guard let contractsData = groupData.contractData else { return }
            
            var updatedContractsMessage: String = "We've updated the following: "
            
            for (_, value) in contractsData {
                let contractTitle = value.title ?? ""
                updatedContractsMessage.append(contractTitle + " ")
            }
            
            updatedContractsMessage.append("\n \n Please agree to these changes.")
            
            DispatchQueue.main.async {
                let alert = self.updatedTermsAlert("Updated Terms", message: updatedContractsMessage, email: signerId, password: passwordText)
                self.present(alert, animated: true, completion: nil)
            }
        }
            
        }
                
            } else {
                DispatchQueue.main.async {
                    self.segueToHome()
                }
            }
        }
```

By getting these details and using a UIAlertController, you could show an alert.



![Example UIAlert](./Documentation/images/login-with-alert.png "UIAlert")



## Using the signedStatus Method





## Sending Activity Manually {#send-activity-manually}

There may be times when you need to send an activity event manually. Doing so just requires using the `send` method on your PactSafe shared instance.

Here's an example method that would allow you to send acceptance:

```swift
// Example
func send(for signerId: String) {
    self.ps.send(activity: .agreed,
    signerId: signerId,
    contractIds: self.contractIds,
    contractVersions: self.contractVersions,
    groupId: nil,
    customSignerData: nil) { (data, response, error) in
    	print("My response: \(response)")
    }
}
```

## Customizing Acceptance Data {#customizing-acceptance-data}
By default, when you send an activity event with the SDK, some additional information about the device will be sent to PactSafe.

The following data will be sent by default and is documented here to avoid potential duplication as you work on planning custom data you may pass to PactSafe.


- **Device Name:** `UIDevice.current.name`
- **Device System Name:** `UIDevice.current.systemName`
- **Device System Version:** `UIDevice.current.systemVersion`
- **Device Identifier for Vendor:** `UIDevice.current.identifierForVendor?.uuidString` (is an optional, which may result in it being an empty string)
- **Locale Identifier:** `Locale.current.identifier`
- **Locale Region Code:** `Locale.current.regionCode` (is an optional, which may result in it being an empty string)
- **Time Zone Identifier:** `TimeZone.current.identifier`
