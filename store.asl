// beliefs and rules
kqml::bel_no_source_self(NS::Content,Ans)[hide_in_mind_inspector] :- (NS::Content[|LA] & (kqml::clear_source_self(LA,NLA) & ((Content =.. [F,T,_73]) & (Ans =.. [NS,F,T,NLA])))).
kqml::bel_no_source_self(NS::Content,Ans)[hide_in_mind_inspector] :- (NS::Content[|LA] & (kqml::clear_source_self(LA,NLA) & ((Content =.. [F,T,_73]) & (Ans =.. [NS,F,T,NLA])))).
kqml::bel_no_source_self(NS::Content,Ans)[hide_in_mind_inspector] :- (NS::Content[|LA] & (kqml::clear_source_self(LA,NLA) & ((Content =.. [F,T,_73]) & (Ans =.. [NS,F,T,NLA])))).
kqml::bel_no_source_self(NS::Content,Ans)[hide_in_mind_inspector] :- (NS::Content[|LA] & (kqml::clear_source_self(LA,NLA) & ((Content =.. [F,T,_73]) & (Ans =.. [NS,F,T,NLA])))).
kqml::clear_source_self([source(self)|T],NT)[hide_in_mind_inspector] :- kqml::clear_source_self(T,NT).
kqml::clear_source_self([A|T],[A|NT])[hide_in_mind_inspector] :- ((A \== source(self)) & kqml::clear_source_self(T,NT)).
kqml::clear_source_self([source(self)|T],NT)[hide_in_mind_inspector] :- kqml::clear_source_self(T,NT).
kqml::clear_source_self([A|T],[A|NT])[hide_in_mind_inspector] :- ((A \== source(self)) & kqml::clear_source_self(T,NT)).
kqml::clear_source_self([source(self)|T],NT)[hide_in_mind_inspector] :- kqml::clear_source_self(T,NT).
kqml::clear_source_self([A|T],[A|NT])[hide_in_mind_inspector] :- ((A \== source(self)) & kqml::clear_source_self(T,NT)).
kqml::clear_source_self([],[])[hide_in_mind_inspector].
kqml::clear_source_self([source(self)|T],NT)[hide_in_mind_inspector] :- kqml::clear_source_self(T,NT).
kqml::clear_source_self([A|T],[A|NT])[hide_in_mind_inspector] :- ((A \== source(self)) & kqml::clear_source_self(T,NT)).
beer(-2).


// initial goals


// plans from file:store.asl

@p__41[source(self),url("file:src/asl/store.asl"),url("file:store.asl")] +!delStore(beer,N) : beer(M) <- -+beer((M-N)); .save_agent("store.asl").
@p__42[source(self),url("file:src/asl/store.asl"),url("file:store.asl")] +!addStore(beer,N) : beer(M) <- -+beer((M+N)); .save_agent("store.asl").

