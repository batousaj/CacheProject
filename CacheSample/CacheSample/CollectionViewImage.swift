//
//  CollectionViewImage.swift
//  CacheSample
//
//  Created by Mac Mini 2021_1 on 17/09/2022.
//

import Foundation
import UIKit

class CollectionViewImage : UICollectionViewCell {
    
    var titleLabel = UILabel()
    var imageView = UIImageView()
    
    public var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    public var image: UIImage? {
        didSet {
            DispatchQueue.main.async {
                self.imageView.image = self.image
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.imageView.backgroundColor = .blue
        self.imageView.layer.borderWidth = 1.0
//        self.titleLabel.backgroundColor = .gray
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(imageView)
        
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let contraints1 = [
            self.imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
            self.imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 30),
            self.imageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -30),
            self.imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -60)
        ]
        NSLayoutConstraint.activate(contraints1)
        
        let contraints2 = [
            self.titleLabel.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 10),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 30),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -30),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10)
        ]
        
        NSLayoutConstraint.activate(contraints2)
    }
    
}
