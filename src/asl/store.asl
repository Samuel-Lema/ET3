// beliefs and rules

// initial goals

// plans from file:super1store.asl

// Save the agent
+!save : .my_name(Name) <- 
	.term2string(Name,SName); 
	.concat(SName,".asl",Store); 
	.save_agent(Store).

// Add a belief into the BB	table for agent Ag
+!addBelief(Ag, Belief) : not (table(Ag,Belief)) <- 
	+table(Ag, Belief); 
	!save.

// Delete the Ag table 	
+!delBelief(Ag, Belief) : (.my_name(Name) & table(Ag,_)) <- 
	.abolish(table(Ag,_)); 
	!save.
	
+!delBelief(Ag, Belief) : (.my_name(Name) & not table(Ag,_)).

// Update the Ag table with the Belief given as parameter
+!updateBelief(Ag,Belief) : (.my_name(Name) & table(Ag,_64)) <- 
	-+table(Ag,Belief); 
	!save.

// Rules to eliminate perceptions not desired	
+A[source(robot)] <- .abolish(A).
+A[source(owner)] <- .abolish(A).
+A[source(provider)] <- .abolish(A).
+A[source(percept)] <- .abolish(A).

