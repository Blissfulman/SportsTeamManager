//
//  Collection+Extension.swift
//  SportsTeamManager
//
//  Created by Evgeny Novgorodov on 26.01.2021.
//

extension Collection {
    
    /// Возвращает элемент по указанному индексу, если он находится в пределах диапазона, в противном случае - nil.
    subscript(safeIndex index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
