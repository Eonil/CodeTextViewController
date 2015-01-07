//
//  UnitTest.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2014/12/29.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation

struct UnitTest {
	static func runAll() {
		testNearestBinarySearch()
		testCodeData()
		testBlockDetection()
		testMultiblockDetection()
		testBlockDetectionController()
	}
}