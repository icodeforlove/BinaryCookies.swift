import Foundation

var data = NSData(base64EncodedString: "Y29vawAAAAsAAAAMAAABkgAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAQAAAAAAAAAAAAAAAQAEAAAAHAAAAHkAAADcAAAANwEAAAAAAABdAAAAAAAAAAQAAAAAAAAAOAAAAEwAAABVAAAAVwAAAAAAAAAAAAAAAAAAZ3SDu0EAAADnIoK7QXVybGVjaG8uYXBwc3BvdC5jb20AaHR0cE9ubHkALwB2YWx1ZQBjAAAAAAAAAAUAAAAAAAAAOAAAAEwAAABbAAAAXQAAAAAAAAAAAAAAAAAAZ3SDu0EAAADnIoK7QXVybGVjaG8uYXBwc3BvdC5jb20AaHR0cE9ubHlTZWN1cmUALwB2YWx1ZQBbAAAAAAAAAAAAAAAAAAAAOAAAAEwAAABTAAAAVQAAAAAAAAAAAAAAAAAAZ3SDu0EAAADnIoK7QXVybGVjaG8uYXBwc3BvdC5jb20Abm9ybWFsAC8AdmFsdWUAWwAAAAAAAAABAAAAAAAAADgAAABMAAAAUwAAAFUAAAAAAAAAAAAAAAAAAGd0g7tBAAAA5yKCu0F1cmxlY2hvLmFwcHNwb3QuY29tAHNlY3VyZQAvAHZhbHVlAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAFjMHFyAFAAAAS2JwbGlzdDAw0QECXxAYTlNIVFRQQ29va2llQWNjZXB0UG9saWN5EAIICyYAAAAAAAABAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAKA==", options: NSDataBase64DecodingOptions(rawValue: 0));

BinaryCookies.parse(data!, callback: {
    (error:BinaryCookiesError?, cookies) in

    if let cookies = cookies {
        print(cookies);
    } else {
        print(error);
    }
});

CFRunLoopRun();