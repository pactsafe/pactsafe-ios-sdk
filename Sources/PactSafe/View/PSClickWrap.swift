//
//  PSClickWrap.swift
//
//
//  Created by Tim Morse  on 10/7/19.
//

import UIKit

public protocol PSClickWrapDelegate: AnyObject {
    func clickWrapRendered()
}

// TODO: Need to probably add ability to select a style of the clickwrap or do some sort of subclassing here
@available(iOS 10.0, *)
public class PSClickWrap: UIView {
    
    // MARK: - Properties
    public var checkbox: PSCheckbox
    public var textView: UITextView
    public var contractIds: [Int] = []
    public var contractVersions: [String] = []
    public var groupId: Int = 0
    private let siteAccessId: String = "790d7014-9806-4acc-8b8a-30c4987f3a95"
    private let ps = PSApp.shared

    // MARK: - Initializers

    override init(frame: CGRect) {
        checkbox = PSCheckbox()
        textView = UITextView()
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        checkbox = PSCheckbox()
        textView = UITextView()
        super.init(coder: coder)
        setupView()
    }
    
    public func loadContracts(withGroupKey groupKey: String) {
        
        ps.getLatestContracts(byGroupKey: groupKey) { contractsData, error in
            guard let contractsData = contractsData else { return }
            let legalCenterUrl = contractsData.data.site.legalCenterURL
            self.groupId = contractsData.data.id

            let acceptanceLanguage = contractsData.data.acceptanceLanguage ?? "By clicking submit, you agree to our {{contracts}}"

            let removeString = acceptanceLanguage.replacingOccurrences(of: "{{contracts}}", with: "")
            let acceptanceLanguageToReturn = NSMutableAttributedString(string: removeString)
            
            if #available(iOS 12, *) {
                DispatchQueue.main.async {
                    if self.traitCollection.userInterfaceStyle == .dark {
                        acceptanceLanguageToReturn.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: acceptanceLanguageToReturn.length))
                    } else {
                        acceptanceLanguageToReturn.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: acceptanceLanguageToReturn.length))
                    }
                }
            }
            
            let contractsLinked: NSMutableAttributedString = NSMutableAttributedString()

            var index = 0
            for contract in contractsData.data.contracts {
                index += 1

                let attributedString = NSMutableAttributedString(string: "\(contract.title)")
                attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: attributedString.length))
                attributedString.addAttribute(.link, value: "\(legalCenterUrl)#\(contract.key)", range: NSRange(location: 0, length: contract.title.count))
                if index != contractsData.data.contracts.count {
                    attributedString.append(NSAttributedString(string: ", "))
                }
                
                self.contractIds.append(contract.id)
                self.contractVersions.append(contract.latestVersion)
                
                contractsLinked.append(attributedString)
            }
            acceptanceLanguageToReturn.append(contractsLinked)
            DispatchQueue.main.async {
                self.textView.attributedText = acceptanceLanguageToReturn
            }
        }
    }
    
    public func sendAgreed(signerId: String,
                           customData: PSCustomData?,
                           completionHandler: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        
        ps.sendActivity(signerId: signerId, activityType: .agreed, contractIds: self.contractIds, contractVersions: self.contractVersions, groupId: "\(self.groupId)", emailConfirmation: false, customSignerData: customData) { (data, response, error) in
            completionHandler(data, response, error)
        }
        
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        textView = UITextView()

        // Configure Checkbox
        checkbox.translatesAutoresizingMaskIntoConstraints = false

        // Configure TextView
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false

        addSubview(checkbox)
        addSubview(textView)

        setupContraints()
    }
    
    private func setupContraints() {
        checkbox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.0).isActive = true
        textView.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 8.0).isActive = true
        textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 8.0).isActive = true
        checkbox.topAnchor.constraint(equalTo: topAnchor, constant: 16.0).isActive = true
        checkbox.heightAnchor.constraint(equalToConstant: 25.0).isActive = true
        checkbox.widthAnchor.constraint(equalToConstant: 25.0).isActive = true
        textView.topAnchor.constraint(equalTo: topAnchor, constant: 8.0).isActive = true
        textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 8.0).isActive = true
        checkbox.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
    }

}
