import Foundation

final class FillWithColor {
    
    func changePixelColor(_ image: [[Int]], _ row: Int, _ column: Int, _ newColor: Int, _ oldColor: Int) -> [[Int]]{
        guard (row >= 0 && row < image.count && column >= 0 && column < (image.first?.count ?? 0) && newColor != oldColor) else {
            return image
        }
        
        var newImage = image
        if  oldColor == image[row][column] {
            newImage[row][column] = newColor
            newImage = changePixelColor(newImage, row-1, column, newColor, oldColor)
            newImage = changePixelColor(newImage, row+1, column, newColor, oldColor)
            newImage = changePixelColor(newImage, row, column-1, newColor, oldColor)
            newImage = changePixelColor(newImage, row, column+1, newColor, oldColor)
        }
        return newImage
    }
    
    func fillWithColor(_ image: [[Int]], _ row: Int, _ column: Int, _ newColor: Int) -> [[Int]] {
        let m = image.count
        let n = image.first?.count ?? 0
        
        guard  (m <= 50 && m >= 1 && n <= 50 && n >= 1 &&
                newColor >= 0 && newColor < 65536 &&
                row >= 0 && row < m && column >= 0 && column < n) else {
            return image
        }
        
        return changePixelColor(image, row, column, newColor, image[row][column])
        
    }
}
