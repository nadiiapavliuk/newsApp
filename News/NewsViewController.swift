//
//  ViewController.swift
//  News
//
//  Created by Nadiia Pavliuk on 3/30/18.
//  Copyright © 2018 Nadiia Pavliuk. All rights reserved.
//

import UIKit
import SafariServices

class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,  UISearchResultsUpdating , UISearchBarDelegate, SFSafariViewControllerDelegate {
    
    final let url = URL(string: "https://newsapi.org/v2/top-headlines?country=us&sortBy=publishedAt&apiKey=cfcc751f9b724387868fc8f22d04d4fa")
    
    private var articles = [Article]()
    var filteredArticles = [Article]()
    var shouldShowSearchResults = false
    var searchController: UISearchController!
    var refresher: UIRefreshControl!
    
    @IBOutlet var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadJson()
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(NewsViewController.refr), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        configureSearchController()
        definesPresentationContext = true
    }
    
    
    @objc func refr() {
        refresher.endRefreshing()
        tableView.reloadData()
    }
    
    
    func downloadJson() {
        guard let downloadURL = url else { return }
        URLSession.shared.dataTask(with: downloadURL) { data, urlResponse, error in
            guard let data = data, error == nil, urlResponse != nil else {
                print("something is wrong")
                return
            }
            print("downloaded")
            do
            {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let news = try decoder.decode(News.self, from: data)
                dump(news)
                
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                encoder.dateEncodingStrategy = .iso8601
                let data = try encoder.encode(news)
                let json = String(data: data, encoding: .utf8)!
                print(json)
                
                self.articles = news.articles
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("something wrong after downloaded")
                print("\(error)")
            }
            }.resume()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults {
            return filteredArticles.count
        }
        else {
            return articles.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? NewsTableViewCell
            else { return UITableViewCell() }
        
        if shouldShowSearchResults {
            cell.autorLabel?.text = filteredArticles[indexPath.row].author
            cell.titleLabel.text =  filteredArticles[indexPath.row].title
            cell.descrTextView.text = filteredArticles[indexPath.row].description
            cell.publishedAtLabel.text = filteredArticles[indexPath.row].publishedAt
            let id = UUID()
            cell.id = id
            if let imageURL = URL(string: filteredArticles[indexPath.row].urlToImage) {
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: imageURL)
                    if let data = data {
                        let image = UIImage(data: data)
                        if id == cell.id {
                            DispatchQueue.main.async {
                                cell.urlToImageView.image = image
                                cell.setNeedsLayout()
                            }
                        }
                    }
                }
            }
        }
        else {
            cell.autorLabel?.text = articles[indexPath.row].author
            cell.titleLabel.text =  articles[indexPath.row].title
            cell.descrTextView.text = articles[indexPath.row].description
            cell.publishedAtLabel.text = articles[indexPath.row].publishedAt
            let id = UUID()
            cell.id = id
            if let imageURL = URL(string: articles[indexPath.row].urlToImage) {
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: imageURL)
                    if let data = data {
                        let image = UIImage(data: data)
                        if id == cell.id {
                            DispatchQueue.main.async {
                                cell.urlToImageView.image = image
                                cell.setNeedsLayout()
                            }
                        }
                    }
                }
            }
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if shouldShowSearchResults {
            if let openPage = URL(string: filteredArticles[indexPath.row].url) {
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = true
                let vc = SFSafariViewController(url: openPage, configuration: config)
                present(vc, animated: true)
            }
        }
        else {
            if let openPage = URL(string: articles[indexPath.row].url) {
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = true
                let vc = SFSafariViewController(url: openPage, configuration: config)
                present(vc, animated: true)
            }
        }
    }
    
    
    // MARK:  pagination
    private func tableView(_ tableView: UITableView, willDisplay cell: NewsTableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == articles.count - 1 {
            moreData()
        }
    }
    func moreData() {
        for _ in 0...10 {
            articles.append(articles.last!)
        }
        tableView.reloadData()
    }
    
    
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        
        self.tableView.tableHeaderView = searchController.searchBar
    }
    
    func filterSearchController(_ searchBar: UISearchBar) {
        let searchText = searchBar.text ?? ""
        filteredArticles = articles.filter { articles in
            let isMatchingSearchText = articles.title.lowercased().contains(searchText.lowercased()) || articles.description.lowercased().contains(searchText.lowercased()) || searchText.lowercased().count == 0
            return isMatchingSearchText
        }
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController){
        filterSearchController(searchController.searchBar)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        tableView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterSearchController(searchBar)
    }
    
}

