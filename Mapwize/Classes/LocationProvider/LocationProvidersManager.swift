import Foundation
import SelectorIndoorLocationProvider
import GPSIndoorLocationProvider
import SocketIndoorLocationProviderObjc
import ManualIndoorLocationProvider
import MapwizeForMapbox

class LocationProvidersManager: ILSelectorIndoorLocationProvider {
    
    let MIN_DISTANCE_TO_ACTIVATE = 1000.0
    var venues:[MWZVenue]?
    var activeVenue:MWZVenue?
    var selectorProvider:ILSelectorIndoorLocationProvider?
    var gpsProvider:ILGPSIndoorLocationProvider?
    var socketProvider:ILSocketIndoorLocationProvider?
    var polestarProvider:ILPolestarIndoorLocationProvider?
    var manualProvider:ILManualIndoorLocationProvider?
    var innerDelegate:ILIndoorLocationProviderDelegate?
    
    override init() {
        super.init(validity: 30000)
        self.gpsProvider = ILGPSIndoorLocationProvider()
        innerDelegate = InnerDelegate(parent: self)
        self.gpsProvider?.addDelegate(innerDelegate)
        self.add(gpsProvider)
        self.manualProvider = ILManualIndoorLocationProvider()
        self.add(manualProvider)
    }
    
    func defineLocation(location:ILIndoorLocation) {
        self.manualProvider?.setIndoorLocation(location)
    }
    
    func activateSocket(socketUrl:String) {
        if self.socketProvider != nil {
            self.remove(self.socketProvider)
        }
        self.socketProvider = ILSocketIndoorLocationProvider(url: socketUrl)
        self.add(self.socketProvider)
        self.socketProvider?.start()
    }
    
    func activatePolestar(polestarKey:String, polestarFloors:[[String:Double]]?) {
        if self.polestarProvider != nil {
            self.remove(self.polestarProvider)
        }
        self.polestarProvider = ILPolestarIndoorLocationProvider(polestarKey: polestarKey)
        if polestarFloors != nil {
            var floors = [Double:Double]()
            for f in polestarFloors! {
                floors[f["altitude"]!] = f["floor"]!
            }
            self.polestarProvider?.floorByAltitude = floors as [NSNumber : NSNumber]
        }
        self.add(self.polestarProvider)
        self.polestarProvider?.start()
    }

    func deactivatePolestar() {
        if self.polestarProvider != nil {
            self.remove(self.polestarProvider)
        }
        self.polestarProvider?.stop()
        self.polestarProvider = nil
    }
    
    func deactivateSocket() {
        if self.socketProvider != nil {
            self.remove(self.socketProvider)
            self.socketProvider?.stop()
            self.socketProvider = nil
        }
    }
    
    func deactivateAll() {
        deactivateSocket()
        deactivatePolestar()
    }
    
    override func stop() {
        self.gpsProvider?.stop()
        self.manualProvider?.stop()
        self.socketProvider?.stop()
    }
    
    func activateVenue(venue:MWZVenue!) {
        let providers = venue.indoorLocationProviders as? [String:Any]
        if (providers == nil) {
            return;
        }
        let socketProviderDic = providers!["socket"] as? [String : Any]
        if socketProviderDic != nil {
            let enabled:Bool = socketProviderDic!["enabled"] as! Bool
            let url = socketProviderDic!["socketUrl"] as! String?
            if (url != nil && enabled) {
                activateSocket(socketUrl: url!)
            }
        }
        let polestarProviderDic = providers!["polestar"] as? [String : Any]
        if polestarProviderDic != nil {
            let enabled:Bool = polestarProviderDic!["enabled"] as! Bool
            let apiKey = polestarProviderDic!["apiKey"] as! String?
            let floors = polestarProviderDic!["floors"] as! [[String : Double]]?
            if (apiKey != nil && enabled) {
                activatePolestar(polestarKey: apiKey!, polestarFloors: floors)
            }
        }
    }
    
    func getNearestVenue(location:ILIndoorLocation) -> MWZVenue? {
        if (self.venues == nil || self.venues?.count == 0) {
            return nil
        }
        let latLng:MWZLatLng = MWZLatLng(latitude: location.latitude, longitude: location.longitude)
        var nearestVenue = self.venues![0]
        var distanceMin = self.getDistance(from: latLng, venue: nearestVenue)
        for venue in self.venues! {
            let distance = self.getDistance(from: latLng, venue: venue)
            if distance < distanceMin {
                nearestVenue = venue
                distanceMin = distance
            }
        }
        if distanceMin < self.MIN_DISTANCE_TO_ACTIVATE {
            return nearestVenue
        }
        return nil
    }
    
    func getDistance(from:MWZLatLng, venue:MWZVenue) -> Double {
        let to:MWZLatLng! = venue.marker
        let R = 6381000.0
        let lat1 = from.coordinates.latitude * .pi / 180.0
        let lat2 = to.coordinates.latitude * .pi / 180.0
        let deltaLat = (from.coordinates.latitude - to.coordinates.latitude) * .pi / 180.0
        let deltaLng = (from.coordinates.longitude - to.coordinates.longitude) * .pi / 180.0
        let a = sin(deltaLat/2) * sin(deltaLat/2) +
            cos(lat1) * cos(lat2) *
            sin(deltaLng/2) * sin(deltaLng/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        return R * c
    }
    
    func checkProviders(location: ILIndoorLocation?) {
        if location == nil {
            return;
        }
        let venue = getNearestVenue(location: location!)
        if venue == nil {
            deactivateAll()
        } else if (activeVenue != venue) {
            deactivateAll()
            activateVenue(venue: venue)
        }
    }
    
    class InnerDelegate: NSObject, ILIndoorLocationProviderDelegate {
        
        let parent:LocationProvidersManager!
        
        init(parent:LocationProvidersManager) {
            self.parent = parent
            super.init()
        }
        
        func provider(_ provider: ILIndoorLocationProvider!, didFailWithError error: Error!) {
            
        }
        
        func providerDidStart(_ provider: ILIndoorLocationProvider!) {
            
        }
        
        func providerDidStop(_ provider: ILIndoorLocationProvider!) {
            
        }
        
        func provider(_ provider: ILIndoorLocationProvider!, didUpdate location: ILIndoorLocation!) {
            parent.checkProviders(location: location)
        }
    }
}
