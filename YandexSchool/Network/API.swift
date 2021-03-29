//
//  API.swift
//  YandexSchool
//
//  Created by Kseniya Lukoshkina on 22.03.2021.
//

import UIKit
import Alamofire

enum NetworkError: Error {
	case parseError
	case apiError
}

class API {
	let headers: HTTPHeaders = HTTPHeaders([HTTPHeader(name: "x-rapidapi-key", value: "afc4ebcfcemsha34c67ea4991f81p1ce626jsnfd9af1de4751"),
											HTTPHeader(name: "x-rapidapi-host", value: "apidojo-yahoo-finance-v1.p.rapidapi.com")])
	let queue = DispatchQueue(label: "favAdv", qos: .background, attributes: .concurrent)
	let serialQueue = DispatchQueue(label: "serial.summary", qos: .background)

	func getTrands(_ completion: @escaping (Result<[Stock], NetworkError>) -> Void) {
		AF.request(URL(string: "https://apidojo-yahoo-finance-v1.p.rapidapi.com/market/get-trending-tickers?region=US")!,
				   method: .get, headers: self.headers).validate().responseJSON(queue: queue) { response in
					switch response.result {
					case .success(let data):
//						print(data)
						var trands = [Stock]()
						guard let data = data as? [String: Any],
							  let finance = data["finance"] as? [String: Any],
							  let results = finance["result"] as? [Any],
							  let result = results[0] as? [String: Any],
							  let quotes = result["quotes"] as? [Any] else { DispatchQueue.main.async { completion(.failure(.parseError)) }; return }
						for anyQuote in quotes {
							guard let quote = anyQuote as? [String: Any],
								  var symbol = quote["symbol"] as? String,
								  let currentPrice = quote["regularMarketPrice"] as? Double,
								  let changeValue = quote["regularMarketChange"] as? Double,
								  let changePercent = quote["regularMarketChangePercent"] as? Double,
								  let name = quote["shortName"] as? String else { print("errr"); continue }
							// handle bags in api
							if let i = symbol.firstIndex(of: "^") {
								symbol.remove(at: i)
							}
							symbol = symbol.components(separatedBy: "-")[0]
							symbol = symbol.components(separatedBy: "=")[0]
							symbol = symbol.components(separatedBy: ".")[0]
							trands.append(Stock(ticker: symbol, name: name,
												currentPrice: currentPrice, changeValue: changeValue,
												changePercent: changePercent))
							
						}
						DispatchQueue.main.async { completion(.success(trands)) }
					case .failure:
						DispatchQueue.main.async { completion(.failure(.apiError)) }
					}
		}
		
	}
	
	func getSummary(with ticker: String, _ completion: @escaping (Result<Stock, NetworkError>) -> Void) {
//		return
		guard let url = URL(string: "https://apidojo-yahoo-finance-v1.p.rapidapi.com/stock/v2/get-profile?symbol=\(ticker)")
			else { DispatchQueue.main.async { completion(.failure(.parseError)) }; return }
			AF.request(url, method: .get, headers: headers).validate().responseJSON(queue: queue) { response in
					switch response.result {
					case .success(let data):
						guard let data = data as? [String: Any],
							  let ticker = data["symbol"] as? String,
							  let prices = data["price"] as? [String: Any],
//							  let symbol = prices["currencySymbol"] as? String,
//							  let ticker = prices["fromCurrency"] as? String,
							  let currentPriceArr = prices["regularMarketPrice"] as? [String: Any],
							  let currentPrice = currentPriceArr["raw"] as? Double,
							  let changeValueArr = prices["regularMarketChange"] as? [String: Any],
							  let changeValue = changeValueArr["raw"] as? Double,
							  let changePercentArr = prices["regularMarketChangePercent"] as? [String: Any],
							  let changePercent = changePercentArr["raw"] as? Double,
							  let name = prices["shortName"] as? String,
							  // url for loading logo
							  let company = data["assetProfile"] as? [String: Any] else { DispatchQueue.main.async { completion(.failure(.parseError)) }; return }
						
						var website: URL?
						if let websiteStr = company["website"] as? String,
							  let websiteUrl = URL(string: websiteStr),
							  let domain = websiteUrl.host,
							  let commonUrl = URL(string: "https://logo.clearbit.com/" + domain) {
							website = commonUrl
						}
						let stock = Stock(ticker: ticker, name: name, currentPrice: currentPrice,
									  changeValue: changeValue, changePercent: changePercent, website: website)
						DispatchQueue.main.async { completion(.success(stock)) }
					case .failure:
						print("get summary api error")
						DispatchQueue.main.async { completion(.failure(.apiError)) }
					}
		}
		
	}
	
	func autoComplete(with text: String, _ completion: @escaping (Result<[Stock], NetworkError>) -> Void) {
		guard let url = URL(string: "https://apidojo-yahoo-finance-v1.p.rapidapi.com/auto-complete?q=\(text)&region=US")
			else { DispatchQueue.main.async { completion(.failure(.parseError)) }; return }
		AF.request(url, method: .get, headers: self.headers).validate().responseJSON(queue: queue) { response in
					switch response.result {
					case .success(let data):
//						print(data)
						var trands = [Stock]()
						guard let data = data as? [String: Any],
							  let quotes = data["quotes"] as? [Any] else { DispatchQueue.main.async { completion(.failure(.parseError)) }; return }
						for anyQuote in quotes {
							guard let quote = anyQuote as? [String: Any],
								  var symbol = quote["symbol"] as? String,
								  let name = quote["shortname"] as? String,
								  let isExist = quote["isYahooFinance"] as? Bool, isExist else { print("errr"); continue }
							// handle bags in api
							if let i = symbol.firstIndex(of: "^") {
								symbol.remove(at: i)
							}
							symbol = symbol.components(separatedBy: "-")[0]
							symbol = symbol.components(separatedBy: "=")[0]
							symbol = symbol.components(separatedBy: ".")[0]
							trands.append(Stock(ticker: symbol, name: name))
						}
						DispatchQueue.main.async { completion(.success(trands)) }
					case .failure:
						DispatchQueue.main.async { completion(.failure(.apiError)) }
					}
		}
		
	}
	
	/*	финансовые апи возвращают некрасивые картинки в плохом качестве, поэтому получаю website
		из саммари и по нему через logo.clearbit.com получаю лого компании	*/
	func getWebsite(with ticker: String, _ completion: @escaping (Result<URL, NetworkError>) -> Void) {
		guard let url = URL(string: "https://apidojo-yahoo-finance-v1.p.rapidapi.com/stock/v2/get-profile?symbol=\(ticker)")
			else { DispatchQueue.main.async { completion(.failure(.parseError)) }; return }
			AF.request(url, method: .get, headers: headers).validate().responseJSON(queue: queue) { response in
					switch response.result {
					case .success(let data):
						guard let data = data as? [String: Any],
							  let company = data["assetProfile"] as? [String: Any],
							  let websiteStr = company["website"] as? String,
							  let websiteUrl = URL(string: websiteStr),
							  let domain = websiteUrl.host,
							  let website = URL(string: "https://logo.clearbit.com/" + domain) else { DispatchQueue.main.async { completion(.failure(.parseError)) }; return }
						DispatchQueue.main.async { completion(.success(website)) }
					case .failure:
						print("get website api error")
						DispatchQueue.main.async { completion(.failure(.apiError)) }
					}
		}
		
	}
}
