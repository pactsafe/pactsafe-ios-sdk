//
//  PSClickWrapView.swift
//
//
//  Created by Tim Morse  on 10/7/19.
//

#if canImport(UIKit)
import UIKit

public protocol PSClickWrapViewDelegate: AnyObject {
    func clickWrapRendered(withGroup groupData: PSGroup)
    func errorLoadingGroup(error: Error?)
    func errorSendingAgreed(error: Error?)
}

extension PSClickWrapViewDelegate {
    // To allow for a non objective-c implementation.
    func errorLoadingGroup(error: Error?) { }
}

@available(iOS 10.0, *)
public class PSClickWrapView: UIView {
    
    // MARK: - Properties
    
    /// The object that acts as the delegate method of the PSClickwrap view.
    public weak var delegate: PSClickWrapViewDelegate?
    
    /// The view that users interact with when accepting terms.
    public var checkbox: PSCheckbox = PSCheckbox()
    
    /// The text view that displays acceptance language.
    public var textView: PSClickWrapTextView = PSClickWrapTextView()
    
    /// Optionally override the acceptance language.
    public var overrideAcceptanceLanguage: NSMutableAttributedString?
    
    /// The group data retrieved when loading the clickwrap.
    public var groupData: PSGroup?
    
    /// The shared instance of PSApp class.
    private let ps = PSApp.shared

    // MARK: - Initializers

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false

        // Configure Checkbox
        checkbox.translatesAutoresizingMaskIntoConstraints = false

        // Configure TextView
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false

        addSubview(checkbox)
        addSubview(textView)
        
        textView.sizeToFit()

        setupContraints()
        
        textView.isScrollEnabled = false
    }
    
    
    /// Load specified Group using a Group key.
    /// - Parameters:
    ///   - groupKey: The Group key for loading a PactSafe group.
    ///   - filterContractsById: Optionally, filter the group by contract IDs.
    public func loadContracts(withGroupKey groupKey: String,
                              filterContractsById: [String]? = []) {
        
        ps.loadGroup(groupKey: groupKey) { (groupData, error) in
            
            if let loadGroupError = error {
                self.delegate?.errorLoadingGroup(error: loadGroupError)
                return
            }
            
            guard let groupData = groupData else {
                self.delegate?.errorLoadingGroup(error: PSErrorMessages.noGroupDataError)
                return
            }
            
            self.groupData = groupData
            
            if let overrideLanguage = self.overrideAcceptanceLanguage {
                self.textView.attributedText = overrideLanguage
                self.delegate?.clickWrapRendered(withGroup: groupData)
                return
            }
            
            let acceptanceLanguageToReturn = self.clean(groupData.acceptanceLanguage, remove: "{{contracts}}")
            
            let contractsLinked: NSMutableAttributedString = NSMutableAttributedString()
            var index = 0
            
            if let contractsData = groupData.contractData {
                let contractsCount = contractsData.count
                for (_, contractData) in contractsData {
                    index += 1
                    let title = contractData.title
                    let legalCenterUrl = (groupData.legalCenterURL) + "#" + (contractData.key)
                    
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
    
    
    /// Send an Agreed activity for the specified SIgner.
    /// - Parameters:
    ///   - signer: The Signer for the agreed event.
    ///   - completion: Completion handler with optional error message if an error occurs.
    public func sendAgreed(signer: PSSigner,
                           completion: @escaping (_ error: Error?) -> Void) {
        guard let groupData = self.groupData else {
            self.delegate?.errorSendingAgreed(error: PSErrorMessages.sendAgreedError)
            completion(PSErrorMessages.sendAgreedError)
            return
        }
        ps.sendActivity(.agreed, signer: signer, group: groupData) { (error) in
            completion(error)
        }
    }
    
    
    private func clean(_ acceptanceLanguage: String,
                       remove dynamicParameter: String) -> NSMutableAttributedString {
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
            checkbox.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8.0),
            checkbox.heightAnchor.constraint(equalToConstant: 25.0),
            checkbox.widthAnchor.constraint(equalToConstant: 25.0),
            checkbox.centerYAnchor.constraint(equalTo: self.textView.centerYAnchor),
            
            textView.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 8.0),
            textView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 8.0),
            textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8.0),
            textView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8.0),
        ])
        checkbox.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
    }
    
}
#endif
