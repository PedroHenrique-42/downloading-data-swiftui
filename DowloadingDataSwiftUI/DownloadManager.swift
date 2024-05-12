//
//  DownloadManager.swift
//  DowloadingDataSwiftUI
//
//  Created by Pedro Henrique on 15/12/23.
//

import Foundation

final class DownloadManager: ObservableObject {
    @Published var isDownloading = false
    
    func downloadFile(url: String, _ closure: @escaping (_ data: Data?) -> Void ) {
        isDownloading = true
        
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let destinationUrl = docsUrl?.appendingPathComponent("myPdf.pdf") else { return }

        if FileManager().fileExists(atPath: destinationUrl.path()) && url.isEmpty {
            print("File already exists")
            isDownloading = false
            let data = FileManager().contents(atPath: destinationUrl.path())
            closure(data)
            return
        }
        
        guard let url = URL(
            string: url.isEmpty
            ? "https://www.learningcontainer.com/wp-content/uploads/2019/09/sample-pdf-file.pdf"
            : url
        ) else {
            print("Url não encontrada")
            return
        }
        let urlRequest = URLRequest(url: url)
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error {
                print("Request error: ", error)
                self.isDownloading = false
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                guard let data else {
                    self.isDownloading = false
                    return
                }
                DispatchQueue.main.async {
                    do {
                        try data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                        print("Arquivo baixado")
                        self.isDownloading = false
                        closure(data)
                    } catch let error {
                        print("Error decoding: ", error)
                        self.isDownloading = false
                    }
                }
            }
        }
        
        dataTask.resume()
    }
    
    func deleteFile() {
        self.isDownloading = true
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        let destinationUrl = docsUrl?.appendingPathComponent("myPdf.pdf")
        if let destinationUrl = destinationUrl {
            guard FileManager().fileExists(atPath: destinationUrl.path) else { return }
            do {
                try FileManager().removeItem(atPath: destinationUrl.path)
                self.isDownloading = false
                print("File deleted successfully")
            } catch let error {
                print("Error while deleting video file: ", error)
            }
        }
    }
}
