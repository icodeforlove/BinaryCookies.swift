# BinaryCookies.swift

Cookie parser for Safari's `Cookies.binarycookies` files

# Cookie Data

each cookie contains the following data

- expiration
- creation
- domain
- name
- path
- value
- secure
- http

# Usage

```swift
BinaryCookies.parse(NSHomeDirectory() + "/Library/Cookies/Cookies.binarycookies", callback: {
    (error:BinaryCookiesError?, cookies) in

    if let cookies = cookies {
        print(cookies);
    } else {
        print(error);
    }
});
```