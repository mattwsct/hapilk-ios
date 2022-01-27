//
//  PointView.swift
//  Kenko
//
//  Created by David Garcia Tort on 8/14/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit

@IBDesignable
class PointView: UIView {
    
    // MARK: - Variables
    @IBInspectable
    var position: Int = 0 { didSet { setNeedsLayout() } }
    
    @IBInspectable
    var win: Bool = false { didSet { setNeedsLayout() } }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Functions
    override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }
    
    private func setupView() {
        
        // Circle
        layer.cornerRadius = bounds.height / 2
        backgroundColor = (win == true ? Colors.rankingFirst.uiColor : Colors.pointBackground.uiColor)
        translatesAutoresizingMaskIntoConstraints = false
        subviews.forEach { $0.removeFromSuperview() }
        
        if win == true {
            // Load assets
            let bundle = Bundle(for: type(of: self))
            let chrownImage = UIImage(named: "Crown", in: bundle, compatibleWith: self.traitCollection)
            let chrownImageView = UIImageView(image: chrownImage)
            chrownImageView.image = chrownImage
            
            let positionLayer = UILabel()
            positionLayer.text = String(position)
            positionLayer.tintColor = Colors.pointTintColor.uiColor
            
            // Add subviews
            addSubview(chrownImageView)
            
            // Constraints
            chrownImageView.translatesAutoresizingMaskIntoConstraints = false
            chrownImageView.heightAnchor.constraint(equalToConstant: bounds.height).isActive = true
            chrownImageView.widthAnchor.constraint(equalToConstant: bounds.width).isActive = true
            chrownImageView.contentMode = .center
        } else {
            let positionLabel = UILabel()
            positionLabel.text = String(position)
            positionLabel.textColor = Colors.pointTintColor.uiColor
            positionLabel.textAlignment = .center
            positionLabel.adjustsFontSizeToFitWidth = true
            
            addSubview(positionLabel)

            // Constraints
            positionLabel.translatesAutoresizingMaskIntoConstraints = false
            positionLabel.heightAnchor.constraint(equalToConstant: bounds.height).isActive = true
            positionLabel.widthAnchor.constraint(equalToConstant: bounds.width).isActive = true
        }
    }
    
    func animate(withDelay delay: Double) {
        UIView.animate(
            withDuration: 0,
            delay: delay,
            options: [],
            animations: {
                self.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            },
            completion: { finished in
                UIView.animate(
                    withDuration: 0.3,
                    delay: 0,
                    options: [],
                    animations: {
                        self.transform = .identity
                    },
                    completion: { finished in
                        
                })
        })
    }
}
