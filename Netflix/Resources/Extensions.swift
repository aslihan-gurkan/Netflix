//
//  Extensions.swift
//  Netflix
//
//  Created by Aslıhan Gürkan on 20.02.2023.
//

import Foundation

extension String {
    func capitalizeFirstLetter() -> String {
        return self.prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}
