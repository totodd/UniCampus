import UIKit
import MapwizeForMapbox

class MapwizeTableViewController: UITableViewController {
    
    static let venueNibName = "SearchBarCell"
    static let tableViewCellIdentifier = "cellVenueID"
    
    static let placeNibName = "PlaceSearchBarCell"
    static let placeTableViewCellIdentifier = "cellPlaceID"
    
    static let placeSubtitleNibName = "PlaceWithSubtitleSearchBarCell"
    static let placeSubtitleTableViewCellIdentifier = "cellPlaceSubtitleID"
    
    static let locationNibName = "LocationBarCell"
    static let locationTableViewCellIdentifier = "cellLocationID"
    
    var tableHeightConstraint:NSLayoutConstraint!
    
    var keyboardHeight:CGFloat?
    var maxSize:CGFloat?
    
    var userLocation:CLLocationCoordinate2D?
    var filteredSearchObjects = [Any]()
    
    var language:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let venueNib = UINib(nibName: MapwizeTableViewController.venueNibName, bundle: nil)
        tableView.register(SearchBarCell.self, forCellReuseIdentifier: MapwizeTableViewController.tableViewCellIdentifier)
        tableView.register(venueNib, forCellReuseIdentifier: MapwizeTableViewController.tableViewCellIdentifier)
        
        let placeNib = UINib(nibName: MapwizeTableViewController.placeNibName, bundle: nil)
        tableView.register(PlaceSearchBarCell.self, forCellReuseIdentifier: MapwizeTableViewController.placeTableViewCellIdentifier)
        tableView.register(placeNib, forCellReuseIdentifier: MapwizeTableViewController.placeTableViewCellIdentifier)
        
        let placeSubtitleNib = UINib(nibName: MapwizeTableViewController.placeSubtitleNibName, bundle: nil)
        tableView.register(PlaceWithSubtitleSearchBarCell.self, forCellReuseIdentifier: MapwizeTableViewController.placeSubtitleTableViewCellIdentifier)
        tableView.register(placeSubtitleNib, forCellReuseIdentifier: MapwizeTableViewController.placeSubtitleTableViewCellIdentifier)
        
        let locationNib = UINib(nibName: MapwizeTableViewController.locationNibName, bundle: nil)
        tableView.register(LocationBarCell.self, forCellReuseIdentifier: MapwizeTableViewController.locationTableViewCellIdentifier)
        tableView.register(locationNib, forCellReuseIdentifier: MapwizeTableViewController.locationTableViewCellIdentifier)
        
        tableView.backgroundColor = .white
        
        tableHeightConstraint = NSLayoutConstraint(item: self.tableView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal,
                           toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 0);
        tableHeightConstraint.isActive = true
        
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.layer.borderWidth = 0.5
        
        tableView.separatorStyle = .none
        
        self.tableView.estimatedRowHeight = 120
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(getInfo(notif:)), name: .UIKeyboardDidShow , object: nil)
        
        self.tableView.layer.masksToBounds = false
        self.tableView.layer.shadowOpacity = 0.3
        self.tableView.layer.shadowRadius = 4
        self.tableView.layer.shadowColor = UIColor.black.cgColor
        self.tableView.layer.shadowOffset = CGSize(width: 0, height: 4)
        
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        self.update()
    }
    
    func setLanguage(language:String) {
        self.language = language
    }
    
    func update() {
        self.tableView.layer.removeAllAnimations()
        if maxSize != nil {
            if tableView.contentSize.height >= maxSize! {
                tableHeightConstraint.constant = maxSize!
            }
            else {
                tableHeightConstraint.constant = tableView.contentSize.height
            }
            
            if self.tableView.contentSize.height == (tableHeightConstraint.constant) {
                self.tableView.isScrollEnabled = false
                self.tableView.setContentOffset(CGPoint.zero, animated: false)
            }
            else {
                self.tableView.isScrollEnabled = true
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSearchObjects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell!
        if let place = filteredSearchObjects[indexPath.row] as? MWZPlace {
            cell = configureCell(place:place)
        }
        if let placeList = filteredSearchObjects[indexPath.row] as? MWZPlaceList {
            cell = configureCell(placeList:placeList)
        }
        if let venue = filteredSearchObjects[indexPath.row] as? MWZVenue {
            cell = configureCell(venue:venue)
        }
        if let string = filteredSearchObjects[indexPath.row] as? String {
            if string.elementsEqual("NO_RESULT") {
                cell = configureNoResultCell()
            }
            else {
                cell = configureCell()
            }
        }
        
        return cell
    }
    
    func configureCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MapwizeTableViewController.tableViewCellIdentifier)! as! SearchBarCell
        cell.placeTitle.text = NSLocalizedString("Current location", comment: "")
        cell.placeImage.image = UIImage(named: "currentLocation")
        cell.isUserInteractionEnabled = true
        return cell
    }
    
    func configureNoResultCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MapwizeTableViewController.tableViewCellIdentifier)! as! SearchBarCell
        cell.placeTitle.text = NSLocalizedString("No result", comment: "")
        cell.placeImage.image = nil
        cell.isUserInteractionEnabled = false
        return cell
    }
    
    func configureCell(place:MWZPlace) -> UITableViewCell {
        if place.subtitle(forLanguage:language) != nil && !place.subtitle(forLanguage:language).elementsEqual("") {
            let cell = tableView.dequeueReusableCell(withIdentifier: MapwizeTableViewController.placeSubtitleTableViewCellIdentifier)! as! PlaceWithSubtitleSearchBarCell
            cell.placeTitle.text = place.title(forLanguage: language)
            cell.placeSubTitle.text = place.subtitle(forLanguage: language)
            cell.placeFloor.text = "Floor \(place.floor!)"
            if place.icon != nil && place.icon.count > 0 {
                cell.placeImage.kf.setImage(with: URL(string: place.icon))
            }
            else {
                cell.placeImage.kf.setImage(with:nil)
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: MapwizeTableViewController.placeTableViewCellIdentifier)! as! PlaceSearchBarCell
            cell.placeTitle.text = place.title(forLanguage: language)
            cell.placeFloor.text = "Floor \(place.floor!)"
            if place.icon != nil && place.icon.count > 0 {
                cell.placeImage.kf.setImage(with: URL(string: place.icon))
            }
            else {
                cell.placeImage.kf.setImage(with:nil)
            }
            return cell
        }
    }
    
    func configureCell(venue:MWZVenue) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MapwizeTableViewController.tableViewCellIdentifier)! as! SearchBarCell
        cell.placeTitle.text = venue.title(forLanguage: language)
        cell.placeImage.kf.setImage(with: URL(string: venue.icon))
        cell.isUserInteractionEnabled = true
        return cell
    }
    
    func configureCell(placeList:MWZPlaceList) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MapwizeTableViewController.tableViewCellIdentifier)! as! SearchBarCell
        cell.placeTitle.text = placeList.title(forLanguage: language)
        if placeList.icon != nil && placeList.icon.count > 0 {
            cell.placeImage.kf.setImage(with: URL(string: placeList.icon))
        }
        else {
            cell.placeImage.kf.setImage(with:nil)
        }
        cell.isUserInteractionEnabled = true
        return cell
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    @objc func getInfo(notif: NSNotification) -> Void {
        guard let userInfo = notif.userInfo else {return}
        
        if let myData = userInfo["UIKeyboardFrameEndUserInfoKey"] as? CGRect {
            keyboardHeight = myData.height
            if keyboardHeight != nil && maxSize == nil && tableView.superview != nil {
                maxSize = (tableView.superview?.frame.size.height)! - keyboardHeight!  - self.tableView.frame.origin.y
                self.update()
            }
        }
    }
}

