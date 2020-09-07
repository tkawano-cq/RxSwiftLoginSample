//
//  ViewController.swift
//  RxTest
//
//  Created by TOUYA KAWANO on 2020/09/07.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    private var viewModel = LoginViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewToViewModel()
        bindViewModelToView()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.subviews.forEach { $0.endEditing(true) }
    }
    
    @IBAction func didLoginButtonTapped(_ sender: UIButton) {
        viewModel.login(email: mailAddressTextField.text!, password: passwordTextField.text!)
    }
    
    func bindViewToViewModel() {
        Observable
            .combineLatest(
                mailAddressTextField.rx.text.map({ $0!.isEmpty }),
                passwordTextField.rx.text.map({ $0!.isEmpty }))
            .map ({ (isEmailEmpty, isPasswordEmpty) -> Bool in
                return !(isEmailEmpty || isPasswordEmpty)
            })
            .subscribe(onNext: { [weak self] isEnabled in
                self?.loginButton.isEnabled = isEnabled
            })
            .disposed(by: disposeBag)
    }
    
    func bindViewModelToView() {
        viewModel.result
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: { [weak self] result in
                guard let result = result, let self = self else { return }
                
                switch result {
                case .success(let res):
                    self.resultLabel.text = "結果：ログインに成功しました。\nemail:\(res.result.email)\ntoken:\(res.result.token)"

                case .failure(let error):
                    self.resultLabel.text = "結果：ログインに失敗しました。\n\(error.localizedDescription)"
                }
            })
            .disposed(by: disposeBag)
        viewModel.loading
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] loading in
                guard let self = self else { return }
                loading ? self.loadingIndicator.startAnimating() : self.loadingIndicator.stopAnimating()
            })
            .disposed(by: disposeBag)
    }
}
