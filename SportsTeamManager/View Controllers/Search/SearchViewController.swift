//
//  SearchViewController.swift
//  SportsTeamManager
//
//  Created by User on 27.01.2021.
//

import UIKit

final class SearchViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var backEnvironmentView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var ageOperatorSegmentedControl: UISegmentedControl!
    @IBOutlet weak var teamSelectButton: UIButton!
    @IBOutlet weak var positionSelectButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var startSearchButton: UIButton!
    
    // MARK: - Properties
    
    static let identifier = String(describing: SearchViewController.self)
    
    private var pickerViewContentType: PickerViewContentType = .teams
    private var selectedTeam: String!
    private var selectedPosition: String!
    
    private let teams = DataConstants.teams
    private let positions = DataConstants.positions
    
    private var playersDataModel: PlayersDataModel!
    
    private var ageOperator: String {
        switch ageOperatorSegmentedControl.selectedSegmentIndex {
        case 0:
            return "<="
        case 1:
            return "="
        default:
            return ">="
        }
    }
    
    // MARK: - Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        playersDataModel = PlayersDataModelImpl.shared
    }
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Actions
    
    @IBAction func teamSelectButtonTapped() {
        view.endEditing(true)
        pickerViewContentType = .teams
        pickerView.reloadAllComponents()
        pickerView.selectRow(teams.safeFirstIndex(of: selectedTeam),
                             inComponent: 0,
                             animated: false)
        showPickerView()
    }
    
    @IBAction func positionSelectButtonTapped() {
        view.endEditing(true)
        pickerViewContentType = .positions
        pickerView.reloadAllComponents()
        pickerView.selectRow(positions.safeFirstIndex(of: selectedPosition),
                             inComponent: 0,
                             animated: false)
        showPickerView()
    }
    
    @IBAction func startSearchButtonTapped() {
        var int16Age: Int16?
        
        if let age = ageTextField.text, !age.isEmpty {
            int16Age = Int16(age)
        }
        
        let predicateData: PredicateData = (
            name: nameTextField.text, age: int16Age, ageOperator: ageOperator,
            team: selectedTeam, position: selectedPosition
        )
        playersDataModel.predicateDidChanged(predicateData)
        dismiss(animated: true)
    }
    
    @IBAction func resetButtonTapped() {
        playersDataModel.resetPredicate()
        dismiss(animated: true)
    }
    
    @objc private func dismissByTapAction() {
        dismiss(animated: true)
    }
    
    @IBAction func nameTextFieldEditingChanged() {
        updateStartSearchButtonState()
    }
    
    @IBAction func ageTextFieldEditingChanged(_ sender: UITextField) {
        if let text = sender.text, !text.isEmpty {
            sender.text = text.toNumberTextFieldFiltered()
        }
        updateStartSearchButtonState()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
        
        if !pickerView.isHidden {
            hidePickerView()
        }
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        contentView.layer.cornerRadius = UIConstants.viewCornerRadius
        contentView.layer.shadowRadius = UIConstants.shadowRadius
        contentView.layer.shadowOpacity = UIConstants.shadowOpacity
        contentView.layer.shadowColor = Color.shadow.cgColor
        startSearchButton.layer.cornerRadius = UIConstants.buttonCornerRadius
        
        let dismissByTapGR = UITapGestureRecognizer(target: self,
                                                    action: #selector(dismissByTapAction))
        backEnvironmentView.addGestureRecognizer(dismissByTapGR)
        updateStartSearchButtonState()
    }
    
    // MARK: - Private methods
    
    private func updateStartSearchButtonState() {
        var isEnabled = false
        
        if (selectedTeam != nil) || (selectedPosition != nil) {
            isEnabled = true
        } else if let name = nameTextField.text, !name.isEmpty {
            isEnabled = true
        } else if let age = ageTextField.text, !age.isEmpty {
            isEnabled = true
        }
        
        startSearchButton.isEnabled = isEnabled
        startSearchButton.backgroundColor = startSearchButton.isEnabled
            ? Color.main
            : Color.disabled
    }
    
    private func showPickerView() {
        stackView.disappear()
        pickerView.appear()
    }
    
    private func hidePickerView() {
        stackView.appear()
        pickerView.disappear()
    }
}

// MARK: - Picker view data source

extension SearchViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerViewContentType == .teams ? teams.count : positions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerViewContentType == .teams ? teams[row] : positions[row]
    }
}

// MARK: - Picker view delegate

extension SearchViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerViewContentType == .teams {
            teamSelectButton.setTitle(teams[row], for: .normal)
            selectedTeam = teams[row]
        } else {
            positionSelectButton.setTitle(positions[row], for: .normal)
            selectedPosition = positions[row]
        }
        hidePickerView()
        updateStartSearchButtonState()
    }
}

// MARK: - Text field delegate

extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == nameTextField {
            ageTextField.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        return true
    }
}
