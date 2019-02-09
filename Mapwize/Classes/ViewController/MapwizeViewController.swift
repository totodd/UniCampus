import UIKit
import WebKit
import ionicons
import MapwizeForMapbox
import Mapbox
import Kingfisher
import SystemConfiguration
enum SearchMode {
    case none
    case defaultSearch
    case fromSearch
    case toSearch
}

class MapwizeViewController: UIViewController  {
    
    var mapwizePlugin: MapwizePlugin!
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var previewQrCode: UIView!
    
    @IBOutlet weak var backedView: UIView!
    @IBOutlet weak var searchBackedView: UIView!
    
    @IBOutlet weak var leftMenuButton: UIButton!
    @IBOutlet weak var qrCodeButton: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var headerSearchTextField: UITextField!
    
    @IBOutlet weak var mapView: MGLMapView!
    
    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var universesButton: UIButton!
    @IBOutlet weak var directionButton: UIButton!

    @IBOutlet weak var directionView: DirectionView!
    
    var popup:UIView!
    var bottomSheetVC:BottomSheetViewController!
    var accessKeyTextField: UITextField!
    var accessKeyAlert: UIAlertController?
    var selectedPlace: MWZPlace?
    var promotedPlaces: [MWZPlace] = [MWZPlace]()
    
    var searchController: UISearchController!
    var searchTableController: MapwizeTableViewController = MapwizeTableViewController()
    
    var searchTableView: UITableView!
    
    var isInVenue: Bool = false
    var isInDirection: Bool = false
    var isInSearch: Bool = false
    var currentVenue: MWZVenue!
    
    var isLeftMenuOpen:Bool = false
    
    var currentSearchMode:SearchMode!
    
    var directionFrom: MWZDirectionPoint?
    var directionTo: MWZDirectionPoint?
    var isPMR: Bool = false
    
    var directionMemory:(venueId:String, from:MWZDirectionPoint, to:MWZDirectionPoint, direction:MWZDirection)?
    
    var locationProvider:LocationProvidersManager!
    var lastLocation:ILIndoorLocation?
    
    var defaultBottomMargin:CGFloat = 0.0
    var defaultTopMargin:CGFloat = 0.0
    
    var parseObjectFromDeepLink:MWZParsedUrlObject?
    var startedFromUrl = false
    
    override func loadView() {
        super.loadView()
        initMap()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false;
        checkIphoneXMargin()
        initNavigation()
        
        self.searchTableView = self.searchTableController.tableView
        self.searchTableController.tableView.delegate = self
        
        self.accessKeyTextField = UITextField()
        
        self.configureSearchBar()
        self.currentSearchMode = .none
        
//        self.bottomSheetVC.placeView.routeDelegate = self
        self.directionView.isHidden = true
        self.directionView.delegate = self
        self.directionView.layer.cornerRadius = 0.5 * languageButton.bounds.size.height
        self.directionView.layer.masksToBounds = false
        self.directionView.layer.shadowColor = Color.black.cgColor
        self.directionView.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.directionView.layer.shadowOpacity = 0.3
        self.directionView.layer.shadowRadius = CGFloat(4)
        self.directionView.layer.zPosition = 10

        self.directionView.fromSearchBar.delegate = self
        self.directionView.toSearchBar.delegate = self
        
        //Removing Empty cell
        self.searchTableController.tableView.tableFooterView = UIView()
        
        // Show View Table
        self.definesPresentationContext = true
        
        if !self.isInternetAvailable() {
            let alert = UIAlertController(title: NSLocalizedString("Network", comment: ""),
                                          message: NSLocalizedString("No network avaible, please turn ON internet and relauch Mapwize", comment: ""),
                                          preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: { (action) -> Void in})
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }
        self.addBottomSheetView()
        initBottomBar()
        locationProvider = LocationProvidersManager()
        let filters = MWZApiFilter()
        MWZApi.getVenuesWith(filters, success: { (venues) in
            self.locationProvider.venues = venues
            self.locationProvider.checkProviders(location: self.locationProvider.lastLocation)
        }) { (err) in
            print(err ?? "Unknown error")
        }
    }
    
    func addBottomSheetView() {
        self.bottomSheetVC = BottomSheetViewController.init(bottomMargin:defaultBottomMargin, topMargin:defaultTopMargin)
        self.addChildViewController(bottomSheetVC)
        self.view.addSubview(bottomSheetVC.view)
        self.bottomSheetVC.didMove(toParentViewController: self)
        let height = view.frame.height
        let width  = view.frame.width
        self.bottomSheetVC.view.frame = CGRect.init(x: 0, y: self.view.frame.maxY, width: width, height: height)
        self.bottomSheetVC.placeView.routeDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    // MARK: Configuration
    func configureSearchBar() {
        self.headerSearchTextField.text = ""
        self.spinner.isHidden = true
        self.spinner.stopAnimating()
        self.leftMenuButton.isHidden = false
        if self.isInVenue {
            let inVenueString =  String(format: NSLocalizedString("Search in venue", comment: ""), self.currentVenue.title(forLanguage: getLanguage()))
            self.headerSearchTextField.placeholder = inVenueString
        }
        else {
            self.headerSearchTextField.placeholder = NSLocalizedString("Search a venue", comment: "")
        }
    }
    
    func initNavigation() {
        self.headerView.layer.masksToBounds = false
        self.headerView.layer.shadowColor = Color.black.cgColor
        self.headerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.headerView.layer.shadowOpacity = 0.3
        self.headerView.layer.shadowRadius = CGFloat(4)
        self.headerView.layer.zPosition = 10

        self.setupMenuButtonDefault()
        self.headerSearchTextField.delegate = self
        self.headerSearchTextField.addTarget(self, action: #selector(headerSearchTextFieldDidChange(textField:)), for: .editingChanged);
        self.directionView.fromSearchBar.addTarget(self, action: #selector(headerSearchTextFieldDidChange(textField:)), for: .editingChanged);
        self.directionView.toSearchBar.addTarget(self, action: #selector(headerSearchTextFieldDidChange(textField:)), for: .editingChanged);
        
        self.backedView.isHidden = true
        self.searchBackedView.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapBackView(_:)))
        let serachtap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapSearchBackView(_:)))
        self.backedView.addGestureRecognizer(tap)
        self.searchBackedView.addGestureRecognizer(serachtap)
    }
    
    @objc func handleTapBackView(_ sender: UITapGestureRecognizer? = nil) {
        if self.isLeftMenuOpen {
            self.revealLeftMenu()
        }
    }
    
    @objc func handleTapSearchBackView(_ sender: UITapGestureRecognizer? = nil) {
        if self.currentSearchMode != .none {
            self.closeSearch()
        }
    }
    
    func setupMenuButtonDefault() {
        self.leftMenuButton.removeTarget(self, action: #selector(closeSearch), for: UIControlEvents.touchDown)
        if self.revealViewController() != nil {
            self.leftMenuButton.setImage(IonIcons.image(withIcon: ion_navicon, size: 30, color: UIColor(hex:"#E3E3E3")), for:UIControlState.normal)
            self.leftMenuButton.addTarget(self, action: #selector(revealLeftMenu), for: UIControlEvents.touchDown)
            self.revealViewController().delegate = self
        }
    }
    
    @objc func revealLeftMenu() {
        self.revealViewController().revealToggle(animated: true)
        
    }
    
    func setupMenuButtonInSearch() {
        self.leftMenuButton.setImage(IonIcons.image(withIcon: ion_ios_arrow_back, size: 30, color: UIColor(hex:"#E3E3E3")), for:UIControlState.normal)
        self.leftMenuButton.removeTarget(self, action: #selector(revealLeftMenu), for: UIControlEvents.touchDown)
        self.leftMenuButton.addTarget(self, action: #selector(closeSearch), for: UIControlEvents.touchDown)
    }
    
    @objc func closeSearch() {
        self.closeSearchWith(value:nil)
    }
    
    func closeSearchWith(value:Any?) {
        self.searchBackedView.isHidden = true
        self.searchTableView.removeFromSuperview()
        self.searchTableController.filteredSearchObjects.removeAll()
        self.searchTableView.reloadData()
        
        if self.currentSearchMode == .defaultSearch {
            self.headerSearchTextField.text = ""
            self.headerSearchTextField.resignFirstResponder()
            setupMenuButtonDefault()
            if let venue = value as? MWZVenue {
                self.mapwizePlugin.center(on: venue, forceEntering:true)
            }
            if let place = value as? MWZPlace {
                mapwizePlugin.center(on: place)
                self.select(place:place)
            }
            if let placeList = value as? MWZPlaceList {
                self.select(placeList:placeList)
            }
            if value != nil {
                self.mapwizePlugin.setFollowUserMode(NONE)
            }
        }
        
        if self.currentSearchMode == .fromSearch {
            if value != nil {
                if let place = value as? MWZPlace {
                    self.directionView.fromSearchBar.text = place.title(forLanguage: mapwizePlugin.getLanguageFor(self.currentVenue))
                    self.directionFrom = place
                }
                if (value as? String) != nil {
                    self.directionView.fromSearchBar.text = NSLocalizedString("Current location", comment: "")
                    self.directionFrom = MWZLatLngFloor.init(latitude: self.mapwizePlugin.userLocation.latitude, longitude: self.mapwizePlugin.userLocation.longitude, floor: self.mapwizePlugin.userLocation.floor)
                }
                self.tryToStartDirection(from: self.directionFrom, to: self.directionTo, isAccessible: self.isPMR)
            }
            else {
                self.directionView.fromSearchBar.text = ""
            }
            self.directionView.fromSearchBar.resignFirstResponder()
        }
        
        if self.currentSearchMode == .toSearch {
            if value != nil {
                if let place = value as? MWZPlace {
                    self.directionView.toSearchBar.text = place.title(forLanguage: mapwizePlugin.getLanguageFor(self.currentVenue))
                    self.directionTo = (value as! MWZDirectionPoint)
                }
                if let placeList = value as? MWZPlaceList {
                    self.directionView.toSearchBar.text = placeList.title(forLanguage: mapwizePlugin.getLanguageFor(self.currentVenue))
                    self.directionTo = placeList
                }
                self.tryToStartDirection(from: self.directionFrom, to: self.directionTo, isAccessible: self.isPMR)
            }
            else {
                self.directionView.toSearchBar.text = ""
            }
            self.directionView.toSearchBar.resignFirstResponder()
        }
        self.isInSearch = false
        self.currentSearchMode = nil
    }
    
    @objc func headerSearchTextFieldDidChange(textField: UITextField){
        let query = textField.text!
        self.setupSearchResult(query: query, mode: self.currentSearchMode)
    }
    
    func setupSearchResult(query:String, mode:SearchMode) {
        let searchParams:MWZSearchParams = MWZSearchParams()
        
        if self.currentSearchMode == .defaultSearch {
            if self.currentVenue == nil {
                searchParams.query = query
                searchParams.objectClass = ["venue"]
                MWZApi.search(with: searchParams, success: { (results) in
                    self.searchTableController.filteredSearchObjects = results!
                    if self.searchTableController.filteredSearchObjects.count == 0 && query.count > 0{
                        self.searchTableController.filteredSearchObjects = ["NO_RESULT"]
                    }
                    self.searchTableController.tableView.reloadData()
                }) { (error) in
                    NSLog("Search error")
                }
            }
            else {
                if query.count > 0 {
                    searchParams.query = query
                    searchParams.objectClass = ["place", "placeList"]
                    searchParams.venueId = currentVenue.identifier
                    searchParams.universeId = self.mapwizePlugin.getUniverse()?.identifier
                    MWZApi.search(with: searchParams, success: { (results) in
                        self.searchTableController.filteredSearchObjects = results!
                        if self.searchTableController.filteredSearchObjects.count == 0 && query.count > 0 {
                            self.searchTableController.filteredSearchObjects = ["NO_RESULT"]
                        }
                        self.searchTableController.tableView.reloadData()
                    }) { (error) in
                        NSLog("Search error")
                    }
                }
                else {
                    MWZApi.getMainSearches(with: self.currentVenue, success: { (results) in
                        self.searchTableController.filteredSearchObjects = results!
                        if self.searchTableController.filteredSearchObjects.count == 0 && query.count > 0 {
                            self.searchTableController.filteredSearchObjects = ["NO_RESULT"]
                        }
                        self.searchTableController.tableView.reloadData()
                    }, failure: { (error) in
                        NSLog("Search error")
                    })
                }
            }
        }
        if self.currentSearchMode == .fromSearch {
            // TODO Add userlocation
            if query.count > 0 {
                searchParams.query = query
                searchParams.objectClass = ["place"]
                searchParams.venueId = currentVenue.identifier
                searchParams.universeId = self.mapwizePlugin.getUniverse().identifier
                MWZApi.search(with: searchParams, success: { (results) in
                    if self.mapwizePlugin.userLocation != nil && self.mapwizePlugin.userLocation.floor != nil {
                        self.searchTableController.filteredSearchObjects = ["Current location"] + results!
                    }
                    else {
                        self.searchTableController.filteredSearchObjects = results!
                    }
                    if self.searchTableController.filteredSearchObjects.count == 0 && query.count > 0 {
                        self.searchTableController.filteredSearchObjects = ["NO_RESULT"]
                    }
                    self.searchTableController.tableView.reloadData()
                }) { (error) in
                    NSLog("Search error")
                }
            }
            else {
                MWZApi.getMainFroms(with: self.currentVenue, success: { (results) in
                    if self.mapwizePlugin.userLocation != nil && self.mapwizePlugin.userLocation.floor != nil {
                        self.searchTableController.filteredSearchObjects = ["Current location"] + results!
                    }
                    else {
                        self.searchTableController.filteredSearchObjects = results!
                    }
                    if self.searchTableController.filteredSearchObjects.count == 0 && query.count > 0 {
                        self.searchTableController.filteredSearchObjects = ["NO_RESULT"]
                    }
                    self.searchTableController.tableView.reloadData()
                }, failure: { (error) in
                    NSLog("Search error")
                })
            }
        }
        if self.currentSearchMode == .toSearch {
            if query.count > 0 {
                searchParams.query = query
                searchParams.objectClass = ["place", "placeList"]
                searchParams.venueId = currentVenue.identifier
                searchParams.universeId = self.mapwizePlugin.getUniverse().identifier
                MWZApi.search(with: searchParams, success: { (results) in
                    self.searchTableController.filteredSearchObjects = results!
                    if self.searchTableController.filteredSearchObjects.count == 0 && query.count > 0 {
                        self.searchTableController.filteredSearchObjects = ["NO_RESULT"]
                    }
                    self.searchTableController.tableView.reloadData()
                }) { (error) in
                    NSLog("Search error")
                }
            }
            else {
                MWZApi.getMainSearches(with: self.currentVenue, success: { (results) in
                    self.searchTableController.filteredSearchObjects = results!
                    if self.searchTableController.filteredSearchObjects.count == 0 && query.count > 0 {
                        self.searchTableController.filteredSearchObjects = ["NO_RESULT"]
                    }
                    self.searchTableController.tableView.reloadData()
                }, failure: { (error) in
                    NSLog("Search error")
                })
            }
        }
    }
    
    func initMap() {
        let options = MWZOptions()
        self.mapwizePlugin = MapwizePlugin.init(self.mapView, options: options)
        self.mapwizePlugin.delegate = self
        self.mapwizePlugin.setBottomPadding(defaultBottomMargin + 60)
    }
    
    func initBottomBar() {
        
        let languageIcon = IonIcons.image(withIcon: ion_ios_world_outline, iconColor: .black, iconSize: 25, imageSize: CGSize(width: 60, height: 60))
    
        self.universesButton.backgroundColor = .white
        self.universesButton.layer.cornerRadius = 0.5 * universesButton.bounds.size.height
        self.universesButton.layer.masksToBounds = false
        self.universesButton.layer.shadowColor = Color.black.cgColor
        self.universesButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.universesButton.layer.shadowOpacity = 0.3
        self.universesButton.layer.shadowRadius = CGFloat(4)

        
        self.directionButton.backgroundColor = .white
        self.directionButton.layer.cornerRadius = 0.5 * directionButton.bounds.size.height
        self.directionButton.layer.masksToBounds = false
        self.directionButton.layer.shadowColor = Color.black.cgColor
        self.directionButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.directionButton.layer.shadowOpacity = 0.3
        self.directionButton.layer.shadowRadius = CGFloat(4)

        
        self.languageButton.setImage(languageIcon, for: .normal)
        self.languageButton.backgroundColor = .white
        self.languageButton.layer.cornerRadius = 0.5 * languageButton.bounds.size.height
        self.languageButton.layer.masksToBounds = false
        self.languageButton.layer.shadowColor = Color.black.cgColor
        self.languageButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.languageButton.layer.shadowOpacity = 0.3
        self.languageButton.layer.shadowRadius = CGFloat(4)
        
        NSLayoutConstraint(item: self.directionButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.mapwizePlugin.followButton,
                           attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true;
        NSLayoutConstraint(item: self.directionButton, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self.mapwizePlugin.followButton,
                           attribute: NSLayoutAttribute.left, multiplier: 1, constant: -8).isActive = true;
        NSLayoutConstraint(item: self.languageButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.mapwizePlugin.followButton,
                           attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true;
        NSLayoutConstraint(item: self.universesButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.mapwizePlugin.followButton,
                           attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true;
        
        exitVenue()
    }
    
    // MARK: - Override
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.isInDirection ? .lightContent : UIStatusBarStyle.default
    }
    
    // MARK: - Bottom Bar
    @IBAction func languageButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("Languages", comment: ""),
                                      message: NSLocalizedString("Choose a language", comment: ""),
                                      preferredStyle: .alert)
        
        for language in self.currentVenue.supportedLanguages {
            let action = UIAlertAction(title: language.uppercased(), style: .default, handler: { (action) -> Void in
                self.mapwizePlugin.setLanguage(language, for: self.currentVenue)
                if (self.selectedPlace != nil) {
                    self.select(place: self.selectedPlace!)
                }
            })
            alert.addAction(action)
        }
        
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: { (action) -> Void in})
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
        
    }
    
    func openAccessKeyAlert() {
        self.backedView.isHidden = false
        accessKeyAlert = UIAlertController(title: NSLocalizedString("Access key", comment: ""),
                                      message: NSLocalizedString("Access keys allow you to view private buildings and are provided by building managers", comment: ""),
                                      preferredStyle: .alert)
        accessKeyAlert!.addTextField(configurationHandler: configurationTextField)
        accessKeyAlert!.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:{ (UIAlertAction)in
            self.validAccessKey()
        }))
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: { (action) -> Void in
            self.backedView.isHidden = true
            self.accessKeyAlert = nil
        })
        accessKeyAlert!.addAction(cancel)
        present(accessKeyAlert!, animated: true, completion: nil)
    }
    
    func validAccessKey() {
        MWZApi.getAccess(self.accessKeyTextField.text!, success: {
            self.mapwizePlugin.refresh(completionHandler: {
                if self.mapwizePlugin.getVenue() != nil {
                    self.enterVenue()
                }
                let filters = MWZApiFilter()
                MWZApi.getVenuesWith(filters, success: { (venues) in
                    self.locationProvider.venues = venues
                    self.locationProvider.checkProviders(location: self.locationProvider.lastLocation)
                }) { (err) in
                    print(err ?? "Unknown error")
                }
            })
            self.openSuccessAccessAlert()
        }, failure: { (error) in
            self.openErrorAccessAlert()
        })
        self.backedView.isHidden = true
        self.accessKeyAlert = nil
    }
    
    func openSuccessAccessAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Access key", comment: ""),
                                      message: NSLocalizedString("New access has been granted", comment: ""),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:nil))
        present(alert, animated: true, completion: nil)
    }
    
    func openErrorAccessAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Access key", comment: ""),
                                      message: NSLocalizedString("Invalid access key", comment: ""),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:nil))
        present(alert, animated: true, completion: nil)
    }
    
    func configurationTextField(textField: UITextField!){
        self.accessKeyTextField = textField
        self.accessKeyTextField.placeholder = NSLocalizedString("Access key", comment: "")
        self.accessKeyTextField.tag = 123
        self.accessKeyTextField.delegate = self
    }
    
    @IBAction func universesButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("Universes", comment: ""),
                                      message: NSLocalizedString("Choose an universe", comment: ""),
                                      preferredStyle: .alert)
        
        for universe in self.currentVenue.universes! {
            let action = UIAlertAction(title: universe.name, style: .default, handler: { (action) -> Void in
                self.mapwizePlugin.setUniverse(universe, for: self.currentVenue)
                self.closePlaceView()
            })
            alert.addAction(action)
        }
        
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: { (action) -> Void in})
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func directionButtonPressed(_ sender: Any) {
        setupDirectionUI()
        self.tryToStartDirection(from: self.directionFrom, to: self.directionTo, isAccessible: self.isPMR)
    }
    
    // MARK: - Venues Custom
    func enterVenue() {
        self.isInVenue = true
        self.configureSearchBar()
        if directionMemory != nil && directionMemory!.venueId.elementsEqual(self.currentVenue.identifier) {
            self.setupDirectionUI()
            self.startDirection(from: directionMemory!.from, to: directionMemory!.to, direction: directionMemory!.direction, fitBounds:false)
        }
        else {
            self.directionMemory = nil
            self.setupDefaultUI()
        }
    }
    
    func exitVenue() {
        self.languageButton.isHidden = true
        self.universesButton.isHidden = true
        self.directionButton.isHidden = true
        self.isInVenue = false
        self.currentVenue = nil
        self.mapwizePlugin.removeMarkers()
        self.configureSearchBar()
        if selectedPlace != nil {
            closePlaceView()
        }
        self.isInDirection = false
        if self.currentSearchMode != nil {
            self.closeSearch()
        }
        else {
            self.mapwizePlugin.setDirection(nil)
            for place in promotedPlaces {
                self.mapwizePlugin.removePromotedPlace(place)
            }
            promotedPlaces.removeAll()
            self.closePlaceView()
            self.directionFrom = nil
            self.directionView.fromSearchBar.text = ""
            self.directionTo = nil
            self.directionView.toSearchBar.text = ""
            self.isInDirection = false
            closeRouteView()
            setupDefaultUI()
        }
    }
    
    func getLanguage() -> String {
        if isInVenue {
            return self.mapwizePlugin.getLanguageFor(self.currentVenue)
        }
        else {
            return self.mapwizePlugin.getPreferredLanguage()
        }
    }
    
    // MARK: - Place Custom
    func select(place: MWZPlace) {

        
        self.bottomSheetVC.placeView.setupViewFor(place: place, language: getLanguage())
        self.bottomSheetVC.setHtmlContent(content: place.details(forLanguage: getLanguage()))
        self.selectedPlace = place
        self.mapwizePlugin.removeMarkers()
        self.mapwizePlugin.addMarker(on: place)
        
        for place in promotedPlaces {
            self.mapwizePlugin.removePromotedPlace(place)
        }
        promotedPlaces.removeAll()
        
        
        self.mapwizePlugin.addPromotedPlace(place)
        promotedPlaces.append(place)
        
        self.bottomSheetVC.show()
        self.mapwizePlugin.setBottomPadding(defaultBottomMargin + 60, animationDuration:0.3)
        
        self.directionTo = place
    }
    
    func select(placeList: MWZPlaceList) {
        self.bottomSheetVC.placeView.setupViewFor(placeList: placeList, language: getLanguage())
        self.mapwizePlugin.removeMarkers()
        
        var places = [MWZPlace]()
        
        for placeId:String in placeList.placeIds {
            MWZApi.getPlaceWithId(placeId, success: { (place) in
                places.append(place!)
                self.mapwizePlugin.addPromotedPlace(place)
                self.promotedPlaces.append(place!)
                self.mapwizePlugin.addMarker(on: place)
            }, failure: { (error) in
                
            })
        }
        self.bottomSheetVC.show()
        self.mapwizePlugin.setBottomPadding(defaultBottomMargin + 60, animationDuration: 0.3)
        self.directionTo = placeList
    }
    
    func closePlaceView() {
        self.mapwizePlugin.removeMarkers()
        self.mapwizePlugin.removePromotedPlace(selectedPlace)
        self.mapwizePlugin.removePromotedPlaces(self.promotedPlaces)
        self.selectedPlace = nil
        self.promotedPlaces = [MWZPlace]()
        //self.placeView.isHidden = true
        self.bottomSheetVC.hide()
        self.mapwizePlugin.setBottomPadding(defaultBottomMargin + 0, animationDuration: 0.3)
        self.directionTo = nil
    }
    
    // MARK: - Route Custom
    func openRouteViewWith(direction: MWZDirection) {
        
        self.bottomSheetVC.placeView.setupViewFor(direction: direction, isAccessible:self.isPMR)
        //self.placeView.isHidden = false
        self.bottomSheetVC.show()
        self.mapwizePlugin.setBottomPadding(defaultBottomMargin + 60, animationDuration: 0.3)
    }
    
    func closeRouteView() {
        //self.placeView.isHidden = true
        self.bottomSheetVC.hide()
        self.mapwizePlugin.setBottomPadding(defaultBottomMargin + 0, animationDuration: 0.3)
    }
    
    func setupEnteringVenue(venue:MWZVenue) {
        let inVenueString =  String(format: NSLocalizedString("Entering in venue", comment: ""), venue.title(forLanguage: getLanguage()))
        self.headerSearchTextField.placeholder = inVenueString
        self.spinner.isHidden = false
        self.spinner.startAnimating()
        self.leftMenuButton.isHidden = true
    }
    
    func setupDefaultUI() {
        self.isInDirection = false
        self.directionView.isHidden = true
        self.universesButton.isHidden = true
        self.languageButton.isHidden = true
        UIApplication.shared.statusBarView?.backgroundColor = .clear
        self.headerView.isHidden = false
        if self.isInVenue {
            self.directionButton.isHidden = false
            if self.currentVenue.supportedLanguages.count > 1 {
                self.languageButton.isHidden = false
            }
            if self.currentVenue.universes.count > 1 {
                self.universesButton.isHidden = false
                if self.languageButton.isHidden {
                    let filteredConstraints = self.view.constraints.filter { $0.identifier == "universeLeading" }
                    if let constaint = filteredConstraints.first {
                        constaint.constant = 10
                    }
                }
                else {
                    let filteredConstraints = self.view.constraints.filter { $0.identifier == "universeLeading" }
                    if let constaint = filteredConstraints.first {
                        constaint.constant = 70
                    }
                }
            }
        }
        let topPadding = headerView.frame.origin.y + headerView.frame.size.height
        mapwizePlugin.setTopPadding(topPadding)
    }
    
    func setupDirectionUI() {
        self.headerView.isHidden = true
        UIApplication.shared.statusBarView?.backgroundColor = UIColor(hex: "C51586")
        self.directionView.isHidden = false
        self.languageButton.isHidden = true
        self.directionButton.isHidden = true
        self.universesButton.isHidden = true
        
        if self.directionFrom == nil && self.mapwizePlugin.userLocation != nil && self.mapwizePlugin.userLocation.floor != nil {
            self.directionFrom = MWZLatLngFloor.init(latitude: self.mapwizePlugin.userLocation.latitude, longitude: self.mapwizePlugin.userLocation.longitude, floor: self.mapwizePlugin.userLocation.floor)
            self.directionView.fromSearchBar.text = NSLocalizedString("Current location", comment: "")
        }
        
        if let mapwizeObject = self.directionTo as? MWZObject {
            self.directionView.toSearchBar.text = mapwizeObject.title(forLanguage: self.getLanguage())
        }
        self.isInDirection = true
        
        let topPadding = directionView.frame.origin.y + directionView.frame.size.height
        mapwizePlugin.setTopPadding(topPadding)
    }
    
    func tryToStartDirection(from:MWZDirectionPoint?, to:MWZDirectionPoint?, isAccessible:Bool) {
        if from != nil && to != nil {
            MWZApi.getDirectionWith(from: from, to: to, isAccessible: self.isPMR, success: { (direction) in
                if direction != nil {
                    self.directionMemory = (self.currentVenue.identifier, from!, to!, direction!)
                    self.startDirection(from:from!, to:to!, direction: direction!, fitBounds:true)
                }
            }, failure: { (error) in
                print(error!)
            })
        }
    }
    
    func startDirection(from:MWZDirectionPoint, to:MWZDirectionPoint, direction:MWZDirection!, fitBounds:Bool!) {
        let opts = MWZDirectionOptions()
        if !fitBounds {
            opts.centerOnStart = false
            opts.setToStartingFloor = false
        }
        self.mapwizePlugin.removeMarkers()
        self.mapwizePlugin.setDirection(direction, options: opts)
        if let place1 = from as? MWZPlace {
            self.mapwizePlugin.addPromotedPlace(place1)
            self.promotedPlaces.append(place1)
            self.directionView.fromSearchBar.text = place1.title(forLanguage: getLanguage())
        }
        else {
            self.directionView.fromSearchBar.text = NSLocalizedString("Coordinates", comment: "")
        }
        if let place2 = to as? MWZPlace {
            self.directionView.toSearchBar.text = place2.title(forLanguage: getLanguage())
            self.mapwizePlugin.addPromotedPlace(place2)
            self.promotedPlaces.append(place2)
        }
        else if let placelist = to as? MWZPlaceList {
            self.directionView.toSearchBar.text = placelist.title(forLanguage: getLanguage())
            MWZApi.getPlaceWithId(direction.to.placeId, success: { (place) in
                if place != nil {
                    self.mapwizePlugin.addPromotedPlace(place)
                    self.promotedPlaces.append(place!)
                }
            }, failure: { (error) in
                
            })
        }
        else {
            self.directionView.toSearchBar.text = NSLocalizedString("Coordinates", comment: "")
        }
        /*var coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
        direction.routes[0].path[0].getValue(&coordinate)
        self.mapView.setCenter(coordinate, zoomLevel: 18, animated: true)
        self.mapwizePlugin.setFollowUserMode(NONE)*/
        self.openRouteViewWith(direction: direction!)
    }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "qrcodescanner" {
            let target = segue.destination as? QrCodeScannerViewController
            target?.delegate = self
        }

        if segue.identifier == "showARView" {
            let target = segue.destination as? ARVC
            target?.direction = self.directionMemory?.direction
        }
    }
    
    func showCredits() {
        popup = UIView(frame:CGRect.zero)
        popup.translatesAutoresizingMaskIntoConstraints = false
        popup.backgroundColor = .white
        popup.layer.shadowOpacity = 0.8
        popup.layer.shadowOffset = CGSize.zero
        self.view.addSubview(popup)
        self.view.bringSubview(toFront: popup)
        NSLayoutConstraint(item: popup, attribute: NSLayoutAttribute.top, relatedBy: .equal,
                           toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: popup, attribute: NSLayoutAttribute.bottom, relatedBy: .equal,
                           toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -30).isActive = true
        NSLayoutConstraint(item: popup, attribute: NSLayoutAttribute.left, relatedBy: .equal,
                           toItem: self.view, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: popup, attribute: NSLayoutAttribute.right, relatedBy: .equal,
                           toItem: self.view, attribute: NSLayoutAttribute.right, multiplier: 1, constant: -10).isActive = true
        
        
        let closeButton = UIButton(frame:CGRect.zero)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        popup.addSubview(closeButton)
        closeButton.setTitle(NSLocalizedString("Close", comment: ""), for: .normal)
        closeButton.backgroundColor = .lightGray
        NSLayoutConstraint(item: closeButton, attribute: NSLayoutAttribute.bottom, relatedBy: .equal,
                           toItem: popup, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: closeButton, attribute: NSLayoutAttribute.left, relatedBy: .equal,
                           toItem: popup, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: closeButton, attribute: NSLayoutAttribute.right, relatedBy: .equal,
                           toItem: popup, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: closeButton, attribute: NSLayoutAttribute.height, relatedBy: .equal,
                           toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 40).isActive = true
        
        let webView = WKWebView(frame:CGRect.zero)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.layer.cornerRadius = 10
        let url = Bundle.main.url(forResource: "credits", withExtension: "html")
        let myRequest = URLRequest(url: url!)
        webView.load(myRequest)
        popup.addSubview(webView)
        NSLayoutConstraint(item: webView, attribute: NSLayoutAttribute.top, relatedBy: .equal,
                           toItem: popup, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: webView, attribute: NSLayoutAttribute.bottom, relatedBy: .equal,
                           toItem: popup, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -40).isActive = true
        NSLayoutConstraint(item: webView, attribute: NSLayoutAttribute.left, relatedBy: .equal,
                           toItem: popup, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: webView, attribute: NSLayoutAttribute.right, relatedBy: .equal,
                           toItem: popup, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0).isActive = true

        closeButton.addTarget(self, action: #selector(hideCredits), for: .touchUpInside)
        
    }
    
    @objc func hideCredits(sender: UIButton) {
        if popup != nil {
            popup.removeFromSuperview()
            popup = nil
        }
    }
    
    func checkIphoneXMargin() {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                defaultBottomMargin = 16.0
                defaultTopMargin = 16.0
            default:
                print("unknown")
            }
        }
    }
    
}

extension MapwizeViewController: QrCodeScannerDelegate {
    func backFromCamera(url: String?) {
        if url != nil {
            MWZApi.getParsedUrlObject(url, success: { (object) in
                self.handleParsedObject(object: object)
            }, failure: { (error) in
                let alert = UIAlertController(title: NSLocalizedString("QrCodeError", comment: ""),
                                              message: NSLocalizedString("QrCodeErrorText", comment: ""),
                                              preferredStyle: .alert)
                
                let cancel = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: { (action) -> Void in})
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            })
        }
    }
    
    func handleParsedObject(object:MWZParsedUrlObject!) {
        if object.accessKey != nil {
            MWZApi.getAccess(object.accessKey, success: {
                object.accessKey = nil
                self.mapwizePlugin.refresh(completionHandler: {
                    let filters = MWZApiFilter()
                    MWZApi.getVenuesWith(filters, success: { (venues) in
                        self.locationProvider.venues = venues
                        self.locationProvider.checkProviders(location: self.locationProvider.lastLocation)
                    }) { (err) in
                        print(err ?? "Unknown error")
                    }
                    self.handleParsedObject(object: object)
                })
            }, failure: { (error) in
                print("Error in access")
            })
        }
        else {
            if object.indoorLocation != nil {
                self.locationProvider.defineLocation(location: object.indoorLocation)
            }
            
            if object.universe != nil {
                self.mapwizePlugin.setUniverse(object.universe, for: nil)
            }
            
            if object.language != nil {
                self.mapwizePlugin.setPreferredLanguage(object.language)
            }
            
            if object.zoom == nil {
                if (object.bounds.ne.latitude == object.bounds.sw.latitude && object.bounds.ne.longitude == object.bounds.sw.longitude) {
                    mapView.setCenter(object.bounds.ne, zoomLevel: 20, animated: false)
                }
                else {
                    let camera = mapView.cameraThatFitsCoordinateBounds(object.bounds)
                    if camera.altitude > 2400 {
                        camera.altitude = 2400
                    }
                    mapView.setCamera(camera, animated: false)
                }
            }
            else {
                if (object.bounds.ne.latitude == object.bounds.sw.latitude && object.bounds.ne.longitude == object.bounds.sw.longitude) {
                    mapView.setCenter(object.bounds.ne, zoomLevel: object.zoom.doubleValue, animated: false)
                }
                else {
                    let latitude = (object.bounds.ne.latitude + object.bounds.sw.latitude) / 2
                    let longitude = (object.bounds.ne.longitude + object.bounds.sw.longitude) / 2
                    let location = CLLocationCoordinate2DMake(latitude, longitude)
                    mapView.setCenter(location, zoomLevel: object.zoom.doubleValue, animated: false)
                }
            }
            
            if object.floor != nil {
                self.mapwizePlugin.setFloor(object.floor)
            }
            
            if object.place != nil {
                self.select(place: object.place)
            }
            
            if object.isAccessible != nil {
                self.isPMR = object.isAccessible.boolValue
            }
            
            if object.direction != nil {
                directionMemory = (object.venue.identifier, object.from, object.to, object.direction)
            }
        }
    }
}


extension MapwizeViewController: SWRevealViewControllerDelegate {
    
    func revealController(_ revealController: SWRevealViewController!, animateTo position: FrontViewPosition) {
        if position.rawValue == 4 {
            self.isLeftMenuOpen = true
        }
        if position.rawValue == 3 {
            self.isLeftMenuOpen = false
        }
        if self.isLeftMenuOpen {
            self.backedView.isHidden = false
        }
        else {
            self.backedView.isHidden = true
        }
    }
    
}

extension MapwizeViewController: DirectionViewDelegate {
    func togglePMRDirection(isPMR: Bool) {
        self.isPMR = isPMR
        self.tryToStartDirection(from: self.directionFrom, to: self.directionTo, isAccessible: self.isPMR)
    }
    
    func reversePlace() {
        let tmpFrom = self.directionFrom
        let tmpTo = self.directionTo
        let texttmp = self.directionView.fromSearchBar.text
        
        self.directionFrom = nil
        self.directionTo = tmpFrom
        self.directionFrom = tmpTo
        
        self.directionView.fromSearchBar.text = self.directionView.toSearchBar.text
        self.directionView.toSearchBar.text = texttmp
        
        self.tryToStartDirection(from: self.directionFrom, to: self.directionTo, isAccessible: self.isPMR)
    }
    
    func exitDirectionView() {
        if self.currentSearchMode != nil {
            self.closeSearch()
        }
        else {
            directionMemory = nil
            self.mapwizePlugin.setDirection(nil)
            for place in promotedPlaces {
                self.mapwizePlugin.removePromotedPlace(place)
            }
            promotedPlaces.removeAll()
            self.closePlaceView()
            self.directionFrom = nil
            self.directionView.fromSearchBar.text = ""
            self.directionTo = nil
            self.directionView.toSearchBar.text = ""
            self.isInDirection = false
            closeRouteView()
            setupDefaultUI()
        }
    }
}

extension MapwizeViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        switch textField.tag {
        case 0:
            self.openSearchTable(mode:.defaultSearch)
        case 1:
            self.openSearchTable(mode:.fromSearch)
        case 2:
            self.openSearchTable(mode:.toSearch)

        default:
            print("ok default")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == accessKeyTextField {
            self.accessKeyAlert!.dismiss(animated: true, completion: nil)
            validAccessKey()
            return false
        }
        return true
    }
    
    func openSearchTable(mode:SearchMode) {
        self.searchBackedView.isHidden = false
        self.currentSearchMode = mode
        self.searchTableView.reloadData()
        
        if isInVenue {
            self.searchTableController.setLanguage(language: self.mapwizePlugin.getLanguageFor(self.currentVenue))
        }
        else {
            self.searchTableController.setLanguage(language: self.mapwizePlugin.getPreferredLanguage())
        }
        
        self.setupSearchResult(query: "", mode: self.currentSearchMode)
        self.view.addSubview(searchTableView)
        self.isInSearch = true
        if mode == .defaultSearch {
            NSLayoutConstraint(item: searchTableView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal,
                               toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -14).isActive = true;
            NSLayoutConstraint(item: searchTableView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal,
                               toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 14).isActive = true;
            NSLayoutConstraint(item: searchTableView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal,
                               toItem: headerView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true;
            setupMenuButtonInSearch()
        }
        if mode == .fromSearch || mode == .toSearch {
            NSLayoutConstraint(item: searchTableView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal,
                               toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -14).isActive = true;
            NSLayoutConstraint(item: searchTableView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal,
                               toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 14).isActive = true;
            NSLayoutConstraint(item: searchTableView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal,
                               toItem: directionView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true;
        }
    }
    
}

// MARK: - SearchBar And SearchController delegate
extension MapwizeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedObject = searchTableController.filteredSearchObjects[indexPath.row]
        self.closeSearchWith(value:selectedObject)
    }
}

extension MapwizeViewController: ILIndoorLocationProviderDelegate {
    func provider(_ provider: ILIndoorLocationProvider!, didFailWithError error: Error!) {
        
    }
    
    func providerDidStart(_ provider: ILIndoorLocationProvider!) {
        
    }
    
    func providerDidStop(_ provider: ILIndoorLocationProvider!) {
        
    }
    
    func provider(_ provider: ILIndoorLocationProvider!, didUpdate location: ILIndoorLocation!) {
        if lastLocation == nil && !startedFromUrl {
            lastLocation = location
            let camera = MGLMapCamera()
            camera.centerCoordinate = CLLocationCoordinate2DMake(lastLocation!.latitude, lastLocation!.longitude)
            camera.altitude = 1200
            if lastLocation!.floor != nil {
                mapwizePlugin.setFloor(locationProvider.lastLocation!.floor!)
            }
            mapView.fly(to: camera, withDuration: 2) {
                
            }
        }
    }
    
}

// MARK: - Mapwize delegate
extension MapwizeViewController: MWZMapwizePluginDelegate {
    func mapwizePluginDidLoad(_ mapwizePlugin: MapwizePlugin!) {
        locationProvider.addDelegate(self)
        self.mapwizePlugin.setIndoorLocationProvider(locationProvider)
        self.mapwizePlugin.setPreferredLanguage(Locale.preferredLanguages[0])
        
        setupDefaultUI()
        
        if (parseObjectFromDeepLink != nil) {
            startedFromUrl = true
            self.handleParsedObject(object: parseObjectFromDeepLink)
        }
        
    }
    
    // MARK: - Venues
    func plugin(_ plugin: MapwizePlugin!, didTapOn venue: MWZVenue!) {
        if (venue != nil) {
            self.mapwizePlugin.center(on: venue, forceEntering:true)
            self.currentVenue = venue
        }
    }

    func plugin(_ plugin: MapwizePlugin!, didEnter venue: MWZVenue!) {
        self.currentVenue = venue
        enterVenue()
    }

    func plugin(_ plugin: MapwizePlugin!, willEnter venue: MWZVenue!) {
        setupEnteringVenue(venue:venue)
    }
    
    func plugin(_ plugin: MapwizePlugin!, didExitVenue venue: MWZVenue!) {
        self.exitVenue()
        
    }
    
    func plugin(_ plugin: MapwizePlugin!, didChange followUserMode: FollowUserMode) {
        if (followUserMode == FOLLOW_USER) {
            let camera = mapView.camera
            camera.pitch = 0.0
            mapView.setCamera(camera, animated: false)
        }
        if (followUserMode == FOLLOW_USER_AND_HEADING) {
            let camera = mapView.camera
            camera.pitch = 45.0
            mapView.setCamera(camera, animated: false)
        }
    }

    // MARK: - Place
    func plugin(_ plugin: MapwizePlugin!, didTapOn place: MWZPlace!) {
        if !self.isInDirection {
            self.select(place: place)
        }
    }
    
    func plugin(_ plugin: MapwizePlugin!, didTapOnMap latLngFloor: MWZLatLngFloor) {
        if self.isLeftMenuOpen {
            self.revealLeftMenu()
        }
        
        if !self.isInDirection && selectedPlace != nil {
            closePlaceView()
        }
        if self.currentSearchMode != nil {
            self.closeSearch()
        }
    }
    
    func plugin(_ plugin: MapwizePlugin!, didChangeFloor floor: NSNumber!) {

    }
}

extension MapwizeViewController: RouteViewDelegate{
    func showARview() {
//        self.navigationController?.pushViewController(ARVC(), animated: true)
        print("delegate showARView")
        self.performSegue(withIdentifier: "showARView", sender: nil)
    }
    
}
