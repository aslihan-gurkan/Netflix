//
//  HeroHeaderUIVİew.swift
//  Netflix
//
//  Created by Aslıhan Gürkan on 17.02.2023.
//

import UIKit

class HeaderUIView: UIView {

    private let playButton : UIButton = {
        
        let button = UIButton()
        button.setTitle("Play", for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        // cornerRadius -> reduces the sharpness of button edges.
        button.layer.cornerRadius = 5
        
        return button
        
    }()
    
    private let downloadButton : UIButton = {
        let button = UIButton()
        button.setTitle("Download", for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        //TODO: exp- translatesAutoresizingMaskIntoConstraints ->> A Boolean value that determines whether the view’s autoresizing mask is translated into Auto Layout constraints
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let headerImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "inception")
        return imageView
    }()
    
    // CAGradientLayer -> A layer that draws a color gradient over its background color, filling the shape of the layer (including rounded corners) : https://developer.apple.com/documentation/quartzcore/cagradientlayer
    //dark mode to light mode changed layer.
    private func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.systemBackground.cgColor
        ]
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(headerImageView)
        addGradient()
        addSubview(playButton)
        applyConstraints()
    }
    
    private func applyConstraints() {
        
        let playButtonConstraints = [
            playButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 70),
            playButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            playButton.widthAnchor.constraint(equalToConstant: 120)
        ]
        
        let downloadButtonConstraints = [
            downloadButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -70),
            downloadButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            downloadButton.widthAnchor.constraint(equalToConstant: 120)
        ]
        
        NSLayoutConstraint.activate(playButtonConstraints)
//        NSLayoutConstraint.activate(downloadButtonConstraints)
        
        /*
        let playButtonConstraints = [
            // leadingAnchor -> constraint of the button based on header image
            //leadingAnchor -> left edge for left-to-right and right edge for right-to-left
            playButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 70),
            // The distance from the bottom edge of the button in the header image
            //Header image'in bottom sınırıyla button arasındaki mesafe
            playButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            // width of button
            playButton.widthAnchor.constraint(equalToConstant: 120)
        ]
        
        let downloadConstraints = [
            downloadButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -70),
            downloadButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            downloadButton.widthAnchor.constraint(equalToConstant: 120)
        ]
        
        NSLayoutConstraint.activate(playButtonConstraints)
        NSLayoutConstraint.activate(downloadConstraints)
        */
    }
    
    public func configure(with model: TitleViewModel) {
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500/\(model.posterURL)") else { return }
        headerImageView.sd_setImage(with: url)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        headerImageView.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

}
