import Foundation

extension NSData {
    func toString (encoding:UInt) -> String {
        return NSString(data: self, encoding: encoding) as! String;
    }
}

class BinaryReader {
    private var data:NSData;
    
    var bufferPosition:Int = 0;
    
    init (data: NSData) {
        self.data = data;
    }
    
    func readSlice (length:Int) -> NSData {
        let slice = self.data.subdataWithRange(NSMakeRange(bufferPosition, length));
        bufferPosition += length;
        return slice;
    }
    
    func readDoubleBE () -> Int64 {
        let data = readDoubleBE(bufferPosition);
        bufferPosition += 8;
        return data;
    }
    
    func readDoubleBE (offset:Int) -> Int64 {
        let data = slice(offset, len: 8);
        var out:double_t = 0;
        memcpy(&out, data.bytes, sizeof(double_t));
        return Int64(NSSwapHostDoubleToBig(Double(out)).v);
    }
    
    func readIntBE () -> UInt32 {
        let data = readIntBE(bufferPosition);
        bufferPosition += 4;
        return data;
    }
    
    func readIntBE (offset:Int) -> UInt32 {
        let data = slice(offset, len: 4);
        var out:NSInteger = 0;
        data.getBytes(&out, length: sizeof(NSInteger));
        return CFSwapInt32HostToBig(UInt32(out));
    }
    
    func readDoubleLE () -> Int64 {
        let data = readDoubleLE(bufferPosition);
        bufferPosition += 8;
        return data;
    }
    
    func readDoubleLE (offset:Int) -> Int64 {
        let data = slice(offset, len: 8);
        var out:double_t = 0;
        memcpy(&out, data.bytes, sizeof(double_t));
        return Int64(out);
    }
    
    func readIntLE () -> UInt32 {
        let data = readIntLE(bufferPosition);
        bufferPosition += 4;
        return data;
    }
    
    func readIntLE (offset:Int) -> UInt32 {
        let data = slice(offset, len: 4);
        var out:NSInteger = 0;
        data.getBytes(&out, length: sizeof(NSInteger));
        return UInt32(out);
    }
    
    func slice (loc: Int, len: Int) -> NSData {
        return self.data.subdataWithRange(NSMakeRange(loc, len));
    }
}

enum BinaryCookiesError: ErrorType {
    case BadFileHeader
    case InvalidEndOfCookieData
    case UnexpectedCookieHeaderValue
}

struct Cookie {
    var expiration:Int64;
    var creation:Int64;
    var domain:String;
    var name:String;
    var path:String;
    var value:String;
    var secure:Bool = false;
    var http:Bool = false;
}

class CookieParser {
    var numPages:UInt32 = 0;
    var pageSizes:[UInt32] = [];
    var pageNumCookies:[UInt32] = [];
    var pageCookieOffsets:[[UInt32]] = [];
    var pages:[BinaryReader] = [];
    var cookieData:[[BinaryReader]] = [];
    var cookies:[Cookie] = [];
    
    var reader:BinaryReader?;
    
    func processCookieData (data:NSData) throws -> [Cookie] {
        reader = BinaryReader(data: data);
        
        let header = reader!.readSlice(4).toString(NSUTF8StringEncoding);
        
        if (header == "cook") {
            getNumPages();
            getPageSizes();
            getPages();
            
            for (index, _) in pages.enumerate() {
                try getNumCookies(index);
                getCookieOffsets(index);
                getCookieData(index);
                
                for (cookieIndex, _) in cookieData[index].enumerate() {
                    try parseCookieData(cookieData[index][cookieIndex]);
                }
            }
        } else {
            throw BinaryCookiesError.BadFileHeader;
        }
        
        return cookies;
    }
    
    func parseCookieData (cookie:BinaryReader) throws {
        let macEpochOffset:Int64 = 978307199;
        var offsets:[UInt32] = [UInt32]();
        
        cookie.readIntLE(0); // unknown
        cookie.readIntLE(4); // unknown2
        let flags = cookie.readIntLE(4 + 4); // flags
        cookie.readIntLE(8 + 4); // unknown3
        offsets.append(cookie.readIntLE(12 + 4)); // domain
        offsets.append(cookie.readIntLE(16 + 4)); // name
        offsets.append(cookie.readIntLE(20 + 4)); // path
        offsets.append(cookie.readIntLE(24 + 4)); // value
        
        let endOfCookie = cookie.readIntLE(28 + 4);
        
        if (endOfCookie != 0) {
            throw BinaryCookiesError.InvalidEndOfCookieData;
        }
        
        let expiration = (cookie.readDoubleLE(32 + 8) + macEpochOffset) * 1000;
        let creation = (cookie.readDoubleLE(40 + 8) + macEpochOffset) * 1000;
        var domain:String = "";
        var name:String = "";
        var path:String = "";
        var value:String = "";
        var secure:Bool = false;
        var http:Bool = false;
        
        let nsCookieString = cookie.data.toString(NSASCIIStringEncoding) as NSString;
        
        for (index, offset) in offsets.enumerate() {
            let endOffset = nsCookieString.rangeOfString("\u{0000}", options: NSStringCompareOptions.CaseInsensitiveSearch, range: NSMakeRange(Int(offset), nsCookieString.length - Int(offset))).location;
            
            let string = nsCookieString.substringWithRange(NSMakeRange(Int(offset), Int(endOffset)-Int(offset)));
            
            if (index == 0) {
                domain = string;
            } else if (index == 1) {
                name = string;
            } else if (index == 2) {
                path = string;
            } else if (index == 3) {
                value = string;
            }
        }
        
        if (flags == 1) {
            secure = true;
        } else if (flags == 4) {
            http = true;
        } else if (flags == 5) {
            secure = true;
            http = true;
        }
        
        cookies.append(Cookie(expiration: expiration, creation: creation, domain: domain, name: name, path: path, value: value, secure: secure, http: http));
    }
    
    func getNumPages () {
        numPages = reader!.readIntBE();
    }
    
    func getCookieOffsets (index:Int) {
        let page = pages[index];
        var offsets:[UInt32] = [UInt32]();
        
        let numCookies = pageNumCookies[index];
        
        for (var i = 0; i < Int(numCookies); i++) {
            offsets.append(page.readIntLE());
        }
        
        pageCookieOffsets.append(offsets);
    }
    
    func getNumCookies (index:Int) throws {
        let page = pages[index];
        
        let header = page.readIntBE();
        
        if (header != 256) {
            throw BinaryCookiesError.UnexpectedCookieHeaderValue;
        }
        
        pageNumCookies.append(page.readIntLE());
    }
    
    func getCookieData (index:Int) {
        let page = pages[index];
        
        let cookieOffsets = pageCookieOffsets[index];
        
        var pageCookies:[BinaryReader] = [BinaryReader]();
        
        for (_, cookieOffset) in cookieOffsets.enumerate() {
            let cookieSize = page.readIntLE(Int(cookieOffset));
            
            pageCookies.append(BinaryReader(data: page.slice(Int(cookieOffset), len: Int(cookieSize))));
        }
        
        cookieData.append(pageCookies);
    }
    
    func getPageSizes () {
        for (var i = 0; i < Int(numPages); i++) {
            pageSizes.append(reader!.readIntBE());
        }
    }
    
    func getPages () {
        for (_, pageSize) in pageSizes.enumerate() {
            pages.append(BinaryReader(data: reader!.readSlice(Int(pageSize))));
        }
    }
}

public class BinaryCookies {
    class func parse (cookiePath:String, callback:(BinaryCookiesError?, [Cookie]?) -> ()) {
        let parser = CookieParser();
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let data:NSData! = NSData(contentsOfURL: NSURL(fileURLWithPath: cookiePath));

            do {
                callback(nil, try parser.processCookieData(data));
            } catch {
                callback(error as? BinaryCookiesError, nil);
            }
        });
    }
    
    class func parse (cookieURL:NSURL, callback:(BinaryCookiesError?, [Cookie]?) -> ()) {
        let parser = CookieParser();
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let data:NSData! = NSData(contentsOfURL: cookieURL);
            
            do {
                callback(nil, try parser.processCookieData(data));
            } catch {
                callback(error as? BinaryCookiesError, nil);
            }
        });
    }
    
    class func parse (data:NSData, callback:(BinaryCookiesError?, [Cookie]?) -> ()) {
        let parser = CookieParser();
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            do {
                callback(nil, try parser.processCookieData(data));
            } catch {
                callback(error as? BinaryCookiesError, nil);
            }
        });
    }
}