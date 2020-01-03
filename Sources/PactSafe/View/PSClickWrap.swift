//
//  PSClickWrap.swift
//
//
//  Created by Tim Morse  on 10/7/19.
//

import UIKit

public protocol PSClickWrapDelegate: AnyObject {
    func clickWrapRendered(withGroup groupData: PSGroupData)
}

// TODO: Need to probably add ability to select a style of the clickwrap or do some sort of subclassing here
@available(iOS 10.0, *)
public class PSClickWrap: UIView {
    
    // MARK: - Properties
    public weak var delegate: PSClickWrapDelegate?
    public var checkbox: PSCheckbox
    public var textView: UITextView
    public var contractIds: [Int] = []
    public var contractVersions: [String] = []
    public var groupId: Int = 0
    public var overrideAcceptanceLanguage: NSMutableAttributedString?
    public var groupData: PSGroupData?
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
    public func loadContracts(withGroupKey groupKey: String,
                              filterContractsById: [String]? = []) {
        
        ps.loadGroup(groupKey: groupKey) { (groupData, error) in
            guard let groupData = groupData else {
                self.handleNoGroupData()
                return
            }
            
            self.groupData = groupData
            self.groupId = groupData.group
            
            let acceptanceLanguage = groupData.acceptanceLanguage ?? "By clicking below, you agree to our {{contracts}}"
            let acceptanceLanguageToReturn = self.clean(acceptanceLanguage, remove: "{{contracts}}")
            
            let contractsLinked: NSMutableAttributedString = NSMutableAttributedString()
            var index = 0
            
            if let contractsData = groupData.contractData {
                for (_, contractData) in contractsData {
                    index += 1
                    let title = contractData.title ?? ""
                    let legalCenterUrl = (groupData.legalCenterURL ?? "") + "#" + (contractData.key ?? "")
                    let attributedString = NSMutableAttributedString(string: title)
                    attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: attributedString.length))
                    attributedString.addAttribute(.link, value: legalCenterUrl, range: NSRange(location: 0, length: title.count))
                    
                    if index != contractsData.count {
                        attributedString.append(NSAttributedString(string: ", "))
                    }
                    
                    contractsLinked.append(attributedString)
                }
                
                acceptanceLanguageToReturn.append(contractsLinked)
                
                if let overridenLanguage = self.overrideAcceptanceLanguage {
                    self.overrideAcceptanceLanguage = overridenLanguage
                }
                
                DispatchQueue.main.async {
                    self.textView.attributedText = acceptanceLanguageToReturn
                }
            }
            
            self.delegate?.clickWrapRendered(withGroup: groupData)
        }
    }
    
    // TODO: Tweak the main view to be able to handle if data is not present
    func handleNoGroupData() {
        
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
        NSLayoutConstraint.activate([
            checkbox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.0),
            textView.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 8.0),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 8.0),
            checkbox.topAnchor.constraint(equalTo: topAnchor, constant: 16.0),
            checkbox.heightAnchor.constraint(equalToConstant: 25.0),
            checkbox.widthAnchor.constraint(equalToConstant: 25.0),
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 8.0),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 8.0)
        ])
        checkbox.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)

    }

}
