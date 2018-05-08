//
//  DataManager.swift
//  complete-view
//
//  Created by Sunshine on 2018/5/5.
//  Copyright © 2018年 Sunshine. All rights reserved.
//

import Foundation

public class DataManager {

    // Get document directory, get access to the direct and save information there
    static fileprivate func getDocumentDirectory () -> URL {

        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return url
        } else {
            fatalError("Unable to access document directory")
        }
    }

    // Save any kinds of codable objects
    static func save <T:Encodable> (object:T, with fileName: String) {
        let url = getDocumentDirectory().appendingPathComponent(fileName, isDirectory: false)
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            if FileManager.default.fileExists(atPath: url.path){
                try FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    // Load any kinds of codable objects
    static func load <T:Decodable> (filename:String, with type:T.Type) -> T {
        let url = getDocumentDirectory().appendingPathComponent(filename, isDirectory:false)
        if !FileManager.default.fileExists(atPath: url.path) {
            fatalError("file not found at path \(url.path)")
        }

        if let data = FileManager.default.contents(atPath: url.path) {
            do {
                let model = try JSONDecoder().decode(type, from: data)
                return model
            } catch {
                fatalError(error.localizedDescription)
            }
        } else {
            fatalError("data can't be accesed at path \(url.path)")
        }
    }

    // Load data from a file
    static func loadData (filename:String) -> Data? {
        let url = getDocumentDirectory().appendingPathComponent(filename, isDirectory:false)
        if !FileManager.default.fileExists(atPath: url.path) {
            fatalError("file not found at path \(url.path)")
        }

        if let data = FileManager.default.contents(atPath: url.path) {
            return data
        } else {
            fatalError("data can't be accesed at path \(url.path)")
        }
    }

    // Load all files from a directory
    static func loadAll <T:Decodable> (type:T.Type) -> [T] {
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: getDocumentDirectory().path)

            var modelObjects = [T]()

            for filename in files {
                modelObjects.append(load(filename: filename, with: type))
            }

            return modelObjects
        } catch {
            fatalError("could not load any files")
        }
    }

    // Delete a file from a directory
    static func delete (filename: String) {
        let url = getDocumentDirectory().appendingPathComponent(filename, isDirectory:false)
        if FileManager.default.fileExists(atPath: url.path){
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                fatalError(error.localizedDescription)
            }
        }

    }
}
