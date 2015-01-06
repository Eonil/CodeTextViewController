//
//  SyntaxHighlightingProtocol.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2015/01/06.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation

protocol SyntaxHighlightingProtocol {
	func startProcessingFromUTF16Location(location:Int)
	func stopProcessing()
}
