//
//  FileDataManager.swift
//  YandexSchool
//
//  Created by Kseniya Lukoshkina on 27.03.2021.
//

import Foundation

enum FileError: Error {
	case loadDataError
	case parseError
}

class FileDataManager {
	
	private let loadQueue: DispatchQueue
	private let saveQueue: DispatchQueue
	
	init() {
		loadQueue = DispatchQueue(label: "loadFavorites.serial", qos: .userInitiated)
		saveQueue = DispatchQueue(label: "saveFavorites.serial", qos: .background)
	}
	
	func loadFavoriteData(completion: @escaping (Result<[String], FileError>) -> Void) {
		loadQueue.async {
			if let data = try? JSONSerialization.loadJSON(withFilename: "favorites") {
				if let data = data as? [String] {
					completion(.success(data))
				} else {
					completion(.failure(.loadDataError))
				}
			} else {
				completion(.failure(.loadDataError))
			}
		}
	}

	func saveFavoriteData(favorites: [String], completion: @escaping (Result<Void, FileError>) -> Void) {
		saveQueue.async {
			if let success = try? JSONSerialization.save(jsonObject: favorites, toFilename: "favorites") {
				if success {
					completion(.success(()))
				} else {
					completion(.failure(.loadDataError))
				}
			} else {
				completion(.failure(.loadDataError))
			}
		}
	}

}


extension JSONSerialization {
	
	static func loadJSON(withFilename filename: String) throws -> Any? {
		let fm = FileManager.default
		let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
		if let url = urls.first {
			var fileURL = url.appendingPathComponent(filename)
			fileURL = fileURL.appendingPathExtension("json")
			let data = try Data(contentsOf: fileURL)
			let jsonObject = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers, .mutableLeaves])
			return jsonObject
		}
		return nil
	}
	
	static func save(jsonObject: Any, toFilename filename: String) throws -> Bool{
		let fm = FileManager.default
		let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
		if let url = urls.first {
			var fileURL = url.appendingPathComponent(filename)
			fileURL = fileURL.appendingPathExtension("json")
			let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
			try data.write(to: fileURL, options: [.atomicWrite])
			return true
		}
		
		return false
	}
}
