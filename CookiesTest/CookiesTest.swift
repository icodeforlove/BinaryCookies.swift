import XCTest

class CookiesTest: XCTestCase {
    var data = NSData(base64EncodedString: "Y29vawAAAAsAAAAMAAABkgAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAQAAAAAAAAAAAAAAAQAEAAAAHAAAAHkAAADcAAAANwEAAAAAAABdAAAAAAAAAAQAAAAAAAAAOAAAAEwAAABVAAAAVwAAAAAAAAAAAAAAAAAAZ3SDu0EAAADnIoK7QXVybGVjaG8uYXBwc3BvdC5jb20AaHR0cE9ubHkALwB2YWx1ZQBjAAAAAAAAAAUAAAAAAAAAOAAAAEwAAABbAAAAXQAAAAAAAAAAAAAAAAAAZ3SDu0EAAADnIoK7QXVybGVjaG8uYXBwc3BvdC5jb20AaHR0cE9ubHlTZWN1cmUALwB2YWx1ZQBbAAAAAAAAAAAAAAAAAAAAOAAAAEwAAABTAAAAVQAAAAAAAAAAAAAAAAAAZ3SDu0EAAADnIoK7QXVybGVjaG8uYXBwc3BvdC5jb20Abm9ybWFsAC8AdmFsdWUAWwAAAAAAAAABAAAAAAAAADgAAABMAAAAUwAAAFUAAAAAAAAAAAAAAAAAAGd0g7tBAAAA5yKCu0F1cmxlY2hvLmFwcHNwb3QuY29tAHNlY3VyZQAvAHZhbHVlAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAFjMHFyAFAAAAS2JwbGlzdDAw0QECXxAYTlNIVFRQQ29va2llQWNjZXB0UG9saWN5EAIICyYAAAAAAAABAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAKA==", options: NSDataBase64DecodingOptions(rawValue: 0));
    
    func testParsing() {
        self.measureBlock {
            BinaryCookies.parse(self.data!, callback: {
                (cookies) in
                
                self.testHttpOnlyCookie(cookies[0]);
                self.testHttpOnlySecureCookie(cookies[1]);
                self.testNormalCookie(cookies[2]);
                self.testSecureCookie(cookies[3]);
            });
        }
    }
    
    func testHttpOnlyCookie (cookie:Cookie) {
        XCTAssert(cookie.name == "httpOnly", "target cookie");
        XCTAssert(cookie.expiration == 1439907046000, "expiration");
        XCTAssert(cookie.creation == 1439820646000, "creation");
        XCTAssert(cookie.domain == "urlecho.appspot.com", "domain");
        XCTAssert(cookie.value == "value", "value");
        XCTAssert(cookie.secure == false, "secure");
        XCTAssert(cookie.http == true, "http");
    }
    
    func testHttpOnlySecureCookie (cookie:Cookie) {
        XCTAssert(cookie.name == "httpOnlySecure", "target cookie");
        XCTAssert(cookie.expiration == 1439907046000, "expiration");
        XCTAssert(cookie.creation == 1439820646000, "creation");
        XCTAssert(cookie.domain == "urlecho.appspot.com", "domain");
        XCTAssert(cookie.value == "value", "value");
        XCTAssert(cookie.secure == true, "secure");
        XCTAssert(cookie.http == true, "http");
    }
    
    func testNormalCookie (cookie:Cookie) {
        XCTAssert(cookie.name == "normal", "target cookie");
        XCTAssert(cookie.expiration == 1439907046000, "expiration");
        XCTAssert(cookie.creation == 1439820646000, "creation");
        XCTAssert(cookie.domain == "urlecho.appspot.com", "domain");
        XCTAssert(cookie.value == "value", "value");
        XCTAssert(cookie.secure == false, "secure");
        XCTAssert(cookie.http == false, "http");
    }
    
    func testSecureCookie (cookie:Cookie) {
        XCTAssert(cookie.name == "secure", "target cookie");
        XCTAssert(cookie.expiration == 1439907046000, "expiration");
        XCTAssert(cookie.creation == 1439820646000, "creation");
        XCTAssert(cookie.domain == "urlecho.appspot.com", "domain");
        XCTAssert(cookie.value == "value", "value");
        XCTAssert(cookie.secure == true, "secure");
        XCTAssert(cookie.http == false, "http");
    }
}
