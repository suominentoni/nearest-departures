import Foundation

public class HSL {

    static let baseQuery = "http://api.reittiopas.fi/hsl/prod/?user=suominentoni&pass=***REMOVED***"

    static func getNearestStops(lat: Double, lon: Double, successCallback: (stops: [Stop]) -> Void) {

        self.getNearestStopsInfo(String(lat), lon: String(lon)) {
        (stopInfos:NSArray) -> Void in
            var nearestStops = [Stop]()

            for item in stopInfos {
                if let name = item["name"] as? String,
                let codeShort = item["codeShort"] as? String,
                let distance = item["dist"] as? Int,
                let code = item["code"] as? String {
                    let stop = Stop(name: name, distance: distance, codeLong: code, codeShort: codeShort)
                    nearestStops.append(stop)
                }

            }
            successCallback(stops: nearestStops)
        }
    }

    private static func formatTime(time:Int) -> String {
        // Converts time from 2515 (which is how the API presents times past midnight) to "01:15"
            if time >= 2400 {
                let timeString = String(time)
                let hours = timeString.substringWithRange(timeString.startIndex..<timeString.startIndex.advancedBy(2))
                let hoursCorrected = Int(hours)! - 24
                let minutes = timeString.substringWithRange(timeString.startIndex.advancedBy(2)..<timeString.endIndex)
                return String(hoursCorrected) + ":" + minutes
            }

        var result = String(time)
        result.insert(":", atIndex: String(time).endIndex.predecessor().predecessor())
        return result
    }

    static func getNearestStopsInfo(lat:String, lon:String, callback: (NSArray) -> Void) {
        let query = baseQuery +
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
        let query = baseQuery +
            "&request=stops_area&" +
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

    static func getNextDeparturesForStop(stopCode: String, callback: ([Departure]) -> Void) {
        HTTPGetJSONArray(
            baseQuery +
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
                    var nextDepartures: [Departure] = []

                    for departure in departures{
                        if let lineCode = departure["code"] as? String,
                        let time = departure["time"] as? Int {
                            nextDepartures.append(Departure(line: Line(codeLong: lineCode, codeShort: nil), time: formatTime(time)))
                        }
                    }

                    // get distinct long line codes
                    let longLineCodes = nextDepartures.reduce([], combine: {(current: Array, dep: Departure) -> [String] in
                        if(current.contains(dep.line.codeLong)) {
                            return current
                        } else {
                            return current + [dep.line.codeLong]
                        }
                    })

                    // get short code for each distinct long line code
                    let lineInfoGroup = dispatch_group_create()
                    var shortLineCodes = [String: String]()

                    for code in longLineCodes {
                        dispatch_group_enter(lineInfoGroup)
                        getLineInfo(code, callback: {lineInfo in
                            shortLineCodes[code] = (lineInfo["code"] as! String)
                            dispatch_group_leave(lineInfoGroup)
                        })
                    }

                    // populate next departures with short line codes
                    dispatch_group_notify(lineInfoGroup,dispatch_get_main_queue(), { _ in
                        print(shortLineCodes)
                        let nextDeparturesWithShortLineCodes = nextDepartures.map({departure -> Departure in
                            if(shortLineCodes[departure.line.codeLong] != nil) {
                                return Departure(
                                    line: Line(
                                        codeLong: departure.line.codeLong,
                                        codeShort: shortLineCodes[departure.line.codeLong]),
                                    time: departure.time)
                            } else {
                                return departure
                            }
                        })
                        callback(nextDeparturesWithShortLineCodes)
                    });
                }
            }
        }
    }

    static func getLineInfo(lineCode: String, callback: (NSDictionary) -> Void) {
        HTTPGetJSONArray(
            baseQuery +
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
