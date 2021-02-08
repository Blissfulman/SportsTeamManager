//
//  SearchViewModel.swift
//  SportsTeamManager
//
//  Created by Evgeny Novgorodov on 05.02.2021.
//

import Foundation

// MARK: Protocols

protocol SearchViewModelProtocol: AnyObject {
    var name: String? { get set }
    var age: String? { get set }
    var ageOperatorSelectedSegmentIndex: Int { get set }
    var teamButtonTitle: String? { get }
    var positionButtonTitle: String { get }
    var pickerViewSelectedIndex: Int { get }
    var pickerViewNumberOfRows: Int { get }
    var pickerViewContentType: PickerViewContentType { get set }
    var isEnabledStartSearchButton: Bool { get }
    var buttonTitleNeedUpdating: ((String?, PickerViewContentType) -> Void)? { get set }
    
    init(searchData: SearchData?)
    
    func startSearch()
    func resetSearchData()
    func pickerViewTitle(forRow: Int) -> String?
    func pickerViewDidSelectRow(at row: Int)
}

final class SearchViewModel: SearchViewModelProtocol {
    
    // MARK: - Properties
    
    var name: String? {
        get {
            searchData.name
        } set {
            searchData.name = newValue
        }
    }
    
    var age: String? {
        get {
            guard let int16Age = searchData.age else { return nil }
            return String(int16Age)
        } set {
            if let stringAge = newValue?.toNumberTextFieldFiltered() {
                searchData.age = Int16(stringAge)
            }
        }
    }
    
    var ageOperatorSelectedSegmentIndex: Int {
        get {
            switch searchData.ageOperator {
            case .lessOrEqual:
                return 0
            case .equal:
                return 1
            case .moreOrEqual:
                return 2
            }
        } set {
            switch newValue {
            case 0:
                searchData.ageOperator = .lessOrEqual
            case 1:
                searchData.ageOperator = .equal
            case 2:
                searchData.ageOperator = .moreOrEqual
            default:
                break
            }
        }
    }
    
    var teamButtonTitle: String? {
        searchData.team ?? "Press to select"
    }
    
    var positionButtonTitle: String {
        searchData.position ?? "Press to select"
    }
    
    var pickerViewSelectedIndex: Int {
        pickerViewContentType == .teams
            ? teams.safeFirstIndex(of: searchData.team)
            : positions.safeFirstIndex(of: searchData.position)
    }
    
    var pickerViewNumberOfRows: Int {
        pickerViewContentType == .teams
            ? teams.count
            : positions.count
    }
    
    var isEnabledStartSearchButton: Bool {
        var isEnabled = false
        
        if searchData.team != nil || searchData.position != nil {
            isEnabled = true
        } else if let name = name, !name.isEmpty {
            isEnabled = true
        } else if let age = age, !age.isEmpty {
            isEnabled = true
        }
        return isEnabled
    }
    
    var pickerViewContentType: PickerViewContentType = .teams
    var buttonTitleNeedUpdating: ((String?, PickerViewContentType) -> Void)?
    
    private var searchData: SearchData
    private let teams = DataConstants.teams
    private let positions = DataConstants.positions
    private let playersDataModel: PlayersDataModelProtocol = PlayersDataModel.shared
    
    // MARK: - Initializers
    
    required init(searchData: SearchData? = nil) {
        if let searchData = searchData {
            self.searchData = searchData
        } else {
            self.searchData = (name: nil, age: nil, ageOperator: AgeOperatorState.lessOrEqual,
                               team: nil, position: nil)
        }
    }
    
    // MARK: - Public methods
    
    func startSearch() {
        playersDataModel.searchDidUpdate(to: searchData)
    }
    
    func resetSearchData() {
        playersDataModel.resetSearchData()
    }
    
    func pickerViewTitle(forRow row: Int) -> String? {
        pickerViewContentType == .teams
            ? teams[safeIndex: row]
            : positions[safeIndex: row]
    }
    
    func pickerViewDidSelectRow(at row: Int) {
        if pickerViewContentType == .teams {
            searchData.team = teams[safeIndex: row]
            buttonTitleNeedUpdating?(teams[safeIndex: row], pickerViewContentType)
        } else {
            searchData.position = positions[safeIndex: row]
            buttonTitleNeedUpdating?(positions[safeIndex: row], pickerViewContentType)
        }
    }
}
