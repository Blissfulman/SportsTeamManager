//
//  PlayerViewController.swift
//  SportsTeamManager
//
//  Created by User on 18.01.2021.
//

import UIKit

final class PlayerViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var stateSegmentedControl: UISegmentedControl!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nationalityTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var teamSelectButton: UIButton!
    @IBOutlet weak var positionSelectButton: UIButton!
    @IBOutlet weak var centralStackView: UIStackView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Properties
    
    static let identifier = String(describing: PlayerViewController.self)
    
    private var pickerViewContentType: PickerViewContentType = .teams
    private var selectedPhoto = #imageLiteral(resourceName: "some.player")
    private var selectedTeam: String!
    private var selectedPosition: String!
    private let imagePickerController = UIImagePickerController()
    
    private let teams = DataConstants.teams
    private let positions = DataConstants.positions
    
    private var playersDataModel: PlayersDataModel!
    
    private lazy var inPlay: Bool = {
        stateSegmentedControl.selectedSegmentIndex == 0 ? true : false
    }()
    
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
    
    // MARK: Actions
    
    @IBAction func uploadPhotoButtonTapped() {
        view.endEditing(true)
        present(imagePickerController, animated: true)
    }
    
    @IBAction func teamSelectButtonTapped() {
        view.endEditing(true)
        pickerViewContentType = .teams
        pickerView.reloadAllComponents()
        showPickerView()
    }
    
    @IBAction func positionSelectButtonTapped() {
        view.endEditing(true)
        pickerViewContentType = .positions
        pickerView.reloadAllComponents()
        showPickerView()
    }
    
    @IBAction func saveButtonTapped() {
        
        guard let number = Int16(numberTextField.text ?? ""),
           let name = nameTextField.text,
           let nationality = nationalityTextField.text,
           let age = Int16(ageTextField.text ?? ""),
           let selectedTeam = selectedTeam,
           let selectedPosition = selectedPosition else { return }
        
        playersDataModel.createPlayer(
            name: name, number: number, nationality: nationality, age: age, team: selectedTeam,
            position: selectedPosition, inPlay: inPlay, photo: selectedPhoto.pngData()
        )
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func textFieldsEditingChanged() {
        updateSaveButtonState()
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
        title = "New player"
        imagePickerController.delegate = self
        saveButton.layer.cornerRadius = UIConstants.buttonCornerRadius
        updateSaveButtonState()
    }
    
    // MARK: - Private methods
    
    private func updateSaveButtonState() {
        if let number = numberTextField.text, !number.isEmpty,
           let name = nameTextField.text, !name.isEmpty,
           let nationality = nationalityTextField.text, !nationality.isEmpty,
           let age = ageTextField.text, !age.isEmpty,
           let _ = selectedTeam,
           let _ = selectedPosition {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
        saveButton.backgroundColor = saveButton.isEnabled ? Color.main : Color.disabled
    }
    
    private func showPickerView() {
        centralStackView.disappear()
        pickerView.appear()
    }
    
    private func hidePickerView() {
        centralStackView.appear()
        pickerView.disappear()
    }
}

// MARK: - Image picker controller delegate

extension PlayerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        defer {
            imagePickerController.dismiss(animated: true)
        }
        
        guard let photo = info[.originalImage] as? UIImage else { return }
        
        selectedPhoto = photo
        photoImageView.image = photo
    }
}

// MARK: - Picker view data source

extension PlayerViewController: UIPickerViewDataSource {
    
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

extension PlayerViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerViewContentType == .teams {
            teamSelectButton.setTitle(teams[row], for: .normal)
            selectedTeam = teams[row]
        } else {
            positionSelectButton.setTitle(positions[row], for: .normal)
            selectedPosition = positions[row]
        }
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
