//
//  ToastHelper.swift
//  LookHeart 100
//
//  Created by 정연호 on 2023/10/13.
//

import Foundation
import Toast_Swift

class ToastHelper {
    
    // Singleton instance
    static let shared = ToastHelper()
    
    private init() {
        var style = ToastStyle()
        style.messageColor = .white
        ToastManager.shared.style = style
        ToastManager.shared.isTapToDismissEnabled = true
        ToastManager.shared.isQueueEnabled = true
    }
            
    func showToast(_ view: UIView, _ message: String, withDuration: Double, delay: Double) {
        let toastContainer = UIView(frame: CGRect())
        toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastContainer.layer.cornerRadius = 10
        toastContainer.clipsToBounds = true
        
        let iconImageView = UIImageView(image: UIImage(named: "toast_icon")!)
        let iconSize: CGFloat = 25
        let iconPadding: CGFloat = 10
        iconImageView.frame = CGRect(x: iconPadding, y: 5, width: iconSize, height: iconSize)
        iconImageView.contentMode = .scaleAspectFit
        
        let toastLabel = UILabel()
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont.systemFont(ofSize: 16.0)
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.numberOfLines = 0

        toastContainer.addSubview(iconImageView)
        toastContainer.addSubview(toastLabel)

        // 토스트 컨테이너 크기 조정
        let containerWidth: CGFloat = view.frame.width - 60
        let containerHeight: CGFloat = 35
        toastContainer.frame = CGRect(x: (view.frame.size.width - containerWidth) / 2,
                                      y: (view.frame.size.height - 120),
                                      width: containerWidth,
                                      height: containerHeight)

        // 레이블 위치 조정
        let labelX: CGFloat = iconImageView.frame.maxX + iconPadding
        toastLabel.frame = CGRect(x: labelX, y: 5,
                                  width: toastContainer.frame.size.width - labelX - iconPadding,
                                  height: 25)

        view.addSubview(toastContainer)

        UIView.animate(withDuration: withDuration, delay: delay, options: .curveEaseOut, animations: {
            toastContainer.alpha = 0.0
        }, completion: {(isCompleted) in
            toastContainer.removeFromSuperview()
        })
    }
}
