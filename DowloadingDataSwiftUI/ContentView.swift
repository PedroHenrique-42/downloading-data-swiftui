//
//  ContentView.swift
//  DowloadingDataSwiftUI
//
//  Created by Pedro Henrique on 15/12/23.
//

import SwiftUI
import PDFKit

struct ContentView: View {
    let downloadManager: DownloadManager = DownloadManager()
    @State var isDownloading = false
    @State var pdfData: Data?
    @State var textInput: String = ""
    
    var body: some View {
        VStack {
            if isDownloading {
                ProgressView()
            }
            
            if let pdfData {
                PDFKitView(data: pdfData)
            }
            
            TextField("Insira a url do pdf", text: $textInput)
                .multilineTextAlignment(.center)
                .frame(width: 300, alignment: .center)
                .padding(.bottom, 20)
                .onTapGesture {
                    self.textInput = ""
                }
            
            Button {
                self.isDownloading = true
                downloadManager.downloadFile(url: textInput) { data in
                    self.isDownloading = false
                    self.pdfData = data
                }
            } label: {
                Text("Baixar PDF")
            }.padding(.bottom, 20)
            
            Button {
                downloadManager.deleteFile()
                self.pdfData = nil
            } label: {
                Text("Deletar PDF")
            }
        }
        .padding()
        .onAppear {
            isDownloading = downloadManager.isDownloading
            downloadManager.downloadFile(url: "") { data in
                pdfData = data
            }
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    var data: Data
    
    func makeUIView(context: UIViewRepresentableContext<PDFKitView>) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: self.data)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: UIViewRepresentableContext<PDFKitView>) {
    }
}
