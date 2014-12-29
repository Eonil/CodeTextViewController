NOTE
====




<!---	You should use UTF16 based counting. Because;-->
<!--	-	We're dealing with fully mutable string.-->
<!--	-	Any other indexing uses *iterator* semantics, then they will be invalidated after mutating the target string.-->
<!--	-	UTF16 based counting is simply an `Int`, and will not be invalidated.-->
