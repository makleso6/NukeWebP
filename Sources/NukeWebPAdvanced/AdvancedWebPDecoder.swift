import libwebp
import NukeWebP
import Foundation
import CoreGraphics

public final class AdvancedWebPDecoder: WebPDecoding, @unchecked Sendable {
  
  private lazy var decoder: WebPDecoder = WebPDecoder()
  private let options: WebPDecoderOptions
  
  public init(options: WebPDecoderOptions = .init()) {
    self.options = options
  }
  
  public func decode(data: Data) throws -> CGImage {
      return try decoder.decode(data, options: options)
  }
  
  public func decodei(data: Data) throws -> CGImage {
      return try decoder.decodei(data, options: options)
  }
}
