import Foundation

class QrCodeTargetView : UIView {
    
    override func draw(_ rect: CGRect) {
        self.layer.borderColor = UIColor(hex:"C51586").cgColor
        self.layer.borderWidth = 3
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }
    
}
