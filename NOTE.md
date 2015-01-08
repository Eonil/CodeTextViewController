NOTE
====




<!---	You should use UTF16 based counting. Because;-->
<!--	-	We're dealing with fully mutable string.-->
<!--	-	Any other indexing uses *iterator* semantics, then they will be invalidated after mutating the target string.-->
<!--	-	UTF16 based counting is simply an `Int`, and will not be invalidated.-->




GOAL
----
-	Acceptable syntax highlighting performance files smaller than 500KB.

NON-GOAL
--------
-	Acceptable syntax highlighting performance files larger than 500KB.




ROADMAP
-------

-	[OpenGL rendering to/from another process](http://cocoadhoc.blogspot.kr/2009/09/hidden-gems-of-snow-leopard-iosurface.html)








OPTIMISATION NOTE
-----------------

-	Setting attributes on a `NSTextStorage` is NOT a bottleneck. It is still so fast.
-	Bottleneck is always a `NSLayoutManager/NSTextView` invalidation and redrawing. Minimise it.