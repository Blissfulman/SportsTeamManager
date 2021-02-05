//
//  PlayerViewController.swift
//  SportsTeamManager
//
//  Created by Evgeny Novgorodov on 18.01.2021.
//

import UIKit

final class PlayerViewController: UIViewController {
    
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
    
    static let identifier = String(describing: PlayerViewController.self)
    
    var editingPlayer: Player!
    
    private var pickerViewContentType: PickerViewContentType = .teams
    private var selectedPhoto = #imageLiteral(resourceName: "some.player")
    
    private let imagePickerController = UIImagePickerController()
    private var selectedTeam: String! {
        willSet {
            teamSelectButton.setTitle(newValue, for: .normal)
        }
    }
    private var selectedPosition: String! {
        willSet {
            positionSelectButton.setTitle(newValue, for: .normal)
        }
    }
    
    private let teams = DataConstants.teams
    private let positions = DataConstants.positions
    
    private var playersDataModel: PlayersDataModelProtocol!
    
    private lazy var inPlay: Bool = {
        stateSegmentedControl.selectedSegmentIndex == 0 ? true : false
    }()
    
    // MARK: - Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        playersDataModel = PlayersDataModel.shared
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
    
    @IBAction func saveButtonTapped() {
        
        guard let number = Int16(numberTextField.text ?? ""),
           let name = nameTextField.text,
           let nationality = nationalityTextField.text,
           let age = Int16(ageTextField.text ?? ""),
           let selectedTeam = selectedTeam,
           let selectedPosition = selectedPosition else { return }
        
        let playerData: PlayerData = (
            name: name, number: number, nationality: nationality, age: age, team: selectedTeam,
            position: selectedPosition, inPlay: inPlay, photo: selectedPhoto.pngData()
        )
        editingPlayer == nil
            ? playersDataModel.createPlayer(playerData)
            : playersDataModel.updatePlayer(editingPlayer, withPlayerData: playerData)
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func withDefaultPadTextFieldsEditingChanged() {
        updateSaveButtonState()
    }
    
    @IBAction func withNumberPadTextFieldsEditingChanged(_ sender: UITextField) {
        if let text = sender.text, !text.isEmpty {
            sender.text = text.toNumberTextFieldFiltered()
        }
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
        imagePickerController.delegate = self
        saveButton.layer.cornerRadius = UIConstants.buttonCornerRadius
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .savedPhotosAlbum
        
        if let player = editingPlayer {
            fillView(for: player)
        }
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
    
    private func fillView(for player: Player) {
        if let photoData = player.photo, let photo = UIImage(data: photoData) {
            selectedPhoto = photo
            photoImageView.image = photo
        }
        stateSegmentedControl.selectedSegmentIndex = player.inPlay ? 0 : 1
        numberTextField.text = String(player.number)
        nameTextField.text = player.fullName
        nationalityTextField.text = player.nationality
        ageTextField.text = String(player.age)
        selectedTeam = player.team?.name
        selectedPosition = player.position
    }
}

// MARK: - Image picker controller delegate

extension PlayerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        defer {
            imagePickerController.dismiss(animated: true)
        }
        
        guard let photo = info[.editedImage] as? UIImage else { return }
        
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
            selectedTeam = teams[row]
        } else {
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
