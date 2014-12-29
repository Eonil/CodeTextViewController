////
////  IndexSet.swift
////  CodeTextViewController
////
////  Created by Hoon H. on 2014/12/29.
////  Copyright (c) 2014 Eonil. All rights reserved.
////
//
//import Foundation
//
//
//
/////	Always sorted in ascending order.
//struct IndexSet<T:Comparable> {
//	var count:Int {
//		get {
//			return	indexes.count
//		}
//	}
//	var last:T? {
//		get {
//			return	indexes.last
//		}
//	}
//	
//	///	Returns either the closest index in the index set that is less than a specific index or `nil`.
//	func indexLessThanIndex(index:T) -> T? {
//		if indexes.count == 0 {
//			return	nil
//		}
//		var	last	=	indexes[0]
//		for i in indexes {
//			if last > index {
//				return	last
//			}
//			last	=	i
//		}
//		return	nil
//	}
//	mutating func addIndex(index:T) {
//		let	p	=	insertionPositionForIndex(index)
//		indexes.insert(index, atIndex: p)
//	}
//	mutating func removeIndexesLargerThanIndex(index:T) {
//		if let p = binarySearchForPositionOfSmallestIndexGreaterThanOrEqualToIndexValue(index, inRange: indexes.startIndex..<indexes.endIndex) {
//			let	r	=	p..<indexes.count
//			indexes.removeRange(r)
//		}
//	}
//	
//	
//	
//	////
//	
//	private var	indexes:[T]	=	[]
//	
//	private func insertionPositionForIndex(index:T) -> Int {
//		if let p = binarySearchForPositionOfSmallestIndexGreaterThanOrEqualToIndexValue(index, inRange: indexes.startIndex..<indexes.endIndex) {
//			return	p
//		} else {
//			return	indexes.endIndex
//		}
//	}
//	
//	private func binarySearchForPositionOfSmallestIndexGreaterThanOrEqualToIndexValue(value:T, inRange:Range<Int>) -> Int? {
//		return	binarySearchForIndexOfSmallestValueEqualToOrGreaterThanValue(indexes, value, inRange)
//	}
//	private func binarySearchForPositionOfLargestIndexLessThanOrEqualToIndexValue(value:T, inRange:Range<Int>) -> Int? {
//		return	binarySearchForIndexOfSmallestValueEqualToOrGreaterThanValue(indexes, value, inRange)
//	}
//}
//
