import Foundation
import libwebp

#if os(macOS) || os(iOS)
import CoreGraphics

extension WebPDecoder {
    public func decode(_ webPData: Data, options: WebPDecoderOptions) throws -> CGImage {
        let feature = try WebPImageInspector.inspect(webPData)
        let height: Int = options.useScaling ? options.scaledHeight : feature.height
        let width: Int = options.useScaling ? options.scaledWidth : feature.width

        let decodedData: CFData = try decode(byRGBA: webPData, options: options) as CFData
        guard let provider = CGDataProvider(data: decodedData) else {
            throw WebPError.unexpectedError(withMessage: "Couldn't initialize CGDataProvider")
        }
        
        let bitmapInfo: CGBitmapInfo
        let bytesPerPixel = 4
        if feature.hasAlpha {
            bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.last.rawValue)
        } else {
            bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.noneSkipLast.rawValue)
        }
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        if let cgImage = CGImage(width: width,
                                 height: height,
                                 bitsPerComponent: 8,
                                 bitsPerPixel: 8 * bytesPerPixel,
                                 bytesPerRow: bytesPerPixel * width,
                                 space: colorSpace,
                                 bitmapInfo: bitmapInfo,
                                 provider: provider,
                                 decode: nil,
                                 shouldInterpolate: false,
                                 intent: .defaultIntent) {
            return cgImage
        }

        throw WebPError.unexpectedError(withMessage: "Couldn't initialize CGImage")
    }
    
    public func decodei(_ webPData: Data, options: WebPDecoderOptions) throws -> CGImage {
        let feature = try WebPImageInspector.inspect(webPData)
        let height: Int = options.useScaling ? options.scaledHeight : feature.height
        let width: Int = options.useScaling ? options.scaledWidth : feature.width

        let decodedi = try decodei(byRGBA: webPData, options: options)
        let decodedData: CFData = decodedi.data as CFData
        guard let provider = CGDataProvider(data: decodedData) else {
            throw WebPError.unexpectedError(withMessage: "Couldn't initialize CGDataProvider")
        }

        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let last_y = decodedi.last_y
        if let image = CGImage(
            width: Int(width),
            height: Int(last_y),
            bitsPerComponent: 8,
            bitsPerPixel: bytesPerPixel * 8,
            bytesPerRow: bytesPerPixel * Int(width),
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        ) {
          let canvasColorSpaceRef = CGColorSpaceCreateDeviceRGB()
          if let canvas = CGContext(
            data: nil,
            width: Int(width),
            height: Int(height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: canvasColorSpaceRef,
            bitmapInfo: bitmapInfo.rawValue
          ) {
              canvas.draw(image,
                          in: .init(x: 0, y: Int(height) - Int(last_y), width: Int(width), height: Int(last_y)))
            if let newImageRef = canvas.makeImage() {
              return newImageRef
            }
          }
        }

        throw WebPError.unexpectedError(withMessage: "Couldn't initialize CGImage")
    }
}
#endif

#if os(iOS)
import UIKit

extension WebPDecoder {
    public func decode(toUImage webPData: Data, options: WebPDecoderOptions) throws -> UIImage {
        let cgImage: CGImage = try decode(webPData, options: options)
        return UIImage(cgImage: cgImage)
    }
    
    public func decodei(toUImage webPData: Data, options: WebPDecoderOptions) throws -> UIImage {
        let cgImage: CGImage = try decodei(webPData, options: options)
        return UIImage(cgImage: cgImage)
    }
}
#endif

#if os(macOS)
import AppKit

extension WebPDecoder {
    public func decode(toNSImage webPData: Data, options: WebPDecoderOptions) throws -> NSImage {
        let cgImage: CGImage = try decode(webPData, options: options)
        return NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
    }
    
    public func decodei(toNSImage webPData: Data, options: WebPDecoderOptions) throws -> NSImage {
        let cgImage: CGImage = try decodei(webPData, options: options)
        return NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
    }
}
#endif
