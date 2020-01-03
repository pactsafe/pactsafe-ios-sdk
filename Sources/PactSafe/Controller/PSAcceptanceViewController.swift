//
//  PSAcceptanceViewController.swift
//  
//
//  Created by Tim Morse  on 10/11/19.
//

import Foundation
import UIKit

@objc public protocol PSAcceptanceViewControllerDelegate: AnyObject {
    @objc optional func receivedAcceptance()
}

@available(iOS 10.0, *)
public class PSAcceptanceViewController: UIViewController {
    
    // MARK: - Properties
    public var termsTitle: String = "Updated Terms"
    public var contractIds: [Int]?
    public var checkboxSelected: Bool = false
    public var submitButtonTitle = "Submit"
    public weak var delegate: PSAcceptanceViewControllerDelegate?
    
    public var changeSummary: String?
    
    private let groupKey: String
    private let signerId: String
    private let customData: PSCustomData?
    private let ps = PSApp.shared
    
    // MARK: - Views
    
    // MARK: Top View of Main View
    /// Hold the title text and contract change summary.
    public var contractsView = UIView()
    
    /// Display title  on screen.
    private let titleLabel = UILabel()
    
    /// Display any major changes to contracts.
    private let changeSummaryTextView = UITextView()
    
    // MARK: Bottom View of Main View
    /// View used to hold clickwrap view and submit button.
    public var checkboxAgreementView = UIView()
    
    /// Display acceptance language and an optional checkbox.
    private let psClickWrap = PSClickWrap()
    
    /// Dubmit acceptance to PactSafe.
    public let submitButton = PSSubmitButton(type: .roundedRect)
    
    // TODO: It seems as if barely moving the modal causes the view to run viewWillAppear again, which means it could end up causing the API constantly. Need to investigate why this is called so quickly and what steps we'd need to take in order to prevent the API being called.
    public init(_ groupKey: String,
                _ signerId: String,
                _ contractIds: [Int]?,
                _ customData: PSCustomData? = PSCustomData()) {
        self.groupKey = groupKey
        self.signerId = signerId
        self.contractIds = contractIds
        self.customData = customData
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func showLoadingIndicator() {
        // Add spinner to indicate the clickwrap is loading data and has not rendered yet
    }
    
    func configureViews() {
        showLoadingIndicator()
        configureAndAddMainViews()
        configureAndAddTitleLabel()
        configureAndAddChangeSummaryView()
        configureAndAddClickwrap()
        configureAndAddSubmitButton()
        addTitleText()
        setupConstraints()
    }
    
    func configureAndAddMainViews() {
        self.view.backgroundColor = .white
        
        checkboxAgreementView.translatesAutoresizingMaskIntoConstraints = false
        contractsView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(checkboxAgreementView)
        self.view.addSubview(contractsView)
    }
    
    func configureAndAddTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 0
        titleLabel.font = titleLabel.font.withSize(28.0)
        contractsView.addSubview(titleLabel)
    }
    
    func configureAndAddChangeSummaryView() {
        changeSummaryTextView.translatesAutoresizingMaskIntoConstraints = false
        changeSummaryTextView.isEditable = false
        changeSummaryTextView.textColor = .black
        contractsView.addSubview(changeSummaryTextView)
    }
    
    func configureAndAddClickwrap() {
        psClickWrap.translatesAutoresizingMaskIntoConstraints = false
        checkboxAgreementView.addSubview(psClickWrap)
        psClickWrap.delegate = self
        psClickWrap.checkbox.valueChanged = { (valueChanged) in
            self.configureSubmitButtonState(valueChanged)
            self.checkboxSelected = valueChanged
        }
        psClickWrap.loadContracts(withGroupKey: groupKey)
    }
    
    func configureAndAddSubmitButton() {
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
    
    func addTitleText() {
        titleLabel.text = termsTitle
    }
    
    func addChangeSummaryText(groupData: PSGroupData) {
        let changeSummaryFormatted = groupChangeSummary(groupData: groupData)
        self.changeSummary = changeSummaryFormatted
        self.changeSummaryTextView.text = changeSummaryFormatted
    }
    
    func groupChangeSummary(groupData: PSGroupData?) -> String {
        guard let groupData = groupData else { return "" }
        
        var changeSummary: [String] = []
        
        guard let contractsData = groupData.contractData else { return "" }
        for (_, contractData) in contractsData {
            guard let title = contractData.title else { return "" }
            guard let summary = contractData.changeSummary else { return "" }
            changeSummary.append(("\(title): \(summary)"))
        }
        
        return changeSummary.map({ String($0) }).joined(separator: ",")
    }
    
    func configureSubmitButtonState(_ state: Bool = false) {
        // Disable submit button by default so we can ensure checkbox is selected
        submitButton.isEnabled = state
    }
    
    @objc func submitPressed(sender: UIButton) {
        if checkboxSelected {
            psClickWrap.sendAgreed(signerId: self.signerId, customData: customData) { (data, response, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        self.delegate?.receivedAcceptance?()
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    if self.ps.debugMode {
                        debugPrint(error as Any)
                    }
                }
            }
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // Set up checkbox bottom view
            checkboxAgreementView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
            checkboxAgreementView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
            checkboxAgreementView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
            checkboxAgreementView.heightAnchor.constraint(equalToConstant: 200),
            
            // Set up Contracts View
            contractsView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 16),
            contractsView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
            contractsView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
            contractsView.bottomAnchor.constraint(equalTo: self.checkboxAgreementView.topAnchor),
            
            // Set up title label
            titleLabel.topAnchor.constraint(equalTo: contractsView.topAnchor, constant: 16),
            titleLabel.leftAnchor.constraint(equalTo: contractsView.leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: contractsView.rightAnchor, constant: -8),
            titleLabel.heightAnchor.constraint(equalToConstant: 50),
            
            // Set up the changes summary view
            changeSummaryTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            changeSummaryTextView.leftAnchor.constraint(equalTo: contractsView.leftAnchor, constant: 8),
            changeSummaryTextView.rightAnchor.constraint(equalTo: contractsView.rightAnchor, constant: -8),
            changeSummaryTextView.bottomAnchor.constraint(equalTo: contractsView.bottomAnchor, constant: 0),
            
            // Set up the clickwrap view
            psClickWrap.topAnchor.constraint(equalTo: checkboxAgreementView.topAnchor, constant: 0),
            psClickWrap.leftAnchor.constraint(equalTo: checkboxAgreementView.leftAnchor, constant: 0),
            psClickWrap.rightAnchor.constraint(equalTo: checkboxAgreementView.rightAnchor, constant: 0),
            psClickWrap.heightAnchor.constraint(equalToConstant: 100),
            
            // Set up the submit buttons
            submitButton.topAnchor.constraint(equalTo: psClickWrap.bottomAnchor, constant: 8),
            submitButton.widthAnchor.constraint(equalToConstant: 150),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            submitButton.centerXAnchor.constraint(equalTo: checkboxAgreementView.centerXAnchor)
        ])
    }
    
}

@available(iOS 10.0, *)
extension PSAcceptanceViewController: PSClickWrapDelegate {
    public func clickWrapRendered(withGroup groupData: PSGroupData) {
        DispatchQueue.main.async {
            self.addChangeSummaryText(groupData: groupData)
        }
    }
}
