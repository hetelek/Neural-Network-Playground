import Foundation
import UIKit
import PlaygroundSupport

internal class Reader {
    let handle: FileHandle
    init?(url: URL) {
        // get file handle and set it
        guard let handle = try? FileHandle(forReadingFrom: url) else {
            return nil
        }
        self.handle = handle
    }
    
    func goTo(offset: UInt64) {
        handle.seek(toFileOffset: offset)
    }
    
    func readInt32() -> Int32 {
        // create variable to hold value
        var num: Int32 = -1
        
        // read 4 bytes for Int32
        let data = handle.readData(ofLength: 4) as NSData
        data.getBytes(&num, length: 4)
        
        // return in proper order
        return num.bigEndian
    }
    
    func readBytes(count: Int) -> Data {
        return handle.readData(ofLength: count)
    }
}

public class MNIST {
    // MNIST file format is described at: http://yann.lecun.com/exdb/mnist/.
    
    // MARK: - Private properties
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
    
    
    // MARK: - Public properties
    public init?(url: URL) {
        guard let reader = Reader(url: url) else {
            return nil
        }
        self.reader = reader
        
        // ensure this is a MNIST file
        guard reader.readInt32() == 2051 else {
            return nil
        }
        
        // read number of images and sizes
        imageCount = reader.readInt32()
        rowCount = reader.readInt32()
        columnCount = reader.readInt32()
    }
    
    
    // MARK: - Private properties
    public func getImage() -> ([Double], UIImage) {
        // get a random image offset
        let imageNumber = UInt64(arc4random_uniform(UInt32(imageCount)))
        let imageOffset = imageStartOffset + imageNumber * imageByteCount
        
        // read the image, get intensities
        reader.goTo(offset: imageOffset)
        let pixels = reader.readBytes(count: Int(imageByteCount))
        let pixelIntensity = pixels.map { Double($0) / 255.0 }
        
        // return the raw pixel intesities, and the actual UIImage
        return (pixelIntensity, imageFromPixelData(pixels: pixels, width: Int(columnCount), height: Int(rowCount))!)
    }
    
    
    // MARK: - Image helpers
    private func imageFromPixelData(pixels: Data, width: Int, height: Int) -> UIImage? {
        // allocate the data (4 bytes per pixel - RGBA)
        var extendedData = Data(capacity: pixels.count * 4)
        
        // populate the data
        pixels.forEach { pixel in
            extendedData.append(255)
            for _ in 0..<3 {
                extendedData.append(pixel)
            }
        }
        
        // create image form data
        let providerRef = CGDataProvider(data: extendedData as CFData)
        let cgim = CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo.byteOrder32Little, provider: providerRef!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        return UIImage(cgImage: cgim!)
    }
}
