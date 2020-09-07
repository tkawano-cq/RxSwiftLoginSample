//
//  LoginViewModel.swift
//  RxTest
//
//  Created by TOUYA KAWANO on 2020/09/07.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import RxSwift
import RxRelay

final class LoginViewModel {
    private let usecase: LoginUseCase
    
    private let resultSubject: BehaviorSubject<Result<LoginResponse, Error>?> = BehaviorSubject(value: nil)
    private let loadingSubject: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    private let disposeBag: DisposeBag = DisposeBag()

    init(usecase: LoginUseCase) {
        self.usecase = usecase
        bindUsecase()
    }
    
    private func bindUsecase() {
        usecase.loading
            .bind(to: loadingSubject)
            .disposed(by: disposeBag)
        usecase.result
            .bind(to: resultSubject)
            .disposed(by: disposeBag)
    }
}

extension LoginViewModel {
    func login(email: String, password: String) {
        usecase.login(email: email, password: password)
    }
}


extension LoginViewModel {
    var loading: Observable<Bool> {
        return loadingSubject.asObservable()
    }

    var result: Observable<Result<LoginResponse, Error>?> {
        return resultSubject.asObservable()
    }
}

extension LoginViewModel {
    convenience init() {
        self.init(usecase: LoginUseCase())
    }
}
