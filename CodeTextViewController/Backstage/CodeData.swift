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
	var utf16:String.UTF16View {
		get {
			return	target.string.utf16
		}
	}
}

extension CodeData {
//	var UTF16StartIndex:UTF16Index {
//		get {
//			return	UTF16Index(utf16.startIndex)
//		}
//	}
//	var UTF16EndIndex:UTF16Index {
//		get {
//			return	UTF16Index(utf16.endIndex)
//		}
//	}
	func substringWithUTF16Range(range:UTF16Range) -> String {
		let	r	=	NSRange(location: range.startIndex, length: range.endIndex - range.startIndex)
		return	(target.string as NSString).substringWithRange(r)
	}
	func substringFromUTF16Index(index:UTF16Index) -> String {
		return	(target.string as NSString).substringFromIndex(index)
	}
	func substringToUTF16Index(index:UTF16Index) -> String {
		return	(target.string as NSString).substringToIndex(index)
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