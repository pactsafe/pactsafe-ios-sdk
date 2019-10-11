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

    public var backgroundColorTest: String = ""
    public var textView: UITextView?
    public var checkbox: Checkbox?
    public var contractIds: [Int] = []
    public var contractVersions: [String] = []

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

        checkbox = Checkbox()
        textView = UITextView()

        // Configure Checkbox
        checkbox?.translatesAutoresizingMaskIntoConstraints = false

        // Configure TextView
        textView?.translatesAutoresizingMaskIntoConstraints = false
        textView?.isEditable = false

        guard let textView = textView else { return }
        guard let checkbox = checkbox else { return }

        addSubview(checkbox)
        addSubview(textView)

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

    public func loadContracts() {
        let ps = PSApp.sharedInstance
        // TODO: Change behavior of implementing group name
        ps.getLatestContracts(byGroupKey: "example-mobile-app-group") { contractsData, _ in
            guard let contractsData = contractsData else { return }

            let legalCenterUrl = contractsData.data.site.legalCenterURL

            let acceptanceLanguage = contractsData.data.acceptanceLanguage ?? "By clicking submit, you agree to our @contracts."

            let removeString = acceptanceLanguage.replacingOccurrences(of: "@contracts.", with: "")
            let acceptanceLanguageToReturn = NSMutableAttributedString(string: removeString)
            let contractsLinked: NSMutableAttributedString = NSMutableAttributedString()

            var index = 0
            for contract in contractsData.data.contracts {
                index += 1

                let attributedString = NSMutableAttributedString(string: "\(contract.title)")
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
                self.textView?.attributedText = acceptanceLanguageToReturn
            }
        }
    }
}
