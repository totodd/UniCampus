import UIKit
import ionicons

protocol RouteViewDelegate {
    func showARview()
}

class RouteView: UIView {
    @IBOutlet var view: UIView!
    
    @IBOutlet var borderView: UIView!
    
    @IBOutlet weak var clockImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var walkImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var ARLabel: UILabel!
    @IBOutlet weak var ARImageView: UIImageView!
    
    @IBOutlet weak var ARView: UIView!
    
    var clockIcon:UIImage!
    var walkIcon:UIImage!
    var wheelchairIcon:UIImage!
    
    var delegate: RouteViewDelegate?
    
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
        clockIcon = IonIcons.image(withIcon: ion_ios_clock_outline, iconColor: UIColor(hex: "882E88"), iconSize: 30, imageSize: CGSize(width: 30, height: 30))
        walkIcon = IonIcons.image(withIcon: ion_android_walk, iconColor: UIColor(hex: "882E88"), iconSize: 30, imageSize: CGSize(width: 30, height: 30))
        wheelchairIcon = UIImage(named:"wheelchair_pink")
        
        
        
        self.clockImageView.image = clockIcon
        self.walkImageView.image = walkIcon
        
        ARLabel.text = "ARView"
        
    }
    
    open func changeIconIf(isPMR: Bool) {
        if isPMR {
            self.walkImageView.image = wheelchairIcon
        } else {
            self.walkImageView.image = walkIcon
        }
    }
}

extension RouteView {
    func xibSetup() {
        self.view = loadViewFromNib()
        self.view.translatesAutoresizingMaskIntoConstraints = true
        self.addSubview(self.view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let view = bundle.loadNibNamed("RouteView", owner: self, options: nil)?[0] as! UIView
        return view
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.view.frame = self.bounds
    }
}

extension RouteView{
    func settARView(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(goToARView(_:)))
        ARView.addGestureRecognizer(tap)
    }
    
    @objc func goToARView(_ recognizer: UIGestureRecognizer){
        delegate?.showARview()
        print("showARView")
    }
}
