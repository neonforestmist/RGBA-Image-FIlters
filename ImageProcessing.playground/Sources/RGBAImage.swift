import UIKit

public struct Pixel {
    public var value: UInt32
    
    public var red: UInt8 {
        get { UInt8(value & 0xFF) }
        set { value = UInt32(newValue) | (value & 0xFFFFFF00) }
    }
    
    public var green: UInt8 {
        get { UInt8((value >> 8) & 0xFF) }
        set { value = (UInt32(newValue) << 8) | (value & 0xFFFF00FF) }
    }
    
    public var blue: UInt8 {
        get { UInt8((value >> 16) & 0xFF) }
        set { value = (UInt32(newValue) << 16) | (value & 0xFF00FFFF) }
    }
    
    public var alpha: UInt8 {
        get { UInt8((value >> 24) & 0xFF) }
        set { value = (UInt32(newValue) << 24) | (value & 0x00FFFFFF) }
    }
}

public struct RGBAImage {
    public var pixels: UnsafeMutableBufferPointer<Pixel>
    
    public var width: Int
    public var height: Int
    
    public init?(image: UIImage) {
        guard let cgImage = image.cgImage else { return nil }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo.byteOrder32Big.union(CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue))
        
        width = cgImage.width
        height = cgImage.height
        let bytesPerRow = width * 4
        
        let imageData = UnsafeMutablePointer<Pixel>.allocate(capacity: width * height)
        guard let context = CGContext(data: imageData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else { return nil }
        context.draw(cgImage, in: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
        
        pixels = UnsafeMutableBufferPointer<Pixel>(start: imageData, count: width * height)
    }
    
    public func toUIImage() -> UIImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo.byteOrder32Big.union(CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue))
        let bytesPerRow = width * 4
        
        guard let context = CGContext(data: pixels.baseAddress,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else { return nil }
        guard let cgImage = context.makeImage() else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
}
