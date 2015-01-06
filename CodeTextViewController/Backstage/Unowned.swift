//
//  Unowned.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2015/01/05.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation

struct Unowned1<T:AnyObject> {
	
	let	ref:Unmanaged<T>
	
	init(_ value:T) {
		self.ref	=	Unmanaged<T>.passUnretained(value)
	}
	
	var value:T {
		get {
			return	ref.takeUnretainedValue()
		}
	}
}
