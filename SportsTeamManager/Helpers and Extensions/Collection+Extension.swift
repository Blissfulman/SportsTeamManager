//
//  Collection+Extension.swift
//  SportsTeamManager
//
//  Created by User on 26.01.2021.
//

import Foundation

extension Collection {
    
    /// Возвращает элемент по указанному индексу, если он находится в пределах диапазона, в противном случае - nil.
    subscript(safeIndex index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}