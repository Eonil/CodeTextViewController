//
//  CodeData.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2014/12/29.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation



///	Provides shared access to a mutable string storage.
///
///	You must call `synchroniseCache` after editing the source string.
final class CodeData {
	init(target:NSMutableAttributedString) {
		self.target						=	target
		self.targetNSMutableStringRef	=	target.mutableString
	}
	private let target:NSMutableAttributedString
	private let	targetNSMutableStringRef:NSMutableString
	
	var unicodeScalars:String.UnicodeScalarView {
		get {
			return	target.string.unicodeScalars
		}
	}
	var utf16Count:Int {
		get {
			return	target.length
		}
	}
	var utf16:String.UTF16View {
		get {
			return	target.string.utf16
		}
	}
}




//extension CodeData {
//	///	Fixes current text to provide high performance read without internal conversion.
//	func beginHighPerformanceImmutableReadSession() {
//		
//	}
//	func endHighPerformanceImmutableReadSession() {
//		
//	}
//}



extension CodeData {
	func substringWithUTF16Range(range:UTF16Range) -> String {
		let	r	=	NSRange(location: range.startIndex, length: range.endIndex - range.startIndex)
		return	(target.string as NSString).substringWithRange(r)
	}
//	func substringFromUTF16Index(index:UTF16Index) -> String {
//		return	(target.string as NSString).substringFromIndex(index)
//	}
//	func substringToUTF16Index(index:UTF16Index) -> String {
//		return	(target.string as NSString).substringToIndex(index)
//	}

	///	Optimised to avoid conversion and RC as much as possible.
	func hasPrefixAtUTF16IndexUnsafe(inout string:String , index:UTF16Index) -> Bool {
		let	stringLen		=	string.utf16.endIndex
		let	availableLen	=	target.length - index
		if availableLen < stringLen {
			return	false
		}
		
		for i in 0..<stringLen {
			let	c1	=	string.utf16[i]
			let	c2	=	targetNSMutableStringRef.characterAtIndex(index+i)
			if c1 != c2 {
				return	false
			}
		}
		return	true
	}
	

	///	Optimised to avoid conversion as much as possible.
	func hasPrefixAtUTF16Index(string:String , index:UTF16Index) -> Bool {
		let	stringLen		=	string.utf16.endIndex
		let	availableLen	=	target.length - index
		if availableLen < stringLen {
			return	false
		}
		
		for i in 0..<stringLen {
			let	c1	=	string.utf16[i]
			let	c2	=	targetNSMutableStringRef.characterAtIndex(index+i)
			if c1 != c2 {
				return	false
			}
		}
		return	true
	}
	
//	///	Optimised to avoid conversion as much as possible.
//	func hasPrefixAtUTF16Index(mark:BlockMark, index:UTF16Index) -> Bool {
//		let	availableLen	=	targetNSStringCache.length - index
//		if availableLen < mark.string.utf16.endIndex {
//			return	false
//		}
//		for i in 0..<mark.string.utf16.endIndex {
//			let	c1	=	mark.string.utf16[i]
//			let	c2	=	targetNSStringCache.characterAtIndex(index+i)
//			if c1 != c2 {
//				return	false
//			}
//		}
//		return	true
//		
////		let	nss	=	targetNSStringCache
////		if (nss.length - index) < string.utf16Count {
////			return	false
////		}
////		let	r	=	NSRange(location: index, length: string.utf16Count)
////		let	c	=	(target.string as NSString).compare(string, options: NSStringCompareOptions.allZeros, range: r)
////		return	c == NSComparisonResult.OrderedSame
//	}
}
























extension UnitTest {
	static func testCodeData() {
		test1()
		test2()
	}

	private static func test1() {
		let	s	=	NSMutableAttributedString(string: "ABC")
		let	d	=	CodeData(target: s)
		assert(String(d.unicodeScalars) == "ABC")
		
		let	r	=	d.unicodeScalars.startIndex.successor()..<d.unicodeScalars.endIndex
		assert(String(d.unicodeScalars[r]) == "BC")
		
		s.mutableString.appendString("DEF")
		assert(String(d.unicodeScalars) == "ABCDEF")
	}
	private static func test2() {
		let	d	=	CodeData(target: NSMutableAttributedString(string: "ABC"))
		assert(d.hasPrefixAtUTF16Index("A", index: 0))
	}
}





