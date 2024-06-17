//
//  OneCellCollectionViewCell.swift
//  FileManager
//
//  Created by Macbook on 17/06/2024.
//

import UIKit

class OneCellCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var sizeLable: UILabel!
    @IBOutlet weak var dateCreatedLable: UILabel!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
