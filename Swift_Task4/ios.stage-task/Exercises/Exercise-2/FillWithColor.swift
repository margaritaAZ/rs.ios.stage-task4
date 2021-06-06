import Foundation

final class FillWithColor {
    
    func changePixelColor(_ image: inout [[Int]], _ visitedPixelsSet: inout [[Bool]], _ row: Int, _ column: Int, _ newColor: Int, _ oldColor: Int){
        
        guard (row >= 0 && row < image.count && column >= 0 && column < (image.first?.count ?? 0)) else {
            return
        }
        guard !visitedPixelsSet[row][column] && oldColor == image[row][column] else {
            return
        }
        image[row][column] = newColor
        visitedPixelsSet[row][column] = true
        changePixelColor(&image, &visitedPixelsSet, row-1, column, newColor, oldColor)
        changePixelColor(&image, &visitedPixelsSet, row+1, column, newColor, oldColor)
        changePixelColor(&image, &visitedPixelsSet, row, column-1, newColor, oldColor)
        changePixelColor(&image, &visitedPixelsSet, row, column+1, newColor, oldColor)
        return
    }
    
    func fillWithColor(_ image: [[Int]], _ row: Int, _ column: Int, _ newColor: Int) -> [[Int]] {
        let m = image.count
        let n = image.first?.count ?? 0
        
        guard  (m <= 50 && m >= 1 && n <= 50 && n >= 1 &&
                    newColor >= 0 && newColor < 65536 &&
                    row >= 0 && row < m && column >= 0 && column < n) else {
            return image
        }
        
        guard newColor != image[row][column] else {
            return image
        }
        
        var coloredImage = image
        var visitedPixelsSet: [[Bool]] = Array(repeating: Array(repeating: false, count: n), count: m)
        
        changePixelColor(&coloredImage, &visitedPixelsSet, row, column, newColor, coloredImage[row][column])
        return coloredImage
    }
}
