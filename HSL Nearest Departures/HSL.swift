import Foundation

public class HSL {

    static func getNearestStops(lat: Double, lon: Double, successCallback: (departureInfo: [NSDictionary]) -> Void) {

        self.getNearestStopsInfo(String(lat), lon: String(lon)) {
        (stopInfos:NSArray) -> Void in
            var nearestStops = [NSDictionary]()

            for item in stopInfos {
                var stopInfo = [String: String]()

                if let name = item["name"] as? String,
                let codeShort = item["codeShort"] as? String,
                let distance = item["dist"] as? Int,
                let code = item["code"] as? String {
                    stopInfo = [
                        "name": name,
                        "distance": String(distance),
                        "code": code,
                        "codeShort": codeShort
                    ]
                    nearestStops.append(stopInfo)
                }

            }
            successCallback(departureInfo: nearestStops)
        }
    }

    private static func formatTimeString(time:String) -> String {
        var result = time
        result.insert(":", atIndex: time.endIndex.predecessor().predecessor())
        return result
    }

    static func getNearestStopsInfo(lat:String, lon:String, callback: (NSArray) -> Void) {
        let query = "http://api.reittiopas.fi/hsl/prod/" +
        "?user=suominentoni" +
        "&pass=***REMOVED***" +
        "&request=stops_area&" +
        "&epsg_in=wgs84" +
        "&center_coordinate=" +
        String(lon) + "," +
        String(lat) +
        "&diameter=500"

        HTTPGetJSONArray(query) {
                (data: NSArray, error: String?) -> Void in
                if error != nil {
                    NSLog("Error getting JSON")
                    NSLog(error!)
                } else {
                    callback(data)
                }
        }
    }
    static func getNearestStopsInfoByReverseGeocoding(lat:String, lon:String, limit: Int, callback: (NSArray) -> Void) {
        let query = "http://api.reittiopas.fi/hsl/prod/" +
            "?user=suominentoni" +
            "&pass=***REMOVED***" +
            "&request=reverse_geocode" +
            "&epsg_in=wgs84" +
            "&coordinate=" +
            String(lon) + "," +
            String(lat) +
            "&limit=" +
            String(limit) +
            "&result_contains=stop"

        HTTPGetJSONArray(query) {
                (data: NSArray, error: String?) -> Void in
                if error != nil {
                    NSLog("Error getting JSON")
                    NSLog(error!)
                } else {
                    callback(data)
                }
        }
    }

    static func getNextDeparturesForStop(stopCode: String, callback: (NSArray) -> Void) {
        HTTPGetJSONArray(
            "http://api.reittiopas.fi/hsl/prod/" +
                "?user=suominentoni" +
                "&pass=***REMOVED***" +
                "&request=stop" +
                "&code=" + stopCode
        ) {
            (data: NSArray, error: String?) -> Void in
            if error != nil {
                NSLog("Error getting JSON")
                NSLog(error!)
            } else {
                if let feed = data.firstObject as? NSDictionary,
                let departures = feed["departures"] as? NSArray{
                    var nextDepartures = [[String: String]]()

                    for departure in departures{
                        if let lineCode = departure["code"] as? String,
                        let time = departure["time"] as? Int{
                            var nextDeparture = [String: String]()
                            nextDeparture["time"] = formatTimeString(String(time))
                            nextDeparture["code"] = lineCode

                            nextDepartures.append(nextDeparture)
                        }
                    }
                    callback(nextDepartures)
                }
            }
        }
    }

    static func getLineInfo(lineCode: String, callback: (NSDictionary) -> Void) {
        HTTPGetJSONArray(
            "http://api.reittiopas.fi/hsl/prod/" +
                "?user=suominentoni" +
                "&pass=***REMOVED***" +
                "&query=" + lineCode +
            "&request=lines"
            ) {
                (data: NSArray, error: String?) -> Void in
                if error != nil {
                    NSLog("Error getting JSON")
                    NSLog(error!)
                } else {
                    if let feed = data.firstObject as? NSDictionary,
                        let code = feed["code_short"] as? String,
                        let name = feed["name"] as? String{
                            let lineInfo: [String: String] = ["code": code, "name": name]
                            callback(lineInfo)
                    }
                }
        }
    }

    static func HTTPGetJSONObject(
        url: String,
        callback: (NSDictionary, String?) -> Void) {
            NSLog("Sending HTTP GET request: " + url)
            let request = NSMutableURLRequest(URL: NSURL(string: url.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)!)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            HTTPsendRequest(request) {
                (data: String, error: String?) -> Void in
                if error != nil {
                    callback(NSDictionary(), error)
                } else {
                    let jsonObj:NSDictionary
                    jsonObj = self.JSONParseDict(data)
                    callback(jsonObj, nil)
                }
            }
    }

    static func HTTPGetJSONArray(
        url: String,
        callback: (NSArray, String?) -> Void) {
            print(url)
            let request = NSMutableURLRequest(URL: NSURL(string: url.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)!)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            HTTPsendRequest(request) {
                (data: String, error: String?) -> Void in
                if error != nil {
                    callback(NSArray(), error)
                } else {
                    let jsonObj:NSArray
                    jsonObj = self.JSONParseArray(data)
                    callback(jsonObj, nil)
                }
            }
    }

    static private func JSONParseArray(jsonString:String) -> NSArray {
        if let data: NSData = jsonString.dataUsingEncoding(
            NSUTF8StringEncoding){
                do{
                    if let jsonObj = try NSJSONSerialization.JSONObjectWithData(
                        data,
                        options: NSJSONReadingOptions(rawValue: 0)) as? NSArray{
                            return jsonObj
                    }
                }catch{
                    NSLog("Error parsing JSON")
                }
        }
        return NSArray()
    }

    static private func JSONParseDict(jsonString:String) -> NSDictionary {
        print(jsonString)
        if let data: NSData = jsonString.dataUsingEncoding(
            NSUTF8StringEncoding){
                do{
                    if let jsonObj = try NSJSONSerialization.JSONObjectWithData(
                        data,
                        options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary{
                            return jsonObj
                    }
                }catch{
                    NSLog("Error parsing JSON")
                }
        }
        return NSDictionary()
    }

    static private func HTTPsendRequest(request: NSMutableURLRequest,
        callback: (String, String?) -> Void) {
            let task = NSURLSession.sharedSession().dataTaskWithRequest(
                request, completionHandler :
                {
                    data, response, error in
                    if error != nil {
                        callback("", (error!.localizedDescription) as String)
                    } else {
                        callback(
                            NSString(data: data!, encoding: NSUTF8StringEncoding) as! String,
                            nil
                        )
                    }
            })
            task.resume()
    }
}
