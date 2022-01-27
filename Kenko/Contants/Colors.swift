//
//  Colors.swift
//  Kenko
//
//  Created by David Garcia Tort on 8/2/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import Foundation
import UIKit

enum Colors {
    case lightOrange
    case darkOrange
    case lightBlue
    case darkBlue
    case rankingFirst
    case rankingSecond
    case rankingThird
    case pointBackground
    case pointTintColor
    
    var cgColor: CGColor {
        switch self {
        case .lightOrange: return #colorLiteral(red: 1, green: 0.5490196078, blue: 0.3921568627, alpha: 1)
        case .darkOrange: return #colorLiteral(red: 1, green: 0.5166268945, blue: 0.3438721001, alpha: 1)
        case .lightBlue: return #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        case .darkBlue: return #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        case .rankingFirst: return #colorLiteral(red: 0.1115803495, green: 0.4634582996, blue: 0.9988313317, alpha: 1)
        case .rankingSecond: return #colorLiteral(red: 0.3868731856, green: 0.6548099518, blue: 0.9990035892, alpha: 1)
        case .rankingThird: return #colorLiteral(red: 0.7056279778, green: 0.8324415088, blue: 0.9992210269, alpha: 1)
        case .pointBackground: return #colorLiteral(red: 0.948936522, green: 0.9490728974, blue: 0.9489067197, alpha: 1)
        case .pointTintColor: return #colorLiteral(red: 0.7999292016, green: 0.8000454307, blue: 0.7999040484, alpha: 1)
        }
    }
    
    var uiColor: UIColor {
        return UIColor(cgColor: self.cgColor)
    }
}
