//
//  QRCodeHelper.swift
//  
//
//  Created by Arturo Jamaica on 2022/02/20.
//
#if canImport(UIKit)
#if canImport(CoreImage)
import Foundation
import UIKit
import CoreImage

class QRCodeHelper {
    func generateQRCode(from url: URL) -> UIImage? {
        let data = url.absoluteString.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
}
#endif
#endif
