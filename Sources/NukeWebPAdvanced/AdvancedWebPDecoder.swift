import libwebp
import NukeWebP
import Foundation

#if !os(macOS)
import UIKit.UIImage
#else
import AppKit.NSImage
#endif

public final class AdvancedWebPDecoder: WebPDecoding, @unchecked Sendable {
  
  private lazy var decoder: WebPDecoder = WebPDecoder()
  private let options: WebPDecoderOptions
  
  public init(options: WebPDecoderOptions = .init()) {
    self.options = options
  }
  
  public func decode(data: Data) throws -> ImageType {
#if !os(macOS)
    return try decoder.decode(toUImage: data, options: options)
#else
    return try decoder.decode(toNSImage: data, options: options)
#endif
  }
  
  public func decodei(data: Data) throws -> ImageType {
#if !os(macOS)
    return try decoder.decodei(toUImage: data, options: options)
#else
    return try decoder.decodei(toNSImage: data, options: options)
#endif
  }
}
