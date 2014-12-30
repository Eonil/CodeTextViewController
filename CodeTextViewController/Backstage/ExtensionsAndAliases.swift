//
//  ExtensionsAndAliases.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2014/12/29.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation

typealias	UScalar		=	UnicodeScalar
typealias	UIndex		=	String.UnicodeScalarView.Index
typealias	URange		=	Range<String.UnicodeScalarView.Index>
typealias	UDistance	=	String.UnicodeScalarView.Index.Distance

extension String.UnicodeScalarView {
	func substringFromIndex(index:UIndex) -> String {
		return	String(self[index..<endIndex])
	}
}

typealias	UTF16CodeUnit	=	UTF16Char
typealias	UTF16Index		=	String.UTF16View.Index
typealias	UTF16Range		=	Range<UTF16Index>
typealias	UTF16Distance	=	UTF16Index.Distance

/////	Type-safe wrapper for UTF-16 index.
//struct UTF16Index: BidirectionalIndexType {
//	typealias	Distance	=	Int
//	
//	func successor() -> UTF16Index {
//		return	UTF16Index(number.successor())
//	}
//	func predecessor() -> UTF16Index {
//		return	UTF16Index(number.predecessor())
//	}
//	
//	private let	number:Int
//	private init(_ value:Int) {
//		self.number	=	value
//	}
//}
//func == (left:UTF16Index, right:UTF16Index) -> Bool {
//	return	left.number == right.number
//}
//func < (left:UTF16Index, right:UTF16Index) -> Bool {
//	return	left.number < right.number
//}
//
//extension String {
//	var	utf16StartIndex:UTF16Index {
//		get {
//			return	UTF16Index(utf16.startIndex)
//		}
//	}
//	var	utf16EndIndex:UTF16Index {
//		get {
//			return	UTF16Index(utf16.endIndex)
//		}
//	}
//}














extension NSRange {
	static func fromUTF16Range(range:UTF16Range) -> NSRange {
		assert(range.startIndex <= range.endIndex)
		return	NSRange(location: range.startIndex, length: range.endIndex-range.startIndex)
	}
}





















func assertMainThread() {
	assert(NSThread.mainThread() == NSThread.currentThread())
}


