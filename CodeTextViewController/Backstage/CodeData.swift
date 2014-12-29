//
//  CodeData.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2014/12/29.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation



///	Provides shared access to a mutable string storage.
final class CodeData {
	init(target:NSMutableAttributedString) {
		self.target	=	target
	}
	private let target:NSMutableAttributedString
	
	var unicodeScalars:String.UnicodeScalarView {
		get {
			return	target.string.unicodeScalars
		}
	}
}
























extension UnitTest {
	static func testCodeData() {
		let	s	=	NSMutableAttributedString(string: "ABC")
		let	d	=	CodeData(target: s)
		assert(String(d.unicodeScalars) == "ABC")
		
		let	r	=	d.unicodeScalars.startIndex.successor()..<d.unicodeScalars.endIndex
		assert(String(d.unicodeScalars[r]) == "BC")
		
		s.mutableString.appendString("DEF")
		assert(String(d.unicodeScalars) == "ABCDEF")
	}
}