//
//  SearchResultTableViewCell.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/07.
//

import UIKit

final class SearchResultTableViewCell: UITableViewCell {

    static let identifier = "SearchResultTableViewCell"

    // MARK: - Init    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
