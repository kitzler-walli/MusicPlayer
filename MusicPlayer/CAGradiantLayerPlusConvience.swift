//
//  CAGradiantLayerPlusConvience.swift
//  MusicPlayer
//
//  Created by Geemakun Storey on 2016-12-29.
//  Copyright © 2016 geemakunstorey@storeyofgee.com. All rights reserved.
//

import UIKit

extension CAGradientLayer {
    func newColor() -> CAGradientLayer {
        let topColor = UIColor(red: (14/255.0), green: (48/255.0), blue: (94/255.0), alpha: 1)
        let bottomColor = UIColor(red: (44/255.0), green: (130/255.0), blue: (189/255.0), alpha: 1)
        
        let gradientColor: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        let gradientLocations: [Float] = [0.0, 1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColor
        gradientLayer.locations = gradientLocations as [NSNumber]?
        
        return gradientLayer
}
}
