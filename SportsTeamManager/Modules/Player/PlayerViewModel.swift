//
//  PlayerViewModel.swift
//  SportsTeamManager
//
//  Created by Evgeny Novgorodov on 05.02.2021.
//

import Foundation

// MARK: Protocols

protocol PlayerViewModelProtocol: AnyObject {
    var number: String? { get set }
    var photo: Data? { get set }
    var name: String? { get set }
    var nationality: String? { get set }
    var age: String? { get set }
    var stateSelectedSegmentIndex: Int { get set }
    var teamButtonTitle: String? { get }
    var positionButtonTitle: String { get }
    var pickerViewSelectedIndex: Int { get }
    var pickerViewNumberOfRows: Int { get }
    var pickerViewContentType: PickerViewContentType { get set }
    var isEnabledSaveButton: Bool { get }
    var buttonTitleNeedUpdating: ((String?, PickerViewContentType) -> Void)? { get set }
    
    init(player: Player?)
    
    func save()
    func pickerViewTitle(forRow: Int) -> String?
    func pickerViewDidSelectRow(at row: Int)
}

final class PlayerViewModel: PlayerViewModelProtocol {
    
    // MARK: Nested types
    
    // Для удобства отслеживания введённых данных используются опциональные свойства там, где данные могут быть не введены
    typealias PlayerDataOptional = (name: String?, number: Int16?, nationality: String?, age: Int16?,
                                    team: String?, position: String?, isInPlay: Bool, photo: Data?)
    
    // MARK: - Properties
    
    var number: String? {
        get {
            guard let int16Number = playerData.number else { return nil }
            return String(int16Number)
        } set {
            if let stringNumber = newValue?.toNumberTextFieldFiltered() {
                playerData.number = Int16(stringNumber)
            }
        }
    }
    
    var photo: Data? {
        get {
            playerData.photo ?? DataConstants.defaultPhoto
        } set {
            playerData.photo = newValue
        }
    }
    
    var name: String? {
        get {
            playerData.name
        } set {
            if let name = newValue {
                playerData.name = name
            }
        }
    }
    
    var nationality: String? {
        get {
            playerData.nationality
        } set {
            if let nationality = newValue {
                playerData.nationality = nationality
            }
        }
    }
    
    var age: String? {
        get {
            guard let int16Age = playerData.age else { return nil }
            return String(int16Age)
        } set {
            if let stringAge = newValue?.toNumberTextFieldFiltered() {
                playerData.age = Int16(stringAge)
            }
        }
    }
    
    var stateSelectedSegmentIndex: Int {
        get {
            playerData.isInPlay ? 0 : 1
        } set {
            playerData.isInPlay = newValue == 0 ? true : false
        }
    }
    
    var teamButtonTitle: String? {
        playerData.team ?? "Press to select"
    }
    
    var positionButtonTitle: String {
        playerData.position ?? "Press to select"
    }
    
    var pickerViewSelectedIndex: Int {
        pickerViewContentType == .teams
            ? teams.safeFirstIndex(of: playerData.team)
            : positions.safeFirstIndex(of: playerData.position)
    }
    
    var pickerViewNumberOfRows: Int {
        pickerViewContentType == .teams
            ? teams.count
            : positions.count
    }
    
    var isEnabledSaveButton: Bool {
        if let number = number, !number.isEmpty,
           let name = name, !name.isEmpty,
           let nationality = nationality, !nationality.isEmpty,
           let age = age, !age.isEmpty,
           let _ = playerData.team,
           let _ = playerData.position {
            return true
        } else {
            return false
        }
    }
    
    var pickerViewContentType: PickerViewContentType = .teams
    var buttonTitleNeedUpdating: ((String?, PickerViewContentType) -> Void)?
    
    private let player: Player?
    private var playerData: PlayerDataOptional
    private let teams = DataConstants.teams
    private let positions = DataConstants.positions
    private let playersDataManager: PlayersDataManagerProtocol = PlayersDataManager.shared
    
    // MARK: - Initializers
    
    required init(player: Player? = nil) {
        // Если player был передан, значит открывается вью редактирования игрока, иначе - вью создания нового
        self.player = player
        self.playerData = (
            name: player?.fullName, number: player?.number, nationality: player?.nationality,
            age: player?.age, team: player?.team?.name, position: player?.position,
            isInPlay: player?.inPlay ?? true, photo: player?.photo
        )
    }
    
    // MARK: - Public methods
    
    func save() {
        guard let name = playerData.name,
              let number = playerData.number,
              let nationality = playerData.nationality,
              let age = playerData.age,
              let team = playerData.team,
              let position = playerData.position else { return }
        
        let playerData: PlayerData = (
            name: name, number: number, nationality: nationality, age: age, team: team,
            position: position, isInPlay: self.playerData.isInPlay, photo: photo
        )
        
        // Если player = nil, то происходит создание нового игрока, иначе - редактирование игрока
        player == nil
            ? playersDataManager.createPlayer(playerData)
            : playersDataManager.updatePlayer(player!, withPlayerData: playerData)
    }
    
    func pickerViewTitle(forRow row: Int) -> String? {
        pickerViewContentType == .teams
            ? teams[safeIndex: row]
            : positions[safeIndex: row]
    }
    
    func pickerViewDidSelectRow(at row: Int) {
        if pickerViewContentType == .teams {
            playerData.team = teams[safeIndex: row] ?? ""
            buttonTitleNeedUpdating?(teams[safeIndex: row], pickerViewContentType)
        } else {
            playerData.position = positions[safeIndex: row] ?? ""
            buttonTitleNeedUpdating?(positions[safeIndex: row], pickerViewContentType)
        }
    }
}
