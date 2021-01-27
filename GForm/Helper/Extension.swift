//
//  Extension.swift
//  GForm
//
//  Created by Kennan Trevyn Zenjaya on 01/01/21.
//

import LBTAComponents

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

func setTitle(title:String, subtitle:String) -> UIView {
    let titleLabel = UILabel(frame: CGRect(x: 0,y: -2, width: 0, height:  0))

    titleLabel.backgroundColor = .clear
    titleLabel.textColor = .label
    titleLabel.font = UIFont.systemFont(ofSize: sixteen, weight: .bold)
    titleLabel.text = title
    titleLabel.sizeToFit()

    let subtitleLabel = UILabel(frame: CGRect(x: 0, y: eighteen, width: 0, height: 0))
    subtitleLabel.backgroundColor = .clear
    subtitleLabel.textColor = .secondaryLabel
    subtitleLabel.font = UIFont.systemFont(ofSize: twelve, weight: .regular)
    subtitleLabel.text = subtitle
    subtitleLabel.sizeToFit()

    let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height: thirty))
    titleView.addSubview(titleLabel)
    titleView.addSubview(subtitleLabel)

    let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width

    if widthDiff < 0 {
        let newX = widthDiff / 2
        subtitleLabel.frame.origin.x = abs(newX)
    } else {
        let newX = widthDiff / 2
        titleLabel.frame.origin.x = newX
    }

    return titleView
}

func hexStringFromColor(color: UIColor) -> String {
    let components = color.cgColor.components
    let r: CGFloat = components?[0] ?? 0.0
    let g: CGFloat = components?[1] ?? 0.0
    let b: CGFloat = components?[2] ?? 0.0

    let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
    print(hexString)
    return hexString
}
