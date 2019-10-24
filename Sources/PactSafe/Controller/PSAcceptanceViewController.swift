//
//  PSAcceptanceViewController.swift
//  
//
//  Created by Tim Morse  on 10/11/19.
//

import Foundation
import UIKit

//@objc public protocol PSAcceptanceViewControllerDelegate: AnyObject {
//    @objc optional func acceptanceStatus()
//}

@available(iOS 11, *)
public class PSAcceptanceViewController: UIViewController {
    
    // MARK: - Properties
    public var termsTitle: String = "Updated Terms"
    public var changeSummary: String?
    public var contractIds: [Int]?
    public var checkboxSelected: Bool = false
//    public weak var delegate: PSAcceptanceViewControllerDelegate?
    
    private let groupKey: String?
    private let signerId: String?
    private let ps = PSApp.shared
    
    // Set up our views
    public var contractsView = UIView()
    public var checkboxAgreementView = UIView()
    public let submitButton = UIButton()
    private let titleLabel = UILabel()
    private let changeSummaryTextView = UITextView()
    private let clickWrap = PSClickWrap()
    
    // TODO: It seems as if barely moving the modal causes the view to run viewWillAppear again, which means it could end up causing the API constantly. Need to investigate why this is called so quickly and what steps we'd need to take in order to prevent the API being called.
    public init(_ groupKey: String?, _ signerId: String?, _ contractIds: [Int]?) {
        self.groupKey = groupKey
        self.signerId = signerId
        self.contractIds = contractIds
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //TODO: Check if contraints should be set in viewWillAppear
        setupContractsView()
        setupConstraints()
    }
    
    func setupContractsView() {
        self.view.backgroundColor = .white
        
        checkboxAgreementView.translatesAutoresizingMaskIntoConstraints = false
        contractsView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(checkboxAgreementView)
        self.view.addSubview(contractsView)
        
        setupTitleLabel()
        setupChangeSummaryView()
        setupClickWrap()
        setupSubmitButton()
    }
    
    func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = termsTitle
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 0
        titleLabel.font = titleLabel.font.withSize(28.0)
        contractsView.addSubview(titleLabel)
    }
    
    func setupChangeSummaryView() {
        changeSummaryTextView.translatesAutoresizingMaskIntoConstraints = false
        changeSummaryTextView.isEditable = false
        groupChangeSummary { (changes) in
            if let changes = changes {
                self.changeSummary = changes
                DispatchQueue.main.async {
                    self.changeSummaryTextView.text = changes
                }
            }
        }
        changeSummaryTextView.textColor = .black
        contractsView.addSubview(changeSummaryTextView)
    }
    
    func groupChangeSummary(completion: @escaping(_ changeSummary: String?) -> Void) {
        // Make sure contractIds exists.
        guard let contractIds = self.contractIds else { return }
        self.ps.getContractsDetails(withContractIds: contractIds) { contracts, error in
            if error == nil {
                var changeSummary: [String] = []
                for contract in contracts {
                    let contractTitle = contract?.publishedVersion.title ?? ""
                    let contractChangeSummary = contract?.publishedVersion.changeSummary ?? ""
                    changeSummary.append("\(contractTitle): \(contractChangeSummary)")
                }
                let changesToList = changeSummary.map { String($0) }.joined(separator: ",")
                completion(changesToList)
            } else {
                if self.ps.debugMode {
                    debugPrint(error as Any)
                }
            }
        }
    }
    
    func setupClickWrap() {
        clickWrap.translatesAutoresizingMaskIntoConstraints = false
        checkboxAgreementView.addSubview(clickWrap)
        guard let groupKey = groupKey else { return }
        clickWrap.loadContracts(withGroupKey: groupKey)
        clickWrap.checkbox.valueChanged = { (valueChanged) in
            self.configureSubmitButtonState(valueChanged)
            self.checkboxSelected = valueChanged
        }
    }
    
    func setupSubmitButton(_ title: String = "Submit") {
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        checkboxAgreementView.addSubview(submitButton)
        submitButton.setTitle(title, for: .normal)
        submitButton.tintColor = .black
        submitButton.setTitleColor(.black, for: .normal)
        submitButton.setTitleColor(.lightGray, for: .disabled)
        configureSubmitButtonState()
    }
    
    func configureSubmitButtonState(_ state: Bool = false) {
        // Disable submit button by default so we can ensure checkbox is selected
        submitButton.isEnabled = state
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // Set up checkbox bottom view
            checkboxAgreementView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            checkboxAgreementView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 0),
            checkboxAgreementView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: 0),
            checkboxAgreementView.heightAnchor.constraint(equalToConstant: 200),
            
            // Set up Contracts View
            contractsView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16),
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
            clickWrap.topAnchor.constraint(equalTo: checkboxAgreementView.topAnchor, constant: 0),
            clickWrap.leftAnchor.constraint(equalTo: checkboxAgreementView.leftAnchor, constant: 0),
            clickWrap.rightAnchor.constraint(equalTo: checkboxAgreementView.rightAnchor, constant: 0),
            clickWrap.heightAnchor.constraint(equalToConstant: 100),
            
            // Set up the submit buttons
            submitButton.topAnchor.constraint(equalTo: clickWrap.bottomAnchor, constant: 8),
            submitButton.widthAnchor.constraint(equalToConstant: 150),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            submitButton.centerXAnchor.constraint(equalTo: checkboxAgreementView.centerXAnchor)
        ])
    }
    
}
