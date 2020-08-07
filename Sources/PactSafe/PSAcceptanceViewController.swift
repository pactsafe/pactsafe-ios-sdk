//
//  PSAcceptanceViewController.swift
//  
//
//  Created by Tim Morse  on 10/11/19.
//

import Foundation
import UIKit

/// Methods for managing events around the `PSAcceptanceViewController`.
@objc public protocol PSAcceptanceViewControllerDelegate: AnyObject {
    @objc optional func receivedAcceptance()
    @objc optional func errorSendingAcceptance(error: Error?)
    @objc optional func checkboxIsChecked(_ checked: Bool)
    @objc optional func errorLoadingGroup(error: Error?)
}

@available(iOS 10.0, *)
public class PSAcceptanceViewController: UIViewController {
    
    // MARK: - Properties
    
    /// The title displayed at the top of the view controller.
    public var termsTitle: String = "Updated Terms"
    
    /// The text displayed in the submit button below the clickwrap.
    public var submitButtonTitle = "Submit"
    
    /// Holds current status of whether the checkbox is selected or not.
    public var checkboxSelected: Bool = false
    
    /// The text used to display a change summary when present.
    public var changeSummary: String?
    
    /// The IDs of contracts that have yet to be accepted.
    private let contractIds: [String]?
    
    /// The share instance of the PSApp class.
    private let ps = PSApp.shared
    
    /// The PactSafe group key used during initialization.
    private let groupKey: String
    
    /// The PactSafe signer id (a unique identifier, commonly an email address)) used to track activity events.
    private let signerId: String
    
    /// The PactSafe custom data that is sent as part of the activity event.
    private let customData: PSCustomData?
    
    /// The object that acts as the delegate of the view controller.
    public weak var delegate: PSAcceptanceViewControllerDelegate?
    
    // MARK: - Views
    
    // MARK: Top View of Main View
    
    /// The view that holds the `changeSummaryTextView`.
    public var contractsView = UIView()
    
    /// The view that displays a contract's change summary.
    private let changeSummaryTextView = UITextView()
    
    // MARK: Bottom View of Main View
    
    /// The view used to hold the `psClickwrap` view and `submitButton`.
    public var checkboxAgreementView = UIView()
    
    /// The view used to display the clickwrap for a PactSafe group.
    private let psClickWrap = PSClickWrapView()
    
    /// The button used when wanting to submit an activity event.
    public let submitButton = PSSubmitButton(type: .roundedRect)
    
    // MARK: - Initializers
    
    public init(_ groupKey: String,
                signerId: String,
                contractIds: [String]?,
                customData: PSCustomData? = PSCustomData()) {
        self.groupKey = groupKey
        self.signerId = signerId
        self.contractIds = contractIds
        self.customData = customData
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Methods
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
    }
    
    func showLoadingIndicator() {
        // Add spinner to indicate the clickwrap is loading data and has not rendered yet
    }
    
    private func configureViews() {
        self.title = termsTitle
        showLoadingIndicator()
        configureAndAddMainViews()
        configureAndAddChangeSummaryView()
        configureAndAddClickwrap()
        configureAndAddSubmitButton()
        setupConstraints()
        checkboxAgreementView.sizeToFit()
    }
    
    private func configureAndAddMainViews() {
        self.view.backgroundColor = .white
        
        checkboxAgreementView.translatesAutoresizingMaskIntoConstraints = false
        contractsView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(checkboxAgreementView)
        self.view.addSubview(contractsView)
    }
    
    private func configureAndAddChangeSummaryView() {
        changeSummaryTextView.translatesAutoresizingMaskIntoConstraints = false
        changeSummaryTextView.isEditable = false
        changeSummaryTextView.textColor = .black
        contractsView.addSubview(changeSummaryTextView)
    }
    
    private func configureAndAddClickwrap() {
        psClickWrap.translatesAutoresizingMaskIntoConstraints = false
        checkboxAgreementView.addSubview(psClickWrap)
        psClickWrap.delegate = self
        psClickWrap.checkbox.valueChanged = { (valueChanged) in
            self.configureSubmitButtonState(valueChanged)
            self.checkboxSelected = valueChanged
            self.delegate?.checkboxIsChecked?(valueChanged)
        }
        psClickWrap.loadContracts(withGroupKey: groupKey)
    }
    
    private func configureAndAddSubmitButton() {
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        checkboxAgreementView.addSubview(submitButton)
        submitButton.setTitle(submitButtonTitle, for: .normal)
        submitButton.setBackgroundColor(UIColor.systemBlue, for: .normal)
        submitButton.setBackgroundColor(UIColor.lightGray, for: .disabled)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.setTitleColor(.gray, for: .disabled)
        submitButton.addTarget(self, action: #selector(self.submitPressed(sender:)), for: .touchUpInside)
        configureSubmitButtonState()
    }
    
    private func addChangeSummaryText(groupData: PSGroup) {
        let changeSummaryFormatted = changeSummary(groupData: groupData)
        self.changeSummary = changeSummaryFormatted
        self.changeSummaryTextView.text = changeSummaryFormatted
    }
    
    /// Creates a user-friendly view of the contracts that have changed and includes the
    /// the change summary if availlable.
    private func changeSummary(groupData: PSGroup?) -> String {
        guard let groupData = groupData else { return "" }
        
        guard let contractsData = groupData.contractData else { return "" }
        
        var changeSummaryString: String = ""
        
        if contractsData.count > 0 {
            changeSummaryTextView.font = UIFont.preferredFont(forTextStyle: .body)
            changeSummaryString.append("We've updated the following: ")
            var index = 0
            for (contractIdKey, contractData) in contractsData {
                index += 1
                if let contractIds = contractIds {
                    if contractIds.contains(contractIdKey) {
                        let contractTitle = contractData.title
                        changeSummaryString.append(contractTitle)
                        if index != contractsData.count && contractsData.count == 2 { changeSummaryString.append(" and ") }
                        if index == contractsData.count { changeSummaryString.append(".") }
                    }
                }
            }
        }
        
        return changeSummaryString
    }
    
    private func configureSubmitButtonState(_ state: Bool = false) {
        // Disable submit button by default so we can ensure checkbox is selected
        submitButton.isEnabled = state
    }
    
    @objc private func submitPressed(sender: UIButton) {
        if checkboxSelected {
            let signer = PSSigner(signerId: self.signerId)
            psClickWrap.sendAgreed(signer: signer) { (error) in
                if error == nil {
                    DispatchQueue.main.async {
                        self.delegate?.receivedAcceptance?()
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    self.delegate?.errorSendingAcceptance?(error: error)
                }
            }
        }
    }
    
    private func setupConstraints() {
        if #available(iOS 11.0, *) {
            contractsView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        } else {
            contractsView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 16).isActive = true
        }
        NSLayoutConstraint.activate([
            // Set up Contracts View
            contractsView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
            contractsView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
            contractsView.bottomAnchor.constraint(equalTo: self.checkboxAgreementView.topAnchor, constant: 16),
            
            // Set up the changes summary view
            changeSummaryTextView.topAnchor.constraint(equalTo: contractsView.topAnchor, constant: 16),
            changeSummaryTextView.leftAnchor.constraint(equalTo: contractsView.leftAnchor, constant: 24),
            changeSummaryTextView.rightAnchor.constraint(equalTo: contractsView.rightAnchor, constant: -24),
            changeSummaryTextView.bottomAnchor.constraint(equalTo: contractsView.bottomAnchor, constant: 0),
            
            // Set up main clickwrap and submit button view
            checkboxAgreementView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
            checkboxAgreementView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
            checkboxAgreementView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
//            checkboxAgreementView.heightAnchor.constraint(equalToConstant: clickwrapHeight),
            
            // Set up the clickwrap view
            psClickWrap.topAnchor.constraint(equalTo: checkboxAgreementView.topAnchor, constant: 16),
            psClickWrap.leftAnchor.constraint(equalTo: checkboxAgreementView.leftAnchor, constant: 24),
            psClickWrap.rightAnchor.constraint(equalTo: checkboxAgreementView.rightAnchor, constant: -24),
            
            // Set up the submit buttons
            submitButton.topAnchor.constraint(equalTo: psClickWrap.bottomAnchor, constant: 16),
            submitButton.leftAnchor.constraint(equalTo: checkboxAgreementView.leftAnchor, constant: 24),
            submitButton.rightAnchor.constraint(equalTo: checkboxAgreementView.rightAnchor, constant: -24),
            submitButton.bottomAnchor.constraint(equalTo: checkboxAgreementView.bottomAnchor, constant: -16),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
}

@available(iOS 10.0, *)
extension PSAcceptanceViewController: PSClickWrapViewDelegate {
    public func clickWrapRendered(withGroup groupData: PSGroup) {
        DispatchQueue.main.async {
            self.addChangeSummaryText(groupData: groupData)
        }
    }
    public func errorLoadingGroup(error: Error?) {
        self.delegate?.errorLoadingGroup?(error: error)
    }
}
