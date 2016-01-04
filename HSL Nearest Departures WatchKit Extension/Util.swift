import Foundation

public class Util {

    static func getNearestStopInfo(lat:String, lon:String, callback: (Dictionary<String, String>) -> Void) {
        HTTPGetJSONArray(
            "http://api.reittiopas.fi/hsl/prod/" +
            "?user=suominentoni" +
            "&pass=***REMOVED***" +
            "&request=reverse_geocode" +
            "&epsg_in=wgs84" +
            "&coordinate=" +
                String(lon) + "," +
                String(lat) +
            "&result_contains=stop"
        ) {
        (data: NSArray, error: String?) -> Void in
            if error != nil {
                print("Error getting JSON")
                print(error)
            } else {
                if let feed = data.firstObject as? NSDictionary ,
                    let details = feed["details"] as? NSDictionary,
                    let name = feed["name"] as? String,
                    let code = details["code"] as? String{
                        let stopInfo: [String: String] = ["code": code, "name": name]
                        callback(stopInfo)
                }
            }
        }
    }

    static func getNextDepartureForStop(stopCode: String, callback: (Dictionary<String, String>) -> Void) {
        HTTPGetJSONArray(
            "http://api.reittiopas.fi/hsl/prod/" +
            "?user=suominentoni" +
            "&pass=***REMOVED***" +
            "&request=stop" +
            "&code=" + stopCode
        ) {
        (data: NSArray, error: String?) -> Void in
            if error != nil {
                print("Error getting JSON")
                print(error)
            } else {
                if let feed = data.firstObject as? NSDictionary,
                    let departures = feed["departures"] as? NSArray,
                    let nextDeparture = departures.firstObject as? NSDictionary,
                    let time = nextDeparture["time"] as? NSNumber,
                    let code = nextDeparture["code"] as? String{
                        let departureInfo: [String: String] = ["code": code, "time": String(time)]
                        callback(departureInfo)
                }
            }
        }
    }

    static func getLineInfo(lineCode: String, callback: (Dictionary<String, String>) -> Void) {
        HTTPGetJSONArray(
            "http://api.reittiopas.fi/hsl/prod/" +
            "?user=suominentoni" +
            "&pass=***REMOVED***" +
            "&query=" + lineCode +
            "&request=lines"
        ) {
        (data: NSArray, error: String?) -> Void in
            if error != nil {
                print("Error getting JSON")
                print(error)
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
        callback: (Dictionary<String, AnyObject>, String?) -> Void) {
            print(url)
            let request = NSMutableURLRequest(URL: NSURL(string: url.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)!)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            HTTPsendRequest(request) {
                (data: String, error: String?) -> Void in
                if error != nil {
                    callback(Dictionary<String, AnyObject>(), error)
                } else {
                    let jsonObj:Dictionary<String, AnyObject>
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
                    print("Error parsing JSON")
                }
        }
        return NSArray()
    }

    static private func JSONParseDict(jsonString:String) -> Dictionary<String, AnyObject> {
        print(jsonString)
        if let data: NSData = jsonString.dataUsingEncoding(
            NSUTF8StringEncoding){
                do{
                    if let jsonObj = try NSJSONSerialization.JSONObjectWithData(
                        data,
                        options: NSJSONReadingOptions(rawValue: 0)) as? Dictionary<String, AnyObject>{
                            return jsonObj
                    }
                }catch{
                    print("Error parsing JSON")
                }
        }
        return [String: AnyObject]()
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