//
//  LoginUseCase.swift
//  RxTest
//
//  Created by TOUYA KAWANO on 2020/09/07.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

final class LoginUseCase {
    private let loadingSubject: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private let resultSubject: BehaviorRelay<Result<LoginResponse, Error>?> = BehaviorRelay(value: nil)
    private let disposeBag: DisposeBag = DisposeBag()
}

extension LoginUseCase {
    func login(email: String, password: String) {

        loadingSubject.accept(true)
        
        LoginRequest().request(.init(email: email, password: password))
            .subscribe(onSuccess: { response in
                self.loadingSubject.accept(false)
                self.resultSubject.accept(.success(response))
            }, onError: { error in
                self.loadingSubject.accept(false)
                self.resultSubject.accept(.failure(error))
            })
            .disposed(by: disposeBag)
    }
}

extension LoginUseCase {
    var loading: Observable<Bool> {
        return loadingSubject.asObservable()
    }

    var result: Observable<Result<LoginResponse, Error>?> {
        return resultSubject.asObservable()
    }
}

