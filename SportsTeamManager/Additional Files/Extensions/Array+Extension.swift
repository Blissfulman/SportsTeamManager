//
//  Array+Extension.swift
//  SportsTeamManager
//
//  Created by Evgeny Novgorodov on 02.02.2021.
//

extension Array {
    
    /// Возвращает индекс первого элемента с переданным значением в массиве строковых элементов.
    /// В случае отсутствия искомого элемента, или если переданный параметр равен nil, вернётся 0.
    func safeFirstIndex(of element: Element?) -> Int where Element == String {
        guard let element = element else { return 0 }
        return firstIndex(of: element) ?? 0
    }
}
