import Foundation
import libwebp

/// There's no definition of WebPDecodingError in libwebp.
/// We map VP8StatusCode enum as WebPDecodingError instead.
public enum WebPDecodingError: UInt32, Error {
    case ok = 0  // shouldn't be used as this is the succseed case
    case outOfMemory
    case invalidParam
    case bitstreamError
    case unsupportedFeature
    case suspended
    case userAbort
    case notEnoughData
    case unknownError = 9999 // This is an own error to deal with internal problems
}

public struct WebPDecoder {
    public init() {
    }
    
    public func decode(byRGB webPData: Data, options: WebPDecoderOptions) throws -> Data {
        var config = makeConfig(options, .RGB)
        try decode(webPData, config: &config)
        
        return Data(bytesNoCopy: config.output.u.RGBA.rgba,
                    count: config.output.u.RGBA.size,
                    deallocator: .free)
    }
    
    public func decode(byRGBA webPData: Data, options: WebPDecoderOptions) throws -> Data {
        var config = makeConfig(options, .RGBA)
        try decode(webPData, config: &config)
        
        return Data(bytesNoCopy: config.output.u.RGBA.rgba,
                    count: config.output.u.RGBA.size,
                    deallocator: .free)
    }
    
    public func decodei(byRGBA webPData: Data, options: WebPDecoderOptions) throws -> (data: Data, last_y: Int) {
        var config = makeConfig(options, .RGBA)
        try decodei(webPData, config: &config)
        if let rgba = config.output.u.RGBA.rgba {
            let data = Data(bytesNoCopy: rgba,
                            count: config.output.u.RGBA.size,
                            deallocator: .free)
            return (data: data, last_y: config.output.height)
        } else {
            throw WebPDecodingError.unknownError
        }
    }
    
    public func decode(byBGR webPData: Data, options: WebPDecoderOptions,
                       width: Int, height: Int) throws -> Data {
        var config = makeConfig(options, .BGR)
        try decode(webPData, config: &config)
        
        return Data(bytesNoCopy: config.output.u.RGBA.rgba,
                    count: config.output.u.RGBA.size,
                    deallocator: .free)
    }
    
    public func decode(byBGRA webPData: Data, options: WebPDecoderOptions) throws -> Data {
        var config = makeConfig(options, .BGRA)
        try decode(webPData, config: &config)
        
        return Data(bytesNoCopy: config.output.u.RGBA.rgba,
                    count: config.output.u.RGBA.size,
                    deallocator: .free)
    }
    
    public func decode(byARGB webPData: Data, options: WebPDecoderOptions) throws -> Data {
        var config = makeConfig(options, .ARGB)
        try decode(webPData, config: &config)
        
        return Data(bytesNoCopy: config.output.u.RGBA.rgba,
                    count: config.output.u.RGBA.size,
                    deallocator: .free)
    }
    
    public func decode(byRGBA4444 webPData: Data, options: WebPDecoderOptions) throws -> Data {
        
        var config = makeConfig(options, .RGBA4444)
        try decode(webPData, config: &config)
        
        return Data(bytesNoCopy: config.output.u.RGBA.rgba,
                    count: config.output.u.RGBA.size,
                    deallocator: .free)
    }
    
    public func decode(byRGB565 webPData: Data, options: WebPDecoderOptions) throws -> Data {
        var config = makeConfig(options, .RGB565)
        try decode(webPData, config: &config)
        
        return Data(bytesNoCopy: config.output.u.RGBA.rgba,
                    count: config.output.u.RGBA.size,
                    deallocator: .free)
    }
    
    public func decode(byrgbA webPData: Data, options: WebPDecoderOptions) throws -> Data {
        var config = makeConfig(options, .rgbA)
        try decode(webPData, config: &config)
        
        return Data(bytesNoCopy: config.output.u.RGBA.rgba,
                    count: config.output.u.RGBA.size,
                    deallocator: .free)
    }
    
    public func decode(bybgrA webPData: Data, options: WebPDecoderOptions) throws -> Data {
        var config = makeConfig(options, .bgrA)
        try decode(webPData, config: &config)
        
        return Data(bytesNoCopy: config.output.u.RGBA.rgba,
                    count: config.output.u.RGBA.size,
                    deallocator: .free)
    }
    
    public func decode(byArgb webPData: Data, options: WebPDecoderOptions) throws -> Data {
        var config = makeConfig(options, .Argb)
        try decode(webPData, config: &config)
        
        return Data(bytesNoCopy: config.output.u.RGBA.rgba,
                    count: config.output.u.RGBA.size,
                    deallocator: .free)
    }
    
    public func decode(byrgbA4444 webPData: Data, options: WebPDecoderOptions) throws -> Data {
        var config = makeConfig(options, .rgbA4444)
        try decode(webPData, config: &config)
        
        return Data(bytesNoCopy: config.output.u.RGBA.rgba,
                    count: config.output.u.RGBA.size,
                    deallocator: .free)
    }
    
    public func decode(byYUV webPData: Data, options: WebPDecoderOptions) throws -> Data {
        fatalError("didn't implement this yet")
    }
    
    public func decode(byYUVA webPData: Data, options: WebPDecoderOptions) throws -> Data {
        fatalError("didn't implement this yet")
    }
    
    private func decode(_ webPData: Data, config: inout WebPDecoderConfig) throws {
        var mutableWebPData = webPData
        var rawConfig: libwebp.WebPDecoderConfig = config.rawValue
        
        try mutableWebPData.withUnsafeMutableBytes { rawPtr in
            
            guard let bindedBasePtr = rawPtr.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                throw WebPDecodingError.unknownError
            }
            
            let status = WebPDecode(bindedBasePtr, webPData.count, &rawConfig)
            if status != VP8_STATUS_OK {
                throw WebPDecodingError(rawValue: status.rawValue)!
            }
        }
        
        switch config.output.u {
        case .RGBA:
            config.output.u = WebPDecBuffer.Colorspace.RGBA(rawConfig.output.u.RGBA)
        case .YUVA:
            config.output.u = WebPDecBuffer.Colorspace.YUVA(rawConfig.output.u.YUVA)
        }
    }
    
    internal func decodei(_ webPData: Data, config: inout WebPDecoderConfig) throws {
        var mutableWebPData = webPData
        
        try mutableWebPData.withUnsafeMutableBytes { rawPtr in
            
            guard let bindedBasePtr = rawPtr.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                throw WebPDecodingError.unknownError
            }
            let idec = WebPINewRGB(MODE_rgbA, nil, 0, 0)
            let status = WebPIUpdate(idec, bindedBasePtr, webPData.count)
            if status != VP8_STATUS_OK && status != VP8_STATUS_SUSPENDED {
                throw WebPDecodingError.unknownError
            }
            var width: Int32 = 0
            var height: Int32 = 0
            var last_y: Int32 = 0
            var stride: Int32 = 0
            guard let rgba = WebPIDecGetRGB(idec, &last_y, &width, &height, &stride) else {
                throw WebPDecodingError.unknownError
            }
            let rgbaSize = stride * last_y
            let buff = WebPRGBABuffer(rgba: rgba, stride: stride, size: Int(rgbaSize))
            config.output.u = WebPDecBuffer.Colorspace.RGBA(buff)
            config.output.height = Int(last_y)
            config.output.width = Int(width)
        }
    }
    
    internal func makeConfig(_ options: WebPDecoderOptions,
                            _ colorspace: ColorspaceMode) -> WebPDecoderConfig {
        var config = WebPDecoderConfig()
        config.options = options
        config.output.colorspace = colorspace
        return config
    }
}
