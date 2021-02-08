//
//  String+Extension.swift
//  SportsTeamManager
//
//  Created by Evgeny Novgorodov on 30.01.2021.
//

extension String {
    
    /// Фильтрация нецифровых символов и ограничение длины строки. Ограничение длины строки по умолчанию равно 3.
    func toNumberTextFieldFiltered(prefixMaxLength: Int = 3) -> String {
        let filteredString = self.filter { "0123456789".contains($0) }
        return String(filteredString.prefix(3))
    }
}
