//
//  Alamofire.swift
//
//  Copyright (c) 2014-2016 Alamofire Software Foundation (http://alamofire.org/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

// MARK: - URLStringConvertible

/**
    Types adopting the `URLStringConvertible` protocol can be used to construct URL strings, which are then used to 
    construct URL requests.
 
    创建 URLStringConvertible 转换协议，并扩展至 String, NSURL, NSURLComponents 和 NSURLRequest, 已便于后面构造 URL 请求字符串。
*/
public protocol URLStringConvertible {
    /**
        A URL that conforms to RFC 2396.

        Methods accepting a `URLStringConvertible` type parameter parse it according to RFCs 1738 and 1808.

        See https://tools.ietf.org/html/rfc2396
        See https://tools.ietf.org/html/rfc1738
        See https://tools.ietf.org/html/rfc1808
    */
    var URLString: String { get }
}

extension String: URLStringConvertible {
    public var URLString: String {
        return self
    }
}

extension NSURL: URLStringConvertible {
    public var URLString: String {
        return absoluteString
    }
}

extension NSURLComponents: URLStringConvertible {
    public var URLString: String {
        return URL!.URLString
    }
}

extension NSURLRequest: URLStringConvertible {
    public var URLString: String {
        return URL!.URLString
    }
}

// MARK: - URLRequestConvertible

/**
    Types adopting the `URLRequestConvertible` protocol can be used to construct URL requests.
 
    构造 URLRequestConvertible 协议，以便于后面构造 URL 请求。（转换成 NSMutableURLRequest）
*/
public protocol URLRequestConvertible {
    /// The URL request.
    var URLRequest: NSMutableURLRequest { get }
}

/**
    NSURLRequest 扩展 URLRequestConvertible, 将 NSURLRequest 转换成 NSURLMutableRequest。
 */
extension NSURLRequest: URLRequestConvertible {
    public var URLRequest: NSMutableURLRequest {
        return self.mutableCopy() as! NSMutableURLRequest
    }
}

// MARK: - Convenience
/**
    构造 URLRequest， 将 URLStringConvertible 转换为对应的 NSURLMutableRequest。
 */
func URLRequest(
    method: Method,
    _ URLString: URLStringConvertible,
    headers: [String: String]? = nil)
    -> NSMutableURLRequest
{
    let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: URLString.URLString)!)
    mutableURLRequest.HTTPMethod = method.rawValue

    if let headers = headers {
        for (headerField, headerValue) in headers {
            mutableURLRequest.setValue(headerValue, forHTTPHeaderField: headerField)
        }
    }

    return mutableURLRequest
}

// MARK: - Request Methods | request 方法根据 URLStringConvertible 或 URLRequestConvertible 发起请求。

/**
    Creates a request using the shared manager instance for the specified method, URL string, parameters, and
    parameter encoding.
    
    使用全局 Manage， 根据 URLStringConvertible 和参数、编码、请求头等发起请求。

    - parameter method:     The HTTP method.
    - parameter URLString:  The URL string.
    - parameter parameters: The parameters. `nil` by default.
    - parameter encoding:   The parameter encoding. `.URL` by default.
    - parameter headers:    The HTTP headers. `nil` by default.

    - returns: The created request.
*/
public func request(
    method: Method,
    _ URLString: URLStringConvertible,
    parameters: [String: AnyObject]? = nil,
    encoding: ParameterEncoding = .URL,
    headers: [String: String]? = nil)
    -> Request
{
    return Manager.sharedInstance.request(
        method,
        URLString,
        parameters: parameters,
        encoding: encoding,
        headers: headers
    )
}

/**
    Creates a request using the shared manager instance for the specified URL request.

    If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
 
    使用全局 Manage， 根据 URLRequestConvertible 发起请求。

    - parameter URLRequest: The URL request

    - returns: The created request.
*/
public func request(URLRequest: URLRequestConvertible) -> Request {
    return Manager.sharedInstance.request(URLRequest.URLRequest)
}

// MARK: - Upload Methods | upload 方法根据 URLStringConvertible, URLRequestConvertible, NSURL, NSData, NSInputStream, MultipartFormData 的不同，发起不同形式的上传请求。

// MARK: File

/**
    Creates an upload request using the shared manager instance for the specified method, URL string, and file.
 
    根据 URLStringConvertible 和请求头、文件 URL 发起上传请求。

    - parameter method:    The HTTP method.
    - parameter URLString: The URL string.
    - parameter headers:   The HTTP headers. `nil` by default.
    - parameter file:      The file to upload.

    - returns: The created upload request.
*/
public func upload(
    method: Method,
    _ URLString: URLStringConvertible,
    headers: [String: String]? = nil,
    file: NSURL)
    -> Request
{
    return Manager.sharedInstance.upload(method, URLString, headers: headers, file: file)
}

/**
    Creates an upload request using the shared manager instance for the specified URL request and file.
 
    根据 URLRequestConvertible 和文件 URL 发起请求。

    - parameter URLRequest: The URL request.
    - parameter file:       The file to upload.

    - returns: The created upload request.
*/
public func upload(URLRequest: URLRequestConvertible, file: NSURL) -> Request {
    return Manager.sharedInstance.upload(URLRequest, file: file)
}

// MARK: Data

/**
    Creates an upload request using the shared manager instance for the specified method, URL string, and data.
 
    根据 URLStringConvertible 和 NSData 发起请求。

    - parameter method:    The HTTP method.
    - parameter URLString: The URL string.
    - parameter headers:   The HTTP headers. `nil` by default.
    - parameter data:      The data to upload.

    - returns: The created upload request.
*/
public func upload(
    method: Method,
    _ URLString: URLStringConvertible,
    headers: [String: String]? = nil,
    data: NSData)
    -> Request
{
    return Manager.sharedInstance.upload(method, URLString, headers: headers, data: data)
}

/**
    Creates an upload request using the shared manager instance for the specified URL request and data.
 
    根据 URLRequestConvertible 和 NSData 发起请求。

    - parameter URLRequest: The URL request.
    - parameter data:       The data to upload.

    - returns: The created upload request.
*/
public func upload(URLRequest: URLRequestConvertible, data: NSData) -> Request {
    return Manager.sharedInstance.upload(URLRequest, data: data)
}

// MARK: Stream

/**
    Creates an upload request using the shared manager instance for the specified method, URL string, and stream.

    - parameter method:    The HTTP method.
    - parameter URLString: The URL string.
    - parameter headers:   The HTTP headers. `nil` by default.
    - parameter stream:    The stream to upload.

    - returns: The created upload request.
*/
public func upload(
    method: Method,
    _ URLString: URLStringConvertible,
    headers: [String: String]? = nil,
    stream: NSInputStream)
    -> Request
{
    return Manager.sharedInstance.upload(method, URLString, headers: headers, stream: stream)
}

/**
    Creates an upload request using the shared manager instance for the specified URL request and stream.

    - parameter URLRequest: The URL request.
    - parameter stream:     The stream to upload.

    - returns: The created upload request.
*/
public func upload(URLRequest: URLRequestConvertible, stream: NSInputStream) -> Request {
    return Manager.sharedInstance.upload(URLRequest, stream: stream)
}

// MARK: MultipartFormData

/**
    Creates an upload request using the shared manager instance for the specified method and URL string.

    - parameter method:                  The HTTP method.
    - parameter URLString:               The URL string.
    - parameter headers:                 The HTTP headers. `nil` by default.
    - parameter multipartFormData:       The closure used to append body parts to the `MultipartFormData`.
    - parameter encodingMemoryThreshold: The encoding memory threshold in bytes.
                                         `MultipartFormDataEncodingMemoryThreshold` by default.
    - parameter encodingCompletion:      The closure called when the `MultipartFormData` encoding is complete.
*/
public func upload(
    method: Method,
    _ URLString: URLStringConvertible,
    headers: [String: String]? = nil,
    multipartFormData: MultipartFormData -> Void,
    encodingMemoryThreshold: UInt64 = Manager.MultipartFormDataEncodingMemoryThreshold,
    encodingCompletion: (Manager.MultipartFormDataEncodingResult -> Void)?)
{
    return Manager.sharedInstance.upload(
        method,
        URLString,
        headers: headers,
        multipartFormData: multipartFormData,
        encodingMemoryThreshold: encodingMemoryThreshold,
        encodingCompletion: encodingCompletion
    )
}

/**
    Creates an upload request using the shared manager instance for the specified method and URL string.

    - parameter URLRequest:              The URL request.
    - parameter multipartFormData:       The closure used to append body parts to the `MultipartFormData`.
    - parameter encodingMemoryThreshold: The encoding memory threshold in bytes.
                                         `MultipartFormDataEncodingMemoryThreshold` by default.
    - parameter encodingCompletion:      The closure called when the `MultipartFormData` encoding is complete.
*/
public func upload(
    URLRequest: URLRequestConvertible,
    multipartFormData: MultipartFormData -> Void,
    encodingMemoryThreshold: UInt64 = Manager.MultipartFormDataEncodingMemoryThreshold,
    encodingCompletion: (Manager.MultipartFormDataEncodingResult -> Void)?)
{
    return Manager.sharedInstance.upload(
        URLRequest,
        multipartFormData: multipartFormData,
        encodingMemoryThreshold: encodingMemoryThreshold,
        encodingCompletion: encodingCompletion
    )
}

// MARK: - Download Methods | 根据 URLStringConvertible, URLRequestConvertible, Request.DownloadFileDestination 的不同进行下载请求。

// MARK: URL Request

/**
    Creates a download request using the shared manager instance for the specified method and URL string.

    - parameter method:      The HTTP method.
    - parameter URLString:   The URL string.
    - parameter parameters:  The parameters. `nil` by default.
    - parameter encoding:    The parameter encoding. `.URL` by default.
    - parameter headers:     The HTTP headers. `nil` by default.
    - parameter destination: The closure used to determine the destination of the downloaded file.

    - returns: The created download request.
*/
public func download(
    method: Method,
    _ URLString: URLStringConvertible,
    parameters: [String: AnyObject]? = nil,
    encoding: ParameterEncoding = .URL,
    headers: [String: String]? = nil,
    destination: Request.DownloadFileDestination)
    -> Request
{
    return Manager.sharedInstance.download(
        method,
        URLString,
        parameters: parameters,
        encoding: encoding,
        headers: headers,
        destination: destination
    )
}

/**
    Creates a download request using the shared manager instance for the specified URL request.

    - parameter URLRequest:  The URL request.
    - parameter destination: The closure used to determine the destination of the downloaded file.

    - returns: The created download request.
*/
public func download(URLRequest: URLRequestConvertible, destination: Request.DownloadFileDestination) -> Request {
    return Manager.sharedInstance.download(URLRequest, destination: destination)
}

// MARK: Resume Data | 断点续传

/**
    Creates a request using the shared manager instance for downloading from the resume data produced from a 
    previous request cancellation.

    - parameter resumeData:  The resume data. This is an opaque data blob produced by `NSURLSessionDownloadTask`
                             when a task is cancelled. See `NSURLSession -downloadTaskWithResumeData:` for additional 
                             information.
    - parameter destination: The closure used to determine the destination of the downloaded file.

    - returns: The created download request.
*/
public func download(resumeData data: NSData, destination: Request.DownloadFileDestination) -> Request {
    return Manager.sharedInstance.download(data, destination: destination)
}
