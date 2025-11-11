import UIKit

//loads image

let image = UIImage(named: "sample")
let imageRGBA = RGBAImage(image: image!)

let x = imageRGBA!.width/2
let y = imageRGBA!.height/2

let index = y * imageRGBA!.width + x

// defining a simple Filter type
public struct Filter {
    public let name: String
    public let apply: (_ rgba: RGBAImage, _ strength: Double) -> RGBAImage

    public init(name: String, apply: @escaping (_ rgba: RGBAImage, _ strength: Double) -> RGBAImage) {
        self.name = name
        self.apply = apply
    }
}

// main function to apply filters, taking in bool parameteres for filter handling
public struct ImageProcessor {
    public func filteredImage(
        negativeFilter: String,  negativeStrength: Double,
        freezeFilter: String,    freezeStrength: Double,
        grayscaleFilter: String,  grayscaleStrength: Double,
        sepiaFilter: String,  sepiaStrength: Double,
        dimFilter: String,     dimStrength: Double
    ) -> RGBAImage? {
        var output: RGBAImage? = RGBAImage(image: image!)
        
        if (negativeFilter == "Negative Filter") {
            if (negativeStrength > 0) {
                output = applyNegative(output, strength: negativeStrength)
            }
        }
        if (freezeFilter == "Freeze Filter") {
            if (freezeStrength > 0) {
                output = applyFreeze(output, strength: freezeStrength)
            }
        }
        if (grayscaleFilter == "Grayscale Filter") {
            if (grayscaleStrength > 0) {
                output = applyGrayscale(output, strength: grayscaleStrength)
            }
        }
        if (sepiaFilter == "Sepia Filter") {
            if (sepiaStrength > 0) {
                output = applySepia(output, strength: sepiaStrength)
            }
        }
        if (dimFilter == "Dim Filter") {
            if (dimStrength > 0) {
                output = applyDimBrightness(output, strength: dimStrength)
            }
        }
        
        return output
    }
    
    // function that serves as a pipeline to apply a series of named filters to an image in sequence, as well as defining default values for strengths
    public func filteredImage(filterNames: [String]) -> RGBAImage? {
        let defaultStrengths: [String: Double] = [
            "Negative Filter": 1.0,
            "Freeze Filter": 1.0,
            "Grayscale Filter": 1.0,
            "Sepia Filter": 1.0,
            "Dim Filter": 1.0
        ]

        var output = RGBAImage(image: image!)
        for name in filterNames {
            let strength = defaultStrengths[name] ?? 1.0
            switch name {
            case "Negative Filter":
                output = applyNegative(output, strength: strength)
            case "Freeze Filter":
                output = applyFreeze(output, strength: strength)
            case "Grayscale Filter":
                output = applyGrayscale(output, strength: strength)
            case "Sepia Filter":
                output = applySepia(output, strength: strength)
            case "Dim Filter":
                output = applyDimBrightness(output, strength: strength)
            default:
                continue
            }
        }
        return output
    }
    
    // negative filter (inverted colors)
    func applyNegative(_ rgba: RGBAImage?, strength: Double) -> RGBAImage? {
        if rgba == nil { return nil }
        var negativeTest = rgba
        let newStrength = max(0.0, min(1.0, strength))  // clamp between 0…1

        for y in 0..<negativeTest!.height {
            for x in 0..<negativeTest!.width {
                let index = y * negativeTest!.width + x
                var pixel = negativeTest!.pixels[index]

                // Calculate the negative of each channel
                let negRed = 255 - Int(pixel.red)
                let negGreen = 255 - Int(pixel.green)
                let negBlue = 255 - Int(pixel.blue)

                // blends original and negative based on strength
                pixel.red   = UInt8(Double(pixel.red) * (1.0 - newStrength) + Double(negRed) * newStrength)
                pixel.green = UInt8(Double(pixel.green) * (1.0 - newStrength) + Double(negGreen) * newStrength)
                pixel.blue  = UInt8(Double(pixel.blue) * (1.0 - newStrength) + Double(negBlue) * newStrength)

                negativeTest!.pixels[index] = pixel
            }
        }
        return negativeTest
    }

    // freeze filter
    func applyFreeze(_ rgba: RGBAImage?, strength: Double) -> RGBAImage? {
        if rgba == nil { return nil }
        var freezeTest = rgba
        let newStrength = max(0.0, min(1.0, strength))
        if newStrength == 0 {
            return freezeTest
        }

        for y in 0..<freezeTest!.height {
            for x in 0..<freezeTest!.width {
                let index = y * freezeTest!.width + x
                var pixel = freezeTest!.pixels[index]

                // Original
                let r = Double(pixel.red)
                let g = Double(pixel.green)
                let b = Double(pixel.blue)


                // Increaes cyan intensity
                 let intensity = (r + g + b) / 3.0
            
                let freezeR = min(255, intensity * 0.25) //mutes red a tad
                 let freezeG = min(255, intensity * 1.05)
                 let freezeB = min(255, intensity * 1.40)

                // blends original to freeze
                let finalR = r * (1.0 - newStrength) + freezeR * newStrength
                let finalG = g * (1.0 - newStrength) + freezeG * newStrength
                let finalB = b * (1.0 - newStrength) + freezeB * newStrength

                pixel.red   = UInt8(max(0, min(255, finalR)))
                pixel.green = UInt8(max(0, min(255, finalG)))
                pixel.blue  = UInt8(max(0, min(255, finalB)))

                freezeTest!.pixels[index] = pixel
            }
        }
        return freezeTest
    }

    // grayscale filter
    func applyGrayscale(_ rgba: RGBAImage?, strength: Double) -> RGBAImage? {
        if rgba == nil {
            return nil
        }
        let grayscaleTest = rgba
        let newStrength = max(0.0, min(1.0, strength))
        for y in 0..<grayscaleTest!.height {
            for x in 0..<grayscaleTest!.width {
                let index = y * grayscaleTest!.width + x
                var pixel = grayscaleTest!.pixels[index]
                    // further logic
                
                let r = Double(pixel.red)
                let g = Double(pixel.green)
                let b = Double(pixel.blue)
                let intensity = r * 0.299 + g * 0.587 + b * 0.114
                
                pixel.red   = UInt8(r * (1.0 - newStrength) + intensity * newStrength)
                pixel.green = UInt8(g * (1.0 - newStrength) + intensity * newStrength)
                pixel.blue  = UInt8(b * (1.0 - newStrength) + intensity * newStrength)
                grayscaleTest!.pixels[index] = pixel
            }
        }
        return grayscaleTest
    }

    // sepia filter
    func applySepia(_ rgba: RGBAImage?, strength: Double) -> RGBAImage? {
        if rgba == nil { return nil }
        let newStrength = max(0.0, min(1.0, strength))
        if newStrength == 0 {
            return rgba
        }

        let sepiaTest = rgba
        for y in 0..<sepiaTest!.height {
            for x in 0..<sepiaTest!.width {
                let index = y * sepiaTest!.width + x
                var pixel = sepiaTest!.pixels[index]
                // further logic
                
                // Original rgb colors
                let r = Double(pixel.red)
                let g = Double(pixel.green)
                let b = Double(pixel.blue)

                // implemented values for sepia
                let sepiaR = min(255, (r * 0.65) + (g * 0.70) + (b * 0.19))
                let sepiaG = min(255, (r * 0.40) + (g * 0.45) + (b * 0.09))
                let sepiaB = min(255, (r * 0.18) + (g * 0.34) + (b * 0.04))

                // we blend original colors with sepia.
                let finalR = r * (1.0 - newStrength) + sepiaR * newStrength
                let finalG = g * (1.0 - newStrength) + sepiaG * newStrength
                let finalB = b * (1.0 - newStrength) + sepiaB * newStrength

                pixel.red = UInt8(max(0, min(255, finalR)))
                pixel.green = UInt8(max(0, min(255, finalG)))
                pixel.blue = UInt8(max(0, min(255, finalB)))

                sepiaTest!.pixels[index] = pixel
            }
        }
        return sepiaTest
    }
// dim filter
    func applyDimBrightness(_ rgba: RGBAImage?, strength: Double) -> RGBAImage? {
        if rgba == nil { return nil }
        
        let dimbrightnessTest = rgba
        // clamps the values so it has bounds
        let newStrength = max(0.0, min(1.0, strength))
        // makes it so if strength is 0 then it returns.
        if newStrength == 0 {
            return dimbrightnessTest
        }
        // decides what the brightness factor should be after passing the strength variable
        let factor = 1.0 - (0.65 * newStrength)
        
        for y in 0..<dimbrightnessTest!.height {
            for x in 0..<dimbrightnessTest!.width {
                let index = y * dimbrightnessTest!.width + x
                var pixel = dimbrightnessTest!.pixels[index]
                // further logic
                
                pixel.red =  UInt8(Double(pixel.red) * factor)
                pixel.green = UInt8(Double(pixel.green) * factor)
                pixel.blue = UInt8(Double(pixel.blue) * factor)
                
                dimbrightnessTest!.pixels[index] = pixel
            }
        }
        return dimbrightnessTest
    }
}

// Processing the image! (open results tab to see how the filters apply with each image)

// -- Creates an instance of ImageProcessor to apply to image filter paramters.
var imageProcessor = ImageProcessor()

// -- showcases different types of filters
// how it works: if you want to apply a filter, you just apply a value greater than 0 to its strength. Generally, a strength of 1.0 shows the filter at its max intended strength. To not apply a filter, keep the value at 0.

//let example1 = imageProcessor.filteredImage(
//    negativeFilter: "Negative Filter", negativeStrength: 1.0,
//    freezeFilter: "Freeze Filter",   freezeStrength: 0.0,
//    grayscaleFilter: "Grayscale Filter",  grayscaleStrength: 0.0,
//    sepiaFilter: "Sepia Filter",  sepiaStrength: 0.0,
//    dimFilter: "Dim Filter",     dimStrength: 0.0
//)?.toUIImage()
//
//let example2 = imageProcessor.filteredImage(
//    negativeFilter: "Negative Filter", negativeStrength: 0.0,
//    freezeFilter: "Freeze Filter",   freezeStrength: 1.0,
//    grayscaleFilter: "Grayscale Filter",  grayscaleStrength: 0.0,
//    sepiaFilter: "Sepia Filter",  sepiaStrength: 0.0,
//    dimFilter: "Dim Filter",     dimStrength: 0.0
//)?.toUIImage()
//
//let example3 = imageProcessor.filteredImage(
//    negativeFilter: "Negative Filter", negativeStrength: 0.0,
//    freezeFilter: "Freeze Filter",   freezeStrength: 0.0,
//    grayscaleFilter: "Grayscale Filter",  grayscaleStrength: 1.00,
//    sepiaFilter: "Sepia Filter",  sepiaStrength: 0.0,
//    dimFilter: "Dim Filter",     dimStrength: 0.0
//)?.toUIImage()
//
//let example4 = imageProcessor.filteredImage(
//    negativeFilter: "Negative Filter", negativeStrength: 0.0,
//    freezeFilter: "Freeze Filter",   freezeStrength: 0.0,
//    grayscaleFilter: "Grayscale Filter",  grayscaleStrength: 0.0,
//    sepiaFilter: "Sepia Filter",  sepiaStrength: 1.0,
//    dimFilter: "Dim Filter",     dimStrength: 0.0
//)?.toUIImage()
//
//let example5 = imageProcessor.filteredImage(
//    negativeFilter: "Negative Filter", negativeStrength: 0.0,
//    freezeFilter: "Freeze Filter",   freezeStrength: 0.0,
//    grayscaleFilter: "Grayscale Filter",  grayscaleStrength: 0.0,
//    sepiaFilter: "Sepia Filter",  sepiaStrength: 0.0,
//    dimFilter: "Dim Filter",     dimStrength: 1.0
//)?.toUIImage()


// -- pipeline example (can apply filters in an arbitrary fashion
let result = imageProcessor.filteredImage(filterNames: ["Freeze Filter", "Dim Filter"])?.toUIImage()

result
