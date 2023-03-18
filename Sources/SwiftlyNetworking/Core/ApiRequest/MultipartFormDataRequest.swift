//
//  MultipartRequest.swift
//
//
//  Created by Onur Var on 3.02.2023.
//

import Foundation

open class MultipartFormDataRequest {
    // MARK: Variables

    private let path: String
    private let httpMethod: HttpMethodType
    private let queryParameter: Encodable?
    private let refreshTokenOnFailEnabled: Bool
    private let boundary: String
    private var body: NSMutableData

    // MARK: Life Cycle

    public init(
        path: String,
        httpMethod: HttpMethodType,
        queryParameter: Encodable? = nil,
        refreshTokenOnFailEnabled: Bool = true
    ) {
        self.path = path
        self.httpMethod = httpMethod
        self.queryParameter = queryParameter
        self.refreshTokenOnFailEnabled = refreshTokenOnFailEnabled
        self.boundary = UUID().uuidString
        self.body = NSMutableData()
    }
}

extension MultipartFormDataRequest: RequestProtocol {
    public var rPath: String {
        return path
    }
    
    public var rHttpMethod: HttpMethodType {
        return httpMethod
    }
    
    public var rQueryParameter: Encodable? {
        return queryParameter
    }
    
    public var rBody: Data? {
        body.appendString("--\(boundary)--")
        return body as Data
    }
    
    public var rHeaders: [String: String]? {
        return ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
    }
    
    public var rRefreshTokenOnFailEnabled: Bool {
        return refreshTokenOnFailEnabled
    }
}

public extension MultipartFormDataRequest {
    // MARK: Text Methods
    
    func addTextField(named name: String, value: String) {
        body.appendString(textFormField(named: name, value: value))
    }
    
    func addTextField(named name: String, value: Int) {
        body.appendString(textFormField(named: name, value: "\(value)"))
    }
    
    private func textFormField(named name: String, value: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "Content-Type: text/plain; charset=ISO-8859-1\r\n"
        fieldString += "Content-Transfer-Encoding: 8bit\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"
        
        return fieldString
    }
    
    // MARK: Data Methods

    func addDataField(fieldName: String, fileName: String, data: Data, mimeType: String) {
        body.append(dataFormField(fieldName: fieldName, fileName: fileName, data: data, mimeType: mimeType))
    }
    
    private func dataFormField(fieldName: String, fileName: String, data: Data, mimeType: String) -> Data
    
    {
        let fieldData = NSMutableData()
        
        fieldData.appendString("--\(boundary)\r\n")
        fieldData.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        fieldData.appendString("Content-Type: \(mimeType)\r\n")
        fieldData.appendString("\r\n")
        fieldData.append(data)
        fieldData.appendString("\r\n")
        return fieldData as Data
    }
}
