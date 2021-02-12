//
//  UIScrollView+IsNearBottomEdge.swift
//  News List
//
//  Created by Andrian Nebeso on 2/13/21.
//

import UIKit

extension UIScrollView {
    func isNearBottomEdge(distance: CGFloat) -> Bool {
        let y = contentOffset.y + bounds.size.height - contentInset.bottom
        let height = contentSize.height
        let reloadDistance: CGFloat = distance
        
        return y > (height + reloadDistance) // TODO: check >=
    }
}
