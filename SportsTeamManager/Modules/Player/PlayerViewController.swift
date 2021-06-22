//
//  PlayerViewController.swift
//  SportsTeamManager
//
//  Created by Evgeny Novgorodov on 18.01.2021.
//

import UIKit

final class PlayerViewController: UIViewController {
    
    // MARK: - Static properties
    
    static let identifier = String(describing: PlayerViewController.self)
    
    // MARK: - Outlets
    
    @IBOutlet private weak var stateSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var numberTextField: UITextField!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var nationalityTextField: UITextField!
    @IBOutlet private weak var ageTextField: UITextField!
    @IBOutlet private weak var teamSelectButton: UIButton!
    @IBOutlet private weak var positionSelectButton: UIButton!
    @IBOutlet private weak var centralStackView: UIStackView!
    @IBOutlet private weak var pickerView: UIPickerView!
    @IBOutlet private weak var saveButton: UIButton!
    
    // MARK: - Properties
    
    var viewModel: PlayerViewModelProtocol!
    
    private let imagePickerController = UIImagePickerController()
    
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
    
    // MARK: Actions
    
    @IBAction private func stateSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        viewModel.stateSelectedSegmentIndex = sender.selectedSegmentIndex
    }
    
    @IBAction private func uploadPhotoButtonTapped() {
        view.endEditing(true)
        present(imagePickerController, animated: true)
    }
    
    @IBAction private func numberTextFieldEditingChanged(_ sender: UITextField) {
        viewModel.number = sender.text
        sender.text = viewModel.number
        updateSaveButtonState()
    }
    
    @IBAction private func nameTextFieldEditingChanged(_ sender: UITextField) {
        viewModel.name = nameTextField.text
        updateSaveButtonState()
    }
    
    @IBAction private func nationalityTextFieldEditingChanged(_ sender: UITextField) {
        viewModel.nationality = nationalityTextField.text
        updateSaveButtonState()
    }
    
    @IBAction private func ageTextFieldEditingChanged(_ sender: UITextField) {
        viewModel.age = sender.text
        sender.text = viewModel.age
        updateSaveButtonState()
    }
    
    @IBAction private func selectionButtonsTapped(_ sender: UIButton) {
        view.endEditing(true)
        viewModel.pickerViewContentType = sender == teamSelectButton ? .teams : .positions
        pickerView.reloadAllComponents()
        pickerView.selectRow(viewModel.pickerViewSelectedIndex, inComponent: 0, animated: false)
        showPickerView()
    }
    
    @IBAction private func saveButtonTapped() {
        viewModel.save()
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .savedPhotosAlbum
        
        setupViewModelBindings()
        fillView()
        updateSaveButtonState()
    }
    
    // MARK: - Private methods
    
    private func setupViewModelBindings() {
        viewModel.buttonTitleNeedUpdating = { [unowned self] title, contentType in
            contentType == .teams
                ? teamSelectButton.setTitle(title, for: .normal)
                : positionSelectButton.setTitle(title, for: .normal)
        }
    }
    
    private func updateSaveButtonState() {
        saveButton.isEnabled = viewModel.isEnabledSaveButton
    }
    
    private func showPickerView() {
        centralStackView.disappear()
        pickerView.appear()
    }
    
    private func hidePickerView() {
        centralStackView.appear()
        pickerView.disappear()
    }
    
    private func fillView() {
        stateSegmentedControl.selectedSegmentIndex = viewModel.stateSelectedSegmentIndex
        photoImageView.image = UIImage(data: viewModel.photo ?? Data())
        numberTextField.text = viewModel.number
        nameTextField.text = viewModel.name
        nationalityTextField.text = viewModel.nationality
        ageTextField.text = viewModel.age
        teamSelectButton.setTitle(viewModel.teamButtonTitle, for: .normal)
        positionSelectButton.setTitle(viewModel.positionButtonTitle, for: .normal)
    }
}

// MARK: - Image picker controller delegate

extension PlayerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        defer {
            imagePickerController.dismiss(animated: true)
        }
        
        guard let photo = info[.editedImage] as? UIImage else { return }
        
        viewModel.photo = photo.pngData()
        photoImageView.image = photo
    }
}

// MARK: - Picker view data source

extension PlayerViewController: UIPickerViewDataSource {
    
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

extension PlayerViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.pickerViewDidSelectRow(at: row)
        hidePickerView()
        updateSaveButtonState()
    }
}

// MARK: - Text field delegate

extension PlayerViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case numberTextField:
            nameTextField.becomeFirstResponder()
        case nameTextField:
            nationalityTextField.becomeFirstResponder()
        case nationalityTextField:
            ageTextField.becomeFirstResponder()
        default:
            view.endEditing(true)
        }
        return true
    }
    
    // Скрытие PickerView при начале ввода текста в текстовое поле
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !pickerView.isHidden {
            hidePickerView()
        }
    }
}
