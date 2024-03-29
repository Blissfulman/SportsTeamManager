//
//  SearchViewController.swift
//  SportsTeamManager
//
//  Created by Evgeny Novgorodov on 27.01.2021.
//

import UIKit

final class SearchViewController: UIViewController {
    
    // MARK: - Static properties
    
    static let identifier = String(describing: SearchViewController.self)
    
    // MARK: - Outlets
    
    @IBOutlet private weak var backEnvironmentView: UIView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var ageTextField: UITextField!
    @IBOutlet private weak var ageOperatorSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var teamSelectButton: UIButton!
    @IBOutlet private weak var positionSelectButton: UIButton!
    @IBOutlet private weak var pickerView: UIPickerView!
    @IBOutlet private weak var startSearchButton: UIButton!
    
    // MARK: - Properties
    
    var viewModel: SearchViewModelProtocol!
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
        
        if !pickerView.isHidden {
            hidePickerView()
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func nameTextFieldEditingChanged() {
        viewModel.name = nameTextField.text
        updateStartSearchButtonState()
    }
    
    @IBAction private func ageTextFieldEditingChanged(_ sender: UITextField) {
        viewModel.age = sender.text
        sender.text = viewModel.age
        updateStartSearchButtonState()
    }
    
    @IBAction private func ageOperatorSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        viewModel.ageOperatorSelectedSegmentIndex = sender.selectedSegmentIndex
    }
    
    @IBAction private func selectionButtonsTapped(_ sender: UIButton) {
        view.endEditing(true)
        viewModel.pickerViewContentType = sender == teamSelectButton ? .teams : .positions
        pickerView.reloadAllComponents()
        pickerView.selectRow(viewModel.pickerViewSelectedIndex, inComponent: 0, animated: false)
        showPickerView()
    }
    
    @IBAction private func startSearchButtonTapped() {
        viewModel.startSearch()
        dismiss(animated: true)
    }
    
    @IBAction private func resetButtonTapped() {
        viewModel.resetSearchData()
        dismiss(animated: true)
    }
    
    @objc private func dismissByTapAction() {
        dismiss(animated: true)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        contentView.layer.cornerRadius = UIConstants.viewCornerRadius
        contentView.layer.shadowRadius = UIConstants.shadowRadius
        contentView.layer.shadowOpacity = UIConstants.shadowOpacity
        contentView.layer.shadowColor = Color.shadow.cgColor
        
        let dismissByTapGR = UITapGestureRecognizer(target: self, action: #selector(dismissByTapAction))
        backEnvironmentView.addGestureRecognizer(dismissByTapGR)
        
        setupViewModelBindings()
        fillView()
        updateStartSearchButtonState()
    }
    
    // MARK: - Private methods
    
    private func setupViewModelBindings() {
        viewModel.buttonTitleNeedUpdating = { [unowned self] title, contentType in
            contentType == .teams
                ? teamSelectButton.setTitle(title, for: .normal)
                : positionSelectButton.setTitle(title, for: .normal)
        }
    }
    
    private func updateStartSearchButtonState() {
        startSearchButton.isEnabled = viewModel.isEnabledStartSearchButton
    }
    
    private func showPickerView() {
        stackView.disappear()
        pickerView.appear()
    }
    
    private func hidePickerView() {
        stackView.appear()
        pickerView.disappear()
    }
    
    private func fillView() {
        nameTextField.text = viewModel.name
        ageTextField.text = viewModel.age
        ageOperatorSegmentedControl.selectedSegmentIndex = viewModel.ageOperatorSelectedSegmentIndex
        teamSelectButton.setTitle(viewModel.teamButtonTitle, for: .normal)
        positionSelectButton.setTitle(viewModel.positionButtonTitle, for: .normal)
    }
}

// MARK: - Picker view data source

extension SearchViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        viewModel.pickerViewNumberOfRows
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        viewModel.pickerViewTitle(forRow: row)
    }
}

// MARK: - Picker view delegate

extension SearchViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.pickerViewDidSelectRow(at: row)
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
