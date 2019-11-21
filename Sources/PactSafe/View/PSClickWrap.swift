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
    private let siteAccessId: String = "***REMOVED***"
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
    
    // TODO: change filterContractsById to contractIds with filter parameter
    public func loadContracts(withGroupKey groupKey: String, filterContractsById: [Int]? = []) {
        
        ps.latestContracts(byGroupKey: groupKey) { contractsData, error in
            guard let contractsData = contractsData else { return }
            let legalCenterUrl = contractsData.data.site.legalCenterURL
            self.groupId = contractsData.data.id

            let acceptanceLanguage = contractsData.data.acceptanceLanguage ?? "By clicking submit, you agree to our {{contracts}}"
            
            let acceptanceLanguageToReturn = self.clean(acceptanceLanguage, remove: "{{contracts}}")
            
            let contractsLinked: NSMutableAttributedString = NSMutableAttributedString()
            
            var index = 0
            var contractsCount = 0
            for contract in contractsData.data.contracts {
                index += 1
                
                contractsCount = contractsData.data.contracts.count
                
                self.contractIds.append(contract.id)
                self.contractVersions.append(contract.latestVersion)
                
                if let filterId = filterContractsById {
                    if filterId.count > 0 {
                        contractsCount = filterId.count
                        if !filterId.contains(contract.id) {
                            continue
                        }
                    }
                }

                let attributedString = NSMutableAttributedString(string: "\(contract.title)")
                attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: attributedString.length))
                attributedString.addAttribute(.link, value: "\(legalCenterUrl)#\(contract.key)", range: NSRange(location: 0, length: contract.title.count))
                
                if index != contractsCount {
                    attributedString.append(NSAttributedString(string: ", "))
                }
                
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
        
        ps.send(activity: .agreed, signerId: signerId, contractIds: self.contractIds, contractVersions: self.contractVersions, groupId: "\(self.groupId)", emailConfirmation: false, customSignerData: customData) { (data, response, error) in
            completionHandler(data, response, error)
        }
        
    }
    
    private func clean(_ acceptanceLanguage: String, remove dynamicParameter: String) -> NSMutableAttributedString {
        let removeString = acceptanceLanguage.replacingOccurrences(of: dynamicParameter, with: "")
        let acceptanceLanguageToReturn = NSMutableAttributedString(string: removeString)
        DispatchQueue.main.async {
            if #available(iOS 12, *) {
                if self.traitCollection.userInterfaceStyle == .dark {
                    acceptanceLanguageToReturn.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: acceptanceLanguageToReturn.length))
                } else {
                    acceptanceLanguageToReturn.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: acceptanceLanguageToReturn.length))
                }
            }
        }
        return acceptanceLanguageToReturn
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
