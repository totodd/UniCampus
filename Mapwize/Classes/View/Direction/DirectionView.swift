import UIKit
import ionicons
@objc protocol DirectionViewDelegate {
    func exitDirectionView()
    func reversePlace()
    func togglePMRDirection(isPMR: Bool)
}

class DirectionView: UIView {
    @IBOutlet var view: UIView!
    
    @IBOutlet weak var fromSearchBar: UITextField!
    @IBOutlet weak var toSearchBar: UITextField!
    
    @IBOutlet weak var fromImage: UIImageView!
    @IBOutlet weak var toImage: UIImageView!
    
    @IBOutlet weak var reverseSearchButton: UIButton!
    @IBOutlet weak var pmrButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    var delegate: DirectionViewDelegate?
    
    var isPmrDirection: Bool = false
    
    var wheelChairImage:UIImage!
    var wheelChairActivateImage:UIImage!
    
    //MARK : Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        configure()
    }
    
    func configure() {
        self.backgroundColor = UIColor(hex: "C51586")
        self.view.backgroundColor = UIColor(hex: "C51586")
        let backIcon = IonIcons.image(withIcon: ion_ios_arrow_back, iconColor: .white, iconSize: 25, imageSize: CGSize(width: 30, height: 30))
        
        let revertIcon = UIImage(named:"arrow_swap")
        wheelChairImage = UIImage(named:"wheelchair_white")
        wheelChairActivateImage = UIImage(named:"wheelchair_activated")
        self.pmrButton.setImage(wheelChairImage, for: .normal)
        self.pmrButton.layer.cornerRadius = 0.5 * pmrButton.bounds.size.height
        self.reverseSearchButton.setImage(revertIcon, for: .normal)
        self.backButton.setImage(backIcon, for: .normal)
        
        self.fromImage.image = IonIcons.image(withIcon: ion_android_locate, size: 15, color: .white)
        self.toImage.image = IonIcons.image(withIcon: ion_ios_location, size: 15, color: .white)
        
        self.fromSearchBar.placeholder = NSLocalizedString("Choose a starting point", comment: "")
        self.toSearchBar.placeholder = NSLocalizedString("Choose a destination", comment: "")
        
        self.fromSearchBar.tag = 1
        self.toSearchBar.tag = 2
    }
    
    @IBAction func backDirectionView(_ sender: Any) {
        self.delegate?.exitDirectionView()
    }
    
    @IBAction func reversePlaces(_ sender: Any) {
        self.delegate?.reversePlace()
    }
    
    @IBAction func togglePmrDirection(_ sender: Any) {
        self.isPmrDirection = !self.isPmrDirection
        self.delegate?.togglePMRDirection(isPMR: self.isPmrDirection)
        
        if self.isPmrDirection {
            self.pmrButton.tintColor = UIColor(hex:"C51586")
            self.pmrButton.backgroundColor = .white
        } else {
            self.pmrButton.tintColor = .white
            self.pmrButton.backgroundColor = .clear
        }
    }
}

extension DirectionView {
    func xibSetup() {
        self.view = loadViewFromNib()
        self.view.translatesAutoresizingMaskIntoConstraints = true
        self.addSubview(self.view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let view = bundle.loadNibNamed("DirectionView", owner: self, options: nil)?[0] as! UIView
        return view
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.view.frame = self.bounds
    }
}
