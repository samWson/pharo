pharo - updates
update60384
	"self new update60384"
	self withUpdateLog: '19312 haltIf: should use recursionstopper
	https://pharo.fogbugz.com/f/cases/19312

18722 GlobalIdentifier used for system settings persistence
	https://pharo.fogbugz.com/f/cases/18722

19659 Tooltips of the class button does not changed
	https://pharo.fogbugz.com/f/cases/19659'.
	self loadTogether: self script60384 merge: false.
	self flushCaches.