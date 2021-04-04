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
	static var shared = API()
	
	private init() {}
	
	let headers: HTTPHeaders = HTTPHeaders([HTTPHeader(name: "x-rapidapi-key", value: "afc4ebcfcemsha34c67ea4991f81p1ce626jsnfd9af1de4751"),
											HTTPHeader(name: "x-rapidapi-host", value: "apidojo-yahoo-finance-v1.p.rapidapi.com")])
	let queue = DispatchQueue(label: "favAdv", qos: .background, attributes: .concurrent)
	let serialQueue = DispatchQueue(label: "serial.summary", qos: .background)

	func getTrands(_ completion: @escaping (Result<[Stock], NetworkError>) -> Void) {
		AF.request(URL(string: "https://apidojo-yahoo-finance-v1.p.rapidapi.com/market/get-trending-tickers?region=US")!,
				   method: .get, headers: self.headers).validate().responseJSON(queue: queue) { response in
					switch response.result {
					case .success(let data):
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
								  let name = quote["shortName"] as? String else { continue }
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
	
	// MARK: - Info
	func getStockInfo(with ticker: String, _ completion: @escaping (Result<Stock, NetworkError>) -> Void) {
		guard let url = URL(string: "https://apidojo-yahoo-finance-v1.p.rapidapi.com/stock/v2/get-profile?symbol=\(ticker)&region=US")
			else { DispatchQueue.main.async { completion(.failure(.parseError)) }; return }
			AF.request(url, method: .get, headers: headers).validate().responseJSON(queue: queue) { response in
					switch response.result {
					case .success(let data):
						guard let data = data as? [String: Any],
							  let ticker = data["symbol"] as? String,
							  let prices = data["price"] as? [String: Any],
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
						DispatchQueue.main.async { completion(.failure(.apiError)) }
					}
		}
		
	}
	
	// MARK: - Search
	func autoComplete(with text: String, _ completion: @escaping (Result<[Stock], NetworkError>) -> Void) {
		guard let url = URL(string: "https://apidojo-yahoo-finance-v1.p.rapidapi.com/auto-complete?q=\(text)&region=US")
			else { DispatchQueue.main.async { completion(.failure(.parseError)) }; return }
		AF.request(url, method: .get, headers: self.headers).validate().responseJSON(queue: queue) { response in
					switch response.result {
					case .success(let data):
						var trands = [Stock]()
						guard let data = data as? [String: Any],
							  let quotes = data["quotes"] as? [Any] else { DispatchQueue.main.async { completion(.failure(.parseError)) }; return }
						for anyQuote in quotes {
							guard let quote = anyQuote as? [String: Any],
								  var symbol = quote["symbol"] as? String,
								  let name = quote["shortname"] as? String,
								  let exchange = quote["exchange"] as? String?,
								  let isExist = quote["isYahooFinance"] as? Bool, isExist else { continue }
							// handle bags in api
							if let i = symbol.firstIndex(of: "^") {
								symbol.remove(at: i)
							}
							symbol = symbol.components(separatedBy: "-")[0]
							symbol = symbol.components(separatedBy: "=")[0]
							symbol = symbol.components(separatedBy: ".")[0]
							trands.append(Stock(ticker: symbol, name: name, exchange: exchange))
						}
						DispatchQueue.main.async { completion(.success(trands)) }
					case .failure:
						DispatchQueue.main.async { completion(.failure(.apiError)) }
					}
		}
		
	}
	
	// MARK: - Logo
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
						DispatchQueue.main.async { completion(.failure(.apiError)) }
					}
		}
		
	}
	
	// MARK: - Chart
	func getChart(with ticker: String, and range: StockChartRangeState, _ completion: @escaping (Result<([Int?], [Double?]), NetworkError>) -> Void) {
		guard let url = URL(string: "https://apidojo-yahoo-finance-v1.p.rapidapi.com/stock/v2/get-chart?interval=\(range.apiIntervalStr)&symbol=\(ticker)&range=\(range.apiRangeStr)")
			else { DispatchQueue.main.async { completion(.failure(.parseError)) }; return }
			AF.request(url, method: .get, headers: headers).validate().responseJSON(queue: queue) { response in
					switch response.result {
					case .success(let data):
						
						guard let data = data as? [String: Any],
							  let chart = data["chart"] as? [String: Any],
							  let results = chart["result"] as? [Any],
							  let result = results[0] as? [String: Any],
							  let timestamp = result["timestamp"] as? [Int?], // <-
							  let indicators = result["indicators"] as? [String: Any],
							  
							  let quotes = indicators["quote"] as? [Any],
							  let quote = quotes[0] as? [String: Any],
							  let prices = quote["open"] as? [Double?] else { DispatchQueue.main.async { completion(.failure(.parseError)) }; return }
						DispatchQueue.main.async { completion(.success((timestamp, prices))) }
					case .failure:
						DispatchQueue.main.async { completion(.failure(.apiError)) }
					}
		}
		
	}
	
	// MARK: - Summary
	func getSummary(with ticker: String, _ completion: @escaping (Result<StockSummary, NetworkError>) -> Void) {
		guard let url = URL(string: "https://apidojo-yahoo-finance-v1.p.rapidapi.com/stock/v2/get-summary?symbol=\(ticker)&region=US")
			else { DispatchQueue.main.async { completion(.failure(.parseError)) }; return }
			AF.request(url, method: .get, headers: headers).validate().responseJSON(queue: queue) { response in
					switch response.result {
					case .success(let data):
						guard let data = data as? [String: Any],
							  let summary = data["summaryDetail"] as? [String: Any] else { DispatchQueue.main.async { completion(.failure(.parseError)) }; return }
						var stockSummary = StockSummary()
						if let previousCloses = summary["previousClose"] as? [String: Any], let previousClose = previousCloses["fmt"] as? String {
							stockSummary.previousClose = previousClose
						}
						if let opens = summary["open"] as? [String: Any], let open = opens["fmt"] as? String {
							stockSummary.open = open
						}
						if let bids = summary["bid"] as? [String: Any], let bid = bids["fmt"] as? String {
							stockSummary.bid = bid
						}
						if let bidSizes = summary["bidSize"] as? [String: Any], let bidSize = bidSizes["fmt"] as? String {
							stockSummary.bidSize = bidSize
						}
						if let asks = summary["ask"] as? [String: Any], let ask = asks["fmt"] as? String {
							stockSummary.ask = ask
						}
						if let askSizes = summary["askSize"] as? [String: Any], let askSize = askSizes["fmt"] as? String {
							stockSummary.askSize = askSize
						}
						if let dayLows = summary["dayLow"] as? [String: Any], let dayLow = dayLows["fmt"] as? String {
							stockSummary.dayLow = dayLow
						}
						if let fiftyTwoWeekLows = summary["fiftyTwoWeekLow"] as? [String: Any], let fiftyTwoWeekLow = fiftyTwoWeekLows["fmt"] as? String {
							stockSummary.fiftyTwoWeekLow = fiftyTwoWeekLow
						}
						if let fiftyTwoWeekHighs = summary["fiftyTwoWeekLow"] as? [String: Any], let fiftyTwoWeekHigh = fiftyTwoWeekHighs["fmt"] as? String {
							stockSummary.fiftyTwoWeekHigh = fiftyTwoWeekHigh
						}
						if let volumes = summary["volume"] as? [String: Any], let volume = volumes["fmt"] as? String {
							stockSummary.volume = volume
						}
						if let averageVolumes = summary["averageVolume"] as? [String: Any], let averageVolume = averageVolumes["fmt"] as? String {
							stockSummary.averageVolume = averageVolume
						}
						if let marketCaps = summary["marketCap"] as? [String: Any], let marketCap = marketCaps["fmt"] as? String {
							stockSummary.marketCap = marketCap
						}
						if let betas = summary["beta"] as? [String: Any], let beta = betas["fmt"] as? String {
							stockSummary.beta = beta
						}
						if let dividendRates = summary["dividendRate"] as? [String: Any], let dividendRate = dividendRates["fmt"] as? String {
							stockSummary.dividendRate = dividendRate
						}
						DispatchQueue.main.async { completion(.success(stockSummary)) }
					case .failure:
						DispatchQueue.main.async { completion(.failure(.apiError)) }
					}
		}
		
	}
	
	// MARK: - News
	func getNews(with ticker: String, _ completion: @escaping (Result<[News], NetworkError>) -> Void) {
		guard let url = URL(string: "https://apidojo-yahoo-finance-v1.p.rapidapi.com/stock/get-news?category=\(ticker)&region=US")
			else { DispatchQueue.main.async { completion(.failure(.parseError)) }; return }
			AF.request(url, method: .get, headers: headers).validate().responseJSON(queue: queue) { response in
					switch response.result {
					case .success(let data):
						guard let data = data as? [String: Any],
							  let items = data["items"] as? [String: Any],
							  let results = items["result"] as? [Any] else { DispatchQueue.main.async { completion(.failure(.parseError)) }; return }
						var newsArr = [News]()
						for result in results {
							guard let resultDic = result as? [String: Any],
								  let title = resultDic["title"] as? String else { continue }
							var news = News(title: title)
							news.link = resultDic["link"] as? String
							news.summary = resultDic["summary"] as? String
							news.date = resultDic["published_at"] as? Int
							
							if let mainImage = resultDic["main_image"] as? [String: Any],
							   let originalUrl = mainImage["original_url"] as? String {
								news.photoUrl = originalUrl
							}
							newsArr.append(news)
						}
						
						DispatchQueue.main.async { completion(.success(newsArr)) }
					case .failure:
						DispatchQueue.main.async { completion(.failure(.apiError)) }
					}
		}
		
	}
	
}
