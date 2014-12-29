////
////  LiveTokenMap.swift
////  CodeTextViewController
////
////  Created by Hoon H. on 2014/12/27.
////  Copyright (c) 2014 Eonil. All rights reserved.
////
//
//import Foundation
//
//
//
//
////	Let’s say we a string, 
////
////		ABCDEFGH
////		
////	and it becomes 3 tokens.
////
////		ABC DEF GH
////		t   t   t
////
////	When user deletes `E`, 
////
////		ABC D_F GH
////		t   t   t
////
////	this object deletes the whole token.
////
////		ABC DF GH
////		t      t
////
////	Calling `step` method will fill the missing token gradually.
////
////		ABC DF GH
////		t   t  t
////
//
//
////	If you insert a character(e.g. `Z` here),
////
////		ABC DZF GH
////		t   t   t
////
////	this object also kills the token.
////
////		ABC DZF GH
////		t       t
////
////	And you need to fill it by calling `step`.
////
////		ABC DZF GH
////		t   t   t
////
//
//
////	Another example. 
////
////		ABC DEF GH
////		t	t	t
////
////	User deleted `B`.
////		
////		A_C DEF GH
////			t   t
////
////	And `ACD`, `EF`, and `GH` are valid tokens.
////	This object does not consider token existence.
////	And if there’s some overlapping tokens, it will be deleted.
////
////		ACD EF GH
////		t      t
////
////	And stops finding when it meets existing token where 
////	found token exactly ends.
////
////		ACD EF GH
////		t   t  t
////
//
//class LiveTokenMap<T> {
//	init() {
//	}
//	
//	func stepProcessing() {
//	}
//	
//	////
//	
//	private let	text	=	NSMutableAttributedString()
//	private var	tokens	=	[] as [Token<T>]				///	Always being sorted in ascending order.
//	
//	private func tokenIndexAtUTF16Index(index:UTF16Index) -> Int? {
//		precondition(index > 0)
//		precondition(index < text.string.utf16Count)
//		
//		//	TODO:	optimise this.
//		var	adv	=	0
//		for i in 0..<tokens.count {
//			let	t	=	tokens[i]
//			if adv < index {
//				return	i
//			}
//			adv		+=	t.length
//		}
//		return	nil
//	}
//	
//	private func tokensRangeInUTF16Range(range:UTF16Range) -> Range<Int> {
//		precondition(range.startIndex > 0)
//		precondition(range.endIndex >= range.startIndex)
//		let	b	=	tokenIndexAtUTF16Index(range.startIndex)!
//		let	e	=	range.endIndex == text.string.utf16Count ? tokens.count : tokenIndexAtUTF16Index(range.endIndex)!
//		return	b..<e
//	}
//	
//	private func replace(range:UTF16Range, string:String) {
//		//	deleteUTF16InRange
//		text.deleteCharactersInRange(NSRange.fromUTF16Range(range))
//		
//		//	destroyTokensInRange
//		let	tr	=	tokensRangeInUTF16Range(range)
//		tokens.removeRange(tr)
//	}
//	
//	private func fillAllMissingRanges() {
//	}	
//}
//enum LiveTokenMapState {
//	case OK
//	case NeedsProcessing
//}
//struct Token<T> {
//	let	length:Int
//	let	type:T
//}
//struct LiveTokenRangeProcessing {
//	
//}
//
//
//typealias	UTF16Index	=	Int
//typealias	UTF16Range	=	Range<Int>
//
////typealias	UScalar	=	UnicodeScalar
////typealias	UIndex	=	String.UnicodeScalarView.Index
////typealias	URange	=	Range<String.UnicodeScalarView.Index>
//
//extension NSRange {
//	static func fromUTF16Range(r:UTF16Range) -> NSRange {
//		precondition(r.endIndex >= r.startIndex)
//		return	NSRange(location: r.startIndex, length: r.endIndex - r.startIndex)
//	}
//}