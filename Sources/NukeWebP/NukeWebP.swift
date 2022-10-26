import Nuke
import Foundation

#if !os(macOS)
import UIKit.UIImage
#else
import AppKit.NSImage
#endif

#if os(watchOS)
import ImageIO
import CoreGraphics
import WatchKit.WKInterfaceDevice
#endif

public protocol WebPDecoding: Sendable {
  func decode(data: Data) throws -> CGImage
  func decodei(data: Data) throws -> CGImage
}

private let _queue = DispatchQueue(label: "com.webp.decoder", autoreleaseFrequency: .workItem)

public final class WebPImageDecoder: ImageDecoding, @unchecked Sendable {
  
  private let decoder: WebPDecoding
  private let context: ImageDecodingContext
  
  public init(decoder: WebPDecoding, context: ImageDecodingContext) {
    self.decoder = decoder
    self.context = context
  }
  private var defaultScale: CGFloat {
#if os(iOS) || os(tvOS)
    return UIScreen.main.scale
#elseif os(watchOS)
    return WKInterfaceDevice.current().screenScale
#elseif os(macOS)
    return 1
#endif
  }
  
  private var scale: CGFloat {
    context.request.userInfo[.scaleKey] as? CGFloat ?? defaultScale
  }
  
  public func decode(_ data: Data) throws -> ImageContainer {
    return try _queue.sync(execute: {
      let cgImage = try decoder.decode(data: data)
#if !os(macOS)
      let image = PlatformImage(cgImage: cgImage, scale: scale, orientation: .up)
#else
      let image = PlatformImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
#endif
      return ImageContainer(image: image, type: .webp, data: data)
    })
    
  }
  
  public func decodePartiallyDownloadedData(_ data: Data) -> ImageContainer? {
    do {
      return try _queue.sync(execute: {
        let cgImage = try decoder.decodei(data: data)
#if !os(macOS)
        let image = PlatformImage(cgImage: cgImage, scale: scale, orientation: .up)
#else
        let image = PlatformImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
#endif
        return ImageContainer(image: image, type: .webp, data: data)
      })
    } catch {
      return nil
    }
  }
}

// MARK: - check webp format data.
extension WebPImageDecoder {
  
  public static func enable(closure: @escaping () -> WebPDecoding) {
    Nuke.ImageDecoderRegistry.shared.register { (context) -> ImageDecoding? in
      WebPImageDecoder.enable(context: context, closure: closure)
    }
  }
  
  public static func enable(auto closure: @escaping @autoclosure () -> WebPDecoding) {
    Nuke.ImageDecoderRegistry.shared.register { (context) -> ImageDecoding? in
      WebPImageDecoder.enable(context: context, closure: closure)
    }
  }
  public static func enable(context: ImageDecodingContext, closure: @escaping () -> WebPDecoding) -> Nuke.ImageDecoding? {
    /// Use native WebP decoder for decode image
    if #available(OSX 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
      return nil
    } else {
      let type = AssetType(context.data)
      if type == .webp {
        return WebPImageDecoder(decoder: closure(), context: context)
      }
    }
    return nil
  }
}

