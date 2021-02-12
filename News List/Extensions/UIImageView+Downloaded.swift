//
//  UIImageView+Downloaded.swift
//  News List
//
//  Created by Andrian Nebeso on 2/12/21.
//

import UIKit

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let imageCache = appDelegate.imageCache
        let imageKey = url.absoluteString as NSString
        
        if let image = imageCache.object(forKey: imageKey) {
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        } else {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                    else { return }
                
                DispatchQueue.main.async() { [weak self] in
                    self?.image = image
                }
            }.resume()
        }
    }
}
