import UIKit
import MapwizeForMapbox
import ionicons

class PlaceView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var borderView: UIView!
    var objectImage: UIImageView!
    var objectTitle: UILabel!
    var objectSubtitle: UILabel!
    var titleContentView: UIView!
    var moreDetailsImageView: UIButton!
    var contentDirectionTimeView: UIView!
    var directionTimeImage: UIImageView!
    var directionTime: UILabel!
    var contentDirectionDistanceView: UIView!
    var directionDistanceImage: UIImageView!
    var directionDistance: UILabel!
    
    weak var delegate:PlaceViewDelegate?
    var routeDelegate: RouteViewDelegate?
    
    //MARK : Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func removeViews() {
        if objectImage != nil {
            objectImage.removeFromSuperview()
            objectImage = nil
        }
        if objectTitle != nil {
            objectTitle.removeFromSuperview()
            objectTitle = nil
        }
        if objectSubtitle != nil {
            objectSubtitle.removeFromSuperview()
            objectSubtitle = nil
        }
        if titleContentView != nil {
            titleContentView.removeFromSuperview()
            titleContentView = nil
        }
        if contentDirectionTimeView != nil {
            contentDirectionTimeView.removeFromSuperview()
            contentDirectionTimeView = nil
        }
        if directionTime != nil {
            directionTime.removeFromSuperview()
            directionTime = nil
        }
        if directionTimeImage != nil {
            directionTimeImage.removeFromSuperview()
            directionTimeImage = nil
        }
        if contentDirectionDistanceView != nil {
            contentDirectionDistanceView.removeFromSuperview()
            contentDirectionDistanceView = nil
        }
        if directionDistance != nil {
            directionDistance.removeFromSuperview()
            directionDistance = nil
        }
        if directionDistanceImage != nil {
            directionDistanceImage.removeFromSuperview()
            directionDistanceImage = nil
        }
        if moreDetailsImageView != nil {
            moreDetailsImageView.removeFromSuperview()
            moreDetailsImageView = nil
        }
    }
    
    func setupViewFor(place:MWZPlace!, language:String!) {
        
        removeViews()
        
        objectImage = UIImageView(frame:CGRect.zero)
        objectImage.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(objectImage)
        NSLayoutConstraint(item: objectImage, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil,
                           attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 30).isActive = true;
        NSLayoutConstraint(item: objectImage, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil,
                           attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 30).isActive = true;
        NSLayoutConstraint(item: objectImage, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.contentView,
                           attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true;
        NSLayoutConstraint(item: objectImage, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self.contentView,
                           attribute: NSLayoutAttribute.left, multiplier: 1, constant: ((self.contentView.frame.height-30)/2)).isActive = true;
        if place.icon != nil && place.icon.count > 0 {
            objectImage.kf.setImage(with: URL(string: place.icon))
        }
        else {
            objectImage.kf.setImage(with: nil)
        }

        objectTitle = UILabel(frame:CGRect.zero)
        objectTitle.translatesAutoresizingMaskIntoConstraints = false
        objectTitle.text = place.title(forLanguage: language)
        let subtitle = place.subtitle(forLanguage: language)
        if subtitle != nil && subtitle!.count > 0 {
            titleContentView = UIView(frame:CGRect.zero)
            titleContentView.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(titleContentView)
            NSLayoutConstraint(item: titleContentView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: objectImage,
                               attribute: NSLayoutAttribute.right, multiplier: 1, constant: ((self.contentView.frame.height-30)/2)).isActive = true;
            NSLayoutConstraint(item: titleContentView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self.contentView,
                               attribute: NSLayoutAttribute.right, multiplier: 1, constant: -((self.contentView.frame.height-30)/2)).isActive = true;
            NSLayoutConstraint(item: titleContentView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.contentView,
                               attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true;
            
            self.titleContentView.addSubview(objectTitle)
            NSLayoutConstraint(item: objectTitle, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: titleContentView,
                               attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true;
            NSLayoutConstraint(item: objectTitle, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: titleContentView,
                               attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0).isActive = true;
            NSLayoutConstraint(item: objectTitle, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: titleContentView,
                               attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0).isActive = true;
            NSLayoutConstraint(item: objectTitle, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil,
                               attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 21).isActive = true;
            
            objectSubtitle = UILabel(frame:CGRect.zero)
            objectSubtitle.translatesAutoresizingMaskIntoConstraints = false
            objectSubtitle.text = subtitle
            self.titleContentView.addSubview(objectSubtitle)
            NSLayoutConstraint(item: objectSubtitle, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: objectTitle,
                               attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true;
            NSLayoutConstraint(item: objectSubtitle, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: titleContentView,
                               attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0).isActive = true;
            NSLayoutConstraint(item: objectSubtitle, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: titleContentView,
                               attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0).isActive = true;
            NSLayoutConstraint(item: objectSubtitle, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil,
                               attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 21).isActive = true;
            NSLayoutConstraint(item: objectSubtitle, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: titleContentView,
                               attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true;
            
        }
        else {
            self.contentView.addSubview(objectTitle)
            NSLayoutConstraint(item: objectTitle, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil,
                               attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 21).isActive = true;
            NSLayoutConstraint(item: objectTitle, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: objectImage,
                               attribute: NSLayoutAttribute.right, multiplier: 1, constant: ((self.contentView.frame.height-30)/2)).isActive = true;
            NSLayoutConstraint(item: objectTitle, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.contentView,
                               attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true;
            NSLayoutConstraint(item: objectTitle, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self.contentView,
                               attribute: NSLayoutAttribute.right, multiplier: 1, constant: ((self.contentView.frame.height-30)/2)).isActive = true;
        }

        let details = place.details(forLanguage: language)
        if details != nil && details!.count > 0 {
            moreDetailsImageView = UIButton(frame:CGRect.zero)
            moreDetailsImageView.translatesAutoresizingMaskIntoConstraints = false
            moreDetailsImageView.setImage(IonIcons.image(withIcon: ion_ios_more, iconColor: .black, iconSize: 30, imageSize: CGSize(width: 30, height: 30)), for: .normal)
            self.contentView.addSubview(moreDetailsImageView)
            NSLayoutConstraint(item: moreDetailsImageView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil,
                               attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 30).isActive = true;
            NSLayoutConstraint(item: moreDetailsImageView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil,
                               attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 30).isActive = true;
            NSLayoutConstraint(item: moreDetailsImageView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.contentView,
                               attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true;
            NSLayoutConstraint(item: moreDetailsImageView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self.contentView,
                               attribute: NSLayoutAttribute.right, multiplier: 1, constant: -((self.contentView.frame.height-30)/2)).isActive = true;
            moreDetailsImageView.addTarget(self, action: #selector(moreDetailsAction), for: .touchUpInside)
        }
        
    }
    
    @objc func moreDetailsAction(sender: UIButton!) {
        self.delegate?.didTapMoreDetails()
    }
    
    func setupViewFor(placeList:MWZPlaceList!, language:String!) {
        
        removeViews()
        
        objectImage = UIImageView(frame:CGRect.zero)
        objectImage.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(objectImage)
        NSLayoutConstraint(item: objectImage, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil,
                           attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 30).isActive = true;
        NSLayoutConstraint(item: objectImage, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil,
                           attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 30).isActive = true;
        NSLayoutConstraint(item: objectImage, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.contentView,
                           attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true;
        NSLayoutConstraint(item: objectImage, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self.contentView,
                           attribute: NSLayoutAttribute.left, multiplier: 1, constant: ((self.contentView.frame.height-30)/2)).isActive = true;
        if placeList.icon != nil && placeList.icon.count > 0 {
            objectImage.kf.setImage(with: URL(string: placeList.icon))
        }
        else {
            objectImage.kf.setImage(with: nil)
        }
        
        objectTitle = UILabel(frame:CGRect.zero)
        objectTitle.translatesAutoresizingMaskIntoConstraints = false
        objectTitle.text = placeList.title(forLanguage: language)
        self.contentView.addSubview(objectTitle)
        NSLayoutConstraint(item: objectTitle, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil,
                           attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 21).isActive = true;
        NSLayoutConstraint(item: objectTitle, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: objectImage,
                           attribute: NSLayoutAttribute.right, multiplier: 1, constant: ((self.contentView.frame.height-30)/2)).isActive = true;
        NSLayoutConstraint(item: objectTitle, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.contentView,
                           attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true;
        NSLayoutConstraint(item: objectTitle, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self.contentView,
                           attribute: NSLayoutAttribute.right, multiplier: 1, constant: ((self.contentView.frame.height-30)/2)).isActive = true;
    }
    
    func setupViewFor(direction:MWZDirection!, isAccessible:Bool!) {
        
        removeViews()
        let routeVC = RouteView()
        routeVC.frame = self.view.frame
        

        var traveltime = (direction.traveltime/60)
        traveltime.round()
        if traveltime == 0 {
            traveltime = 1
        }
        
        var distance = direction.distance
        distance.round()
        if #available(iOS 10.0, *) {
            let metersMeasurement = Measurement(value: distance, unit: UnitLength.meters)
            let measurementFormatter = MeasurementFormatter()
            measurementFormatter.unitOptions = .naturalScale
            measurementFormatter.numberFormatter.maximumFractionDigits = 0
            let localizedString = measurementFormatter.string(from: metersMeasurement)
            routeVC.distanceLabel.text = localizedString
        } else {
            routeVC.distanceLabel.text = String(format:"%.0f m", direction.distance)
        }
        
        
        
        routeVC.timeLabel.text = String(format:"%.0f min", traveltime)
//        routeVC.distanceLabel.text = String(distance)
        


        contentDirectionTimeView = routeVC
        contentView.addSubview(contentDirectionTimeView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(goToARView(_:)))
        routeVC.ARView.addGestureRecognizer(tap)
    }
    
    @objc func goToARView(_ recognizer: UIGestureRecognizer){
        routeDelegate?.showARview()
        print("showARView")
    }
}

extension PlaceView {
    func xibSetup() {
        self.view = loadViewFromNib()
        self.view.translatesAutoresizingMaskIntoConstraints = true
        self.addSubview(self.view)
        self.borderView.backgroundColor = UIColor(hex: "C51586")
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let view = bundle.loadNibNamed("PlaceView", owner: self, options: nil)?[0] as! UIView
        return view
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.view.frame = self.bounds
    }
}

protocol PlaceViewDelegate: class {
    func didTapMoreDetails()
}
