//
//  PlayerViewController.swift
//  SportsTeamManager
//
//  Created by User on 18.01.2021.
//

import UIKit

final class PlayerViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nationalityTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    
    
    // MARK: - Properties
    static let identifier = String(describing: PlayerViewController.self)
    
    var dataManager: CoreDataManager!
    
    private var chosenImage = #imageLiteral(resourceName: "some.player")
    private let imagePickerController = UIImagePickerController()
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: Actions
    @IBAction func uploadPhotoButtonTapped() {
        present(imagePickerController, animated: true)
    }
    
    @IBAction func teamSelectButtonTapped() {
    }
    
    @IBAction func positionSelectButtonTapped() {
    }
    
    @IBAction func saveButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    // MARK: - Setup UI
    private func setupUI() {
        imagePickerController.delegate = self
    }
    
    // MARK: - Private methods
}

extension PlayerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        defer {
            imagePickerController.dismiss(animated: true)
        }
        
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        guard let image = info[convertFromUIImagePickerControllerInfoKey(.originalImage)] as? UIImage else {
            return
        }
        chosenImage = image
        photoImageView.image = image
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
