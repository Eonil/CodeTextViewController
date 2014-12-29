//
//  Utility.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2014/12/27.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation


func assertMainThread() {
	assert(NSThread.currentThread() == NSThread.mainThread(), "Must be called from the main thread.")
}
func assertNonMainThread() {
	assert(NSThread.currentThread() != NSThread.mainThread(), "Must be called from a non-main thread.")
}