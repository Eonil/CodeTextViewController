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
