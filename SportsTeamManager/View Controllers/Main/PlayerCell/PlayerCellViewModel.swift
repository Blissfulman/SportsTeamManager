//
//  PlayerCellViewModel.swift
//  SportsTeamManager
//
//  Created by Evgeny Novgorodov on 05.02.2021.
//

import Foundation

protocol PlayerCellViewModelProtocol {
    var photo: Data? { get }
    var number: String? { get }
    var name: String? { get }
    var state: String? { get }
    var team: String? { get }
    var nationality: String? { get }
    var position: String? { get }
    var age: String? { get }
    var isInPlay: Bool { get }
    
    init(player: Player)
}

class PlayerCellViewModel: PlayerCellViewModelProtocol {
    var photo: Data? {
        player.photo
    }
    
    var number: String? {
        String(player.number)
    }
    
    var name: String? {
        player.fullName
    }
    
    var state: String? {
        player.inPlay ? FilterState.inPlay.rawValue : FilterState.bench.rawValue
    }
    
    var team: String? {
        player.team?.name
    }
    
    var nationality: String? {
        player.nationality
    }
    
    var position: String? {
        player.position
    }
    
    var age: String? {
        String(player.age)
    }
    
    var isInPlay: Bool {
        player.inPlay
    }
    
    private let player: Player
    
    required init(player: Player) {
        self.player = player
    }
}
