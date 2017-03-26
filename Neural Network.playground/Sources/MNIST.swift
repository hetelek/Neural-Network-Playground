import Foundation
import UIKit
import PlaygroundSupport

internal class Reader {
    let handle: FileHandle
    init?(url: URL) {
        guard let handle = try? FileHandle(forReadingFrom: url) else {
            return nil
        }
        
        self.handle = handle
    }
    
    func goTo(offset: UInt64) {
        handle.seek(toFileOffset: offset)
    }
    
    func readInt32() -> Int32 {
        var num: Int32 = -1
        
        let data = handle.readData(ofLength: 4) as NSData
        data.getBytes(&num, length: 4)
        
        return num.bigEndian
    }
    
    func readBytes(count: Int) -> Data {
        return handle.readData(ofLength: count)
    }
}

public class MNIST {
    private let reader: Reader
    private let imageCount: Int32
    private let rowCount: Int32
    private let columnCount: Int32
    private var imageByteCount: UInt64 {
        get {
            return UInt64(rowCount) * UInt64(columnCount)
        }
    }
    private let imageStartOffset: UInt64 = 16
    
    public init?(url: URL) {
        guard let reader = Reader(url: url) else {
            return nil
        }
        self.reader = reader
        
        // ensure this is a MNIST file
        guard reader.readInt32() == 2051 else {
            return nil
        }
        
        imageCount = reader.readInt32()
        rowCount = reader.readInt32()
        columnCount = reader.readInt32()
    }
    
    public func getImage() -> ([Double], UIImage) {
        let imageNumber = UInt64(arc4random_uniform(UInt32(imageCount)))
        let imageOffset = imageStartOffset + imageNumber * imageByteCount
        
        reader.goTo(offset: imageOffset)
        let pixels = reader.readBytes(count: Int(imageByteCount))
        let pixelIntensity = pixels.map { Double($0) / 255.0 }
        return (pixelIntensity, imageFromPixelData(pixels: pixels, width: Int(columnCount), height: Int(rowCount))!)
    }
    
    private func imageFromPixelData(pixels: Data, width: Int, height: Int) -> UIImage? {
        var extendedData = Data(capacity: pixels.count * 4)
        pixels.forEach { pixel in
            extendedData.append(255)
            for _ in 0..<3 {
                extendedData.append(pixel)
            }
        }
        
        let providerRef = CGDataProvider(data: extendedData as CFData)
        let cgim = CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo.byteOrder32Little, provider: providerRef!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        return UIImage(cgImage: cgim!)
    }
}
