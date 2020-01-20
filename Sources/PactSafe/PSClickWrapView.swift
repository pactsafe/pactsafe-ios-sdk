//
//  PSClickWrap.swift
//
//
//  Created by Tim Morse  on 10/7/19.
//

import UIKit

public protocol PSClickWrapViewDelegate: AnyObject {
    func clickWrapRendered(withGroup groupData: PSGroupData)
}

@available(iOS 10.0, *)
public class PSClickWrapView: UIView {
    
    // MARK: - Properties
    
    /// The object that acts as the delegate method of the PSClickwrap view.
    public weak var delegate: PSClickWrapViewDelegate?
    
    /// The view that users interact with when accepting terms.
    public var checkbox: PSCheckbox = PSCheckbox()
    
    /// The text view that displays acceptance language.
    public var textView: UITextView = UITextView()
    
    
    public var contractIds: [String] = []
    
    
    public var contractVersions: [String] = []
    
    
    public var groupId: Int = 0
    
    
    public var customAcceptanceLanguage: String?
    
    
    public var overrideAcceptanceLanguage: NSMutableAttributedString?
    
    
    public var groupData: PSGroupData?
    
    /// The shared instance of PSApp class.
    private let ps = PSApp.shared

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        // Configure Checkbox
        checkbox.translatesAutoresizingMaskIntoConstraints = false

        // Configure TextView
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.sizeToFit()
        textView.isEditable = false
        textView.isScrollEnabled = false

        addSubview(checkbox)
        addSubview(textView)

        setupContraints()
    }
    
    public override func draw(_ rect: CGRect) {
        
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
            self.groupId = groupData.id
            self.contractIds = groupData.contracts.map({ String($0) })
            self.contractVersions = groupData.versions
            
            let acceptanceLanguage = groupData.acceptanceLanguage ?? "By clicking below, you agree to our {{contracts}}"
            let acceptanceLanguageToReturn = self.clean(acceptanceLanguage, remove: "{{contracts}}")
            
            let contractsLinked: NSMutableAttributedString = NSMutableAttributedString()
            var index = 0
            
            if let contractsData = groupData.contractData {
                let contractsCount = contractsData.count
                for (_, contractData) in contractsData {
                    index += 1
                    let title = contractData.title ?? ""
                    let legalCenterUrl = (groupData.legalCenterURL ?? "") + "#" + (contractData.key ?? "")
                    
                    let attributedString = NSMutableAttributedString(string: title)
                    attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: attributedString.length))
                    attributedString.addAttribute(.link, value: legalCenterUrl, range: NSRange(location: 0, length: title.count))
                    
                    if index != contractsCount {
                        attributedString.append(NSAttributedString(string: " and "))
                    }
                    
                    if index == contractsCount {
                        attributedString.append(NSAttributedString(string: "."))
                    }
                    
                    contractsLinked.append(attributedString)
                }
                
                acceptanceLanguageToReturn.append(contractsLinked)
                acceptanceLanguageToReturn.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .footnote), range: NSRange(location: 0, length: acceptanceLanguageToReturn.length))
                
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
    private func handleNoGroupData() {
        
    }
    
    public func sendAgreed(signer: PSSigner,
                           completion: @escaping (_ response: URLResponse?, _ error: Error?) -> Void) {
        
        // TODO: Handle no group data
        guard let groupData = self.groupData else { return }
        ps.sendActivity(.agreed, signer: signer, group: groupData) { (response, error) in
            completion(response, error)
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
    
    private func setupContraints() {
        NSLayoutConstraint.activate([
            checkbox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.0),
            checkbox.heightAnchor.constraint(equalToConstant: 25.0),
            checkbox.widthAnchor.constraint(equalToConstant: 25.0),
            checkbox.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            textView.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 8.0),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 8.0),
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 0.0),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0)
        ])
        checkbox.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
    }

}
