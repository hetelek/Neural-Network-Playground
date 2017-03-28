import UIKit

public extension UIImage {
    public convenience init(view: UIView) {
        // draw view in context
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        // get image, return
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
    
    public func resize(newSize: CGSize) -> UIImage {
        // create context - make sure we are on a 1.0 scale
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0);
        
        // draw with new size, get image, and return
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return newImage!
    }
    
    public func grayScalePixelIntensities() -> [Double] {
        var pixels: [Double] = []
        
        // First get the image into your data buffer
        guard let cgImage = cgImage else {
            return pixels
        }
        
        // get image dimensions
        let width = cgImage.width
        let height = cgImage.height
        let pixelCount = width * height
        
        // calculate context information
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let rawData = calloc(height * width * 4, MemoryLayout<CUnsignedChar>.size)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let bitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        
        guard let context = CGContext(data: rawData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return pixels
        }
        
        // draw image in new context
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // loop each pixel and get as gray float (average of RGB, scaled between 0 and 1)
        var byteIndex = 0
        for _ in 0..<pixelCount {
            // get and scale pixels
            let red = CGFloat(rawData!.load(fromByteOffset: byteIndex, as: UInt8.self)) / 255.0
            let green = CGFloat(rawData!.load(fromByteOffset: byteIndex + 1, as: UInt8.self)) / 255.0
            let blue = CGFloat(rawData!.load(fromByteOffset: byteIndex + 2, as: UInt8.self)) / 255.0
            
            // take average
            let pixel = Double(red + green + blue) / 3.0
            pixels.append(pixel)
            
            // increment address for next cycle
            byteIndex += bytesPerPixel
        }
        
        // free and return grayscale pixels
        free(rawData)
        return pixels
    }
}
