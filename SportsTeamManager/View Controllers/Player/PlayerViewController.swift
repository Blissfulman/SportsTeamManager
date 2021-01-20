//
//  PlayerViewController.swift
//  SportsTeamManager
//
//  Created by User on 18.01.2021.
//

import UIKit

final class PlayerViewController: UIViewController {
    
    private enum Constants {
        static let teams = ["Real", "Barcelona", "Chelsea", "Roma", "CSKA", "Monaco",
                            "Manchester Unated", "Liverpool", "Bavaria", "Juventus"]
        static let positions = ["Defender", "Halfback", "Forward"]
    }
    
    private enum PickerViewContentType {
        case teams
        case positions
    }
    
    // MARK: - Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nationalityTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var selectedTeamButton: UIButton!
    @IBOutlet weak var selectedPositionButton: UIButton!
    @IBOutlet weak var centralStackView: UIStackView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Properties
    static let identifier = String(describing: PlayerViewController.self)
    
    var dataManager: CoreDataManager!
    
    private var pickerViewContentType: PickerViewContentType = .teams
    
    private var chosenPhoto = #imageLiteral(resourceName: "some.player")
    private var selectedTeam: String!
    private var selectedPosition: String!
    private let imagePickerController = UIImagePickerController()
    
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
        centralStackView.isHidden = true
        pickerView.isHidden = false
    }
    
    @IBAction func positionSelectButtonTapped() {
        view.endEditing(true)
        pickerViewContentType = .positions
        pickerView.reloadAllComponents()
        centralStackView.isHidden = true
        pickerView.isHidden = false
    }
    
    @IBAction func saveButtonTapped() {
//        let context = dataManager.getContext()
//
//        let team = dataManager.createObject(from: Team.self)
//        team.name = selectedTeam
//
//        let player = dataManager.createObject(from: Player.self)
//        player.team = team
//
//        player.photo = chosenPhoto
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func textFieldsEditingChanged() {
        updateSaveButtonState()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
        pickerView.isHidden = true
        centralStackView.isHidden = false
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        imagePickerController.delegate = self
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
    }
}

extension PlayerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        defer {
            imagePickerController.dismiss(animated: true)
        }
        
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        guard let photo = info[convertFromUIImagePickerControllerInfoKey(.originalImage)] as? UIImage else {
            return
        }
        chosenPhoto = photo
        photoImageView.image = photo
    }
}

extension PlayerViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerViewContentType == .teams {
            selectedTeamButton.setTitle(Constants.teams[row], for: .normal)
            selectedTeam = Constants.teams[row]
        } else {
            selectedPositionButton.setTitle(Constants.positions[row], for: .normal)
            selectedPosition = Constants.positions[row]
        }
        pickerView.isHidden = true
        centralStackView.isHidden = false
        updateSaveButtonState()
    }
}

extension PlayerViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerViewContentType == .teams ? Constants.teams.count : Constants.positions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerViewContentType == .teams ? Constants.teams[row] : Constants.positions[row]
    }
}

extension PlayerViewController {
    
    func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        Dictionary(uniqueKeysWithValues: input.map { key, value in (key.rawValue, value) })
    }
        
    func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        input.rawValue
    }
}

// MARK: - Text Field Delegate
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
        pickerView.isHidden = true
        centralStackView.isHidden = false
    }
}
