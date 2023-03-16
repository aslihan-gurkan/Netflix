//
//  CollectionViewTableViewCell.swift
//  Netflix
//
//  Created by Aslıhan Gürkan on 15.02.2023.
//

import UIKit

protocol CollectionViewTableViewCellDelegate : AnyObject {
    func collectionViewTableViewCellDidTapCell(_ cell : CollectionViewTableViewCell, viewModel : PreviewViewModel)
}

class CollectionViewTableViewCell: UITableViewCell {

    //each viewcell has own identifier
    static let identifier = "CollectionViewTableViewCell"
    weak var delegate : CollectionViewTableViewCellDelegate?
    
    private var titles : [Title] = [Title]()
    
    //Horizontal cells in vertical table cell
    private let collectionView : UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 140, height: 200)
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TitleCollectionViewCell.self, forCellWithReuseIdentifier: TitleCollectionViewCell.identifier)
        return collectionView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemPink
        contentView.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    // NS -> NeXTSTEP is a discontinued object-oriented, multitasking operating system based on the Mach kernel and the UNIX-derived BSD.
    // NSCoder -> An abstract class that serves as the basis for objects that enable archiving and distribution of other objects.
    // https://developer.apple.com/documentation/foundation/nscoder
    required init?(coder: NSCoder) {
        fatalError()
    }

    // layoutSubviews() -> to perform more precise layout of their subviews.
    // use this method only if the autoresizing & constraint-based behaviors of the subviews do not offer behavior you want.
    // https://developer.apple.com/documentation/uikit/uiview/1622482-layoutsubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.bounds
    }
    
    public func configure(with titles: [Title]) {
        self.titles = titles
        
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()            
        }
    }
    
    private func downloadMovieAt(indexPath: IndexPath) {
        //check it's true -> print("Downloading \(titles[indexPath.row].original_title)")
        
        DataPersistenceManager.shared.downloadMovieWith(model: titles[indexPath.row]) { result in
            switch result {
            case .success():
                NotificationCenter.default.post(name: NSNotification.Name("downloaded"), object: nil)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension CollectionViewTableViewCell : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionViewCell.identifier, for: indexPath) as? TitleCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        guard let model = titles[indexPath.row].poster_path else {
            return UICollectionViewCell()
        }
        cell.configure(with: model)
        return cell
        
    }
    
//  didSelectItemAt -> A function where we specify what a selected cell will do.
//  Whenever tap on any cell(item:movie)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let title = titles[indexPath.row]
        guard let titleName = title.original_title ?? title.original_name else { return }
        //TODO: [weak self] -> expl.
        APICaller.shared.getMovie(with: titleName + "trailer") { [weak self] result in
            switch result {
            case .success(let videoItem):
                
                guard let titleOverview = title.overview else { return }
                
                let viewModel = PreviewViewModel(title: titleName, youtubeView: videoItem, overview: titleOverview)
                self?.delegate?.collectionViewTableViewCellDidTapCell(self!, viewModel: viewModel)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
    // long tap on the cell
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(
        identifier: nil,
        previewProvider: nil) { [weak self] _ in
            let downloadAction = UIAction(title: "Download", state: .off) { _ in
                self?.downloadMovieAt(indexPath: indexPath)
            }
            return UIMenu(options: .displayInline, children: [downloadAction])
        }
        return config
    }
}
