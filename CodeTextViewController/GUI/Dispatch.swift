//
//  Dispatch.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2015/01/06.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation

func dispatchMain(f:()->()) {
	dispatch_async(dispatch_get_main_queue()) {
		f()
	}
}