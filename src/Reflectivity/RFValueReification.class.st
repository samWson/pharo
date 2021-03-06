"
value

Assignment:  the orginal value for before, new value for after. 

Variables: current value (same for before and after)

Message: result of the message, only availabe for *after* links.

Return: what will be returned


"
Class {
	#name : #RFValueReification,
	#superclass : #RFReification,
	#category : #'Reflectivity-Reifications'
}

{ #category : #'plugin interface' }
RFValueReification class >> entities [
	^{RBValueNode . RBReturnNode. RBMethodNode . LiteralVariable . Slot} 
]

{ #category : #'plugin interface' }
RFValueReification class >> key [
	^#value
]

{ #category : #generate }
RFValueReification >> genForInstanceVariableSlot [
	"entity in this case is the binding of the instance variable"

	^ RBMessageNode
		receiver: (RFLiteralVariableNode value: entity)
		selector: #read:
		arguments: {(RBVariableNode named: 'self')}
]

{ #category : #generate }
RFValueReification >> genForLiteralVariable [
	"entity in this case is the binding of the literal variable"
	^RFLiteralVariableNode value: entity value
]

{ #category : #generate }
RFValueReification >> genForRBArrayNode [
	^RBVariableNode named: #RFReifyValueVar
]

{ #category : #generate }
RFValueReification >> genForRBAssignmentNode [
	"#value for Assignemnt is the old value, is that what we want?"
	^RBVariableNode named: entity variable name
]

{ #category : #generate }
RFValueReification >> genForRBBlockNode [
	^RBVariableNode named: #RFReifyValueVar
]

{ #category : #generate }
RFValueReification >> genForRBCascadeNode [
	^RBVariableNode named: #RFReifyValueVar
]

{ #category : #generate }
RFValueReification >> genForRBLiteralArrayNode [
	^RBLiteralArrayNode value: entity value
]

{ #category : #generate }
RFValueReification >> genForRBLiteralValueNode [
	^RBLiteralValueNode value: entity value
]

{ #category : #generate }
RFValueReification >> genForRBMessageNode [
	^RBVariableNode named: #RFReifyValueVar
]

{ #category : #generate }
RFValueReification >> genForRBMethodNode [
	^RBTemporaryNode named: #RFValueReificationVar
]

{ #category : #generate }
RFValueReification >> genForRBReturnNode [
	^RBVariableNode named: #RFReifyValueVar
]

{ #category : #generate }
RFValueReification >> genForRBVariableNode [
	entity isGlobal ifTrue: [^RFLiteralVariableNode value: entity binding value]. 
	^RBVariableNode named: entity name.
]

{ #category : #generate }
RFValueReification >> postamble: aNode [
	(aNode isKindOf: RBProgramNode) ifFalse: [ ^#() ].
	aNode isMessage ifTrue: [^RFStoreIntoTempNode named: 'RFReifyValueVar'. ].
	aNode isCascade ifTrue: [^RFStoreIntoTempNode named: 'RFReifyValueVar'. ].
	aNode isBlock ifTrue: [^RFStoreIntoTempNode named: #RFReifyValueVar].
	^super postamble: aNode.
	 
]

{ #category : #generate }
RFValueReification >> preamble: aNode [
	(aNode isKindOf: RBProgramNode) ifFalse: [ ^#() ].
	aNode isReturn ifTrue: [^RFStoreIntoTempNode named: #RFReifyValueVar].
	aNode isDynamicArray ifTrue: [ ^self preambleForArray: aNode ].
	^#().
	 
]

{ #category : #generate }
RFValueReification >> preambleForArray: aNode [
	| preamble arguments |
	preamble := OrderedCollection new.
	arguments := OrderedCollection new.

	(1 to: aNode size) reverseWithIndexDo: [:each :index |  
			| name |
			name := 'RFArg', index asString, 'RFReification'.
			preamble add:  (RFStorePopIntoTempNode named: name).
	].
	
	self flag: #TBD. "for #instead we do not need to build the stack up again as the array creation bytecode is missing"
	(1 to: aNode size) withIndexDo: [:each :index |  
			| name |
			name := 'RFArg', index asString, 'RFReification'.
			arguments add:  (RBTemporaryNode named: name).
	].
	preamble addAll: (RBArrayNode statements: arguments).
	preamble add: (RFStorePopIntoTempNode named: 'RFReifyValueVar').
	preamble addAll: arguments.
	^ preamble 
	
]
