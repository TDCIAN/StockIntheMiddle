//
//  UIImageView+.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2023/05/03.
//

import UIKit

extension UIImageView {

    func setImage(with url: URL?) {
        guard let url = url else { return }
        DispatchQueue.global(qos: .userInteractive).async {
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self?.image = UIImage(data: data)
                }
            }
            task.resume()
        }
    }
}
