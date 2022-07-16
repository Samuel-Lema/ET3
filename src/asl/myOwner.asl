/* Initial beliefs and rules */

state(5). 	// 5 Animado
			// 4 Euforico
			// 3 Crispado
			// 2 Amodorrado
			// 1 Dormido
dinero(3000).

// Check if owner answer requires a service
service(Answer, translating):- 			// Translating service
	checkTag("<translate>",Answer).
service(Answer, addingBot):- 			// Adding a bot property service
	checkTag("<botprop>",Answer).

	
// Checking a concrete service required by the bot ia as simple as find the required tag
// as a substring on the string given by the second parameter
checkTag(Service,String) :-
	.substring(Service,String).


// Gets into Val the first substring contained by a tag Tag into String
getValTag(Tag,String,Val) :- 
	.substring(Tag,String,Fst) &       // First: find the Fst Posicition of the tag string              
	.length(Tag,N) &                   // Second: calculate the length of the tag string
	.delete(0,Tag,RestTag) &     
	.concat("</",RestTag,EndTag) &     // Third: build the terminal of the tag string
	.substring(EndTag,String,End) &    // Four: find the Fst Position of the terminal tag string
	.substring(String,Val,Fst+N,End).  // Five: get the Val tagged

// Filter the answer to be showed when the service indicated as second arg is done
filter(Answer, translating, [To,Msg]):-
	getValTag("<to>",Answer,To) &
	getValTag("<msg>",Answer,Msg).
	
filter(Answer, addingBot, [ToWrite,Route]):-
	getValTag("<name>",Answer,Name) &
	getValTag("<val>",Answer,Val) &
	.concat(Name,":",Val,ToWrite) &
	bot(Bot) &
	.concat("/bots/",Bot,BotName) &
	.concat(BotName,"/config/properties.txt",Route).	

/* Initial goals */

!setupTool("Owner", "Robot").
!initBot.
!answerOwner.
!ask_time.
!mood.
!sit.
 
/* subobjectives for cheerUp */

!talkRobot.
!cleanHouse.
!drinkBeer. 
!wakeUp.

/* Plans */
		
+!setupTool(Name, Id) : .my_name(N) 
    <-     makeArtifact("GUI","gui.Console",[],GUI);
        setBotMasterName(Name);
        setBotName(Id);
        focus(GUI).
		
+!initBot: .my_name(N) & N == "myOwner2" <-
	makeArtifact(N,"bot.ChatBOT",["bot"],BOT);
	focus(BOT);
	+bot("bot").

+!answerOwner : msg(Msg)[source(Ag)] & bot(Bot) <-
	chatSincrono(Msg,Answer);
	-msg(Msg)[source(Ag)];   
	.println("El agente ",Ag," ha dicho ",Msg);
	.println("OWNER2 --- Le contesto al ",Ag," ",Answer);
	.send(Ag,tell,Answer).
	!answerOwner.
+!answerOwner <- !answerOwner.
		
+say(Msg) <-
	.println("Owner esta aburrido y desde la consola le dice ", Msg, " al Robot");
	.send(myRobot,tell,msg(Msg)).
	
// Segun el estado del Owner comenta diferentes cosas cuando esta aburrido
+!talkRobot: state(5) <-
	.println("Owner esta animado y le da conversacion al robot");
	.send(myRobot, tell, msg("Hola, que haces?"));
	.send(myOwner2, tell, msg("Hola, que haces?"));
	.wait(5000);
	!talkRobot.
+!talkRobot: state(4) <-
	.println("Owner esta euforico, y le da conversacion al robot");
	.send(myRobot, tell, msg("Hola, que andas haciendo!"));
	.send(myOwner2, tell, msg("Hola, que andas haciendo!"));
	.wait(5000);
	!talkRobot.	
+!talkRobot: state(3) <-
	.println("Owner esta crispado y le da conversacion al robot");
	.send(myRobot, tell, msg("Que demonios haces!"));
	.send(myOwner2, tell, msg("Que demonios haces!"));
	.wait(5000);
	!talkRobot.
+!talkRobot: state(2) <-
	.println("Owner esta amodorrado y le da conversacion al robot");
	.send(myRobot, tell, msg("Que vas a zzZZ hacer hoy?"));
	.wait(5000);
	!talkRobot.
	
+!talkRobot <- !talkRobot.

+!wakeUp: state(1) <-
	.println("Owner esta dormido y se escucha zzZZZ");
	.send(myRobot,tell,msg("zzZZ"));
	.random(R);	//se despierta en un tiempo aleatorio
	.wait(R * 4000 + 8000);
	-+state(4);
	.send(myRobot,tell,msg("Me he despertado"));
	!cleanHouse;
	!wakeUp.
	
+!wakeUp <- !wakeUp.                           
	
// Plan que se activa en un tiempo aleatorio
+!ask_time : not state(1) <-
   		.random(X); 
		.wait(X * 4000 + 8000);
	    .println("El owner pregunta la hora");
		.send(myRobot, tell, msg("Que hora es"));
		!ask_time.

+!ask_time <- !ask_time.

+!gottaGetBeer: .my_name(N) <-
	.send(myRobot, tell, "Voy yo a recoger una cerveza al frigorifico");
	!go_at(N,fridge);
	!take(fridge,beer);
	.send(myRobot, tell, "He cogido una cerveza del frigorifico");
	!go_at(N,chair);
	hand_in(beer);
	+has(N,beer).
	
+!take(fridge, beer) <-
	.println("El Owner esta cogiendo una cerveza.");
	!check(fridge, beer).
	
+!check(fridge, beer) <-
	.println("El Owner esta en el frigorifico y coge una cerveza.");
	.wait(1000);
	open(fridge);
	.println("El owner abre la nevera.");
	get(beer);
	.println("El owner coge una cerveza.");
	close(fridge);
	.println("El owner cierra la nevera.").

+!drinkBeer <- !drink(beer).

+!drink(beer) : ~couldDrink(beer) <-
	.println("Owner ha bebido demasiado por hoy.").	
+!drink(beer) : state(S) & S > 1 & .my_name(N) & has(N,beer) & asked(beer) <-
	.println("Owner va a empezar a beber cerveza.");
	-asked(beer);  
	sip(beer);
	-+state(S+1);
	.println("El Owner ha bebido cerveza y aumenta su estado de animo.");
	!drink(beer).
+!drink(beer) : not state(1) & .my_name(N) & has(N,beer) & not asked(beer) <-
	.wait(200);
	sip(beer);
	.println("Owner esta bebiendo cerveza.");
	!drink(beer).
+!drink(beer) : not state(1) & .my_name(N) & not has(N,beer) & not asked(beer) & emptyCan <-
	troughtBeer;
	-emptyCan;
	.println("El owner ha tirado una lata.");
	!drink(beer).
+!drink(beer) : not state(1) & .my_name(N) & not has(N,beer) & not asked(beer) & not emptyCan <-
	.println("Owner no tiene cerveza.");
	!get(beer);
	!drink(beer).
+!drink(beer) : not state(1) & .my_name(N) & not has(N,beer) & asked(beer) <- 
	.println("Owner esta esperando una cerveza.");
	.wait(5000);                                                                          
	!drink(beer).
+!drink(beer) <- !drink(beer).
	      
-has(N,beer): .my_name(N) <-
	+emptyCan.

+!get(beer) : not asked(beer) & state(S) & S < 5 & S \== 1 <-
	.random(R);
	if(R > 0.5){ //la mitad de las veces va a por cerveza
		//.println("El Owner decidió ir a coger cerveza");
		!gottaGetBeer;
	}else{ //la otra mitad se la pide al robot
		//.println("El Owner decidió pedirle la cerveza al robot");
		.send(myRobot, tell, msg("Traeme una cerveza."));
		.send(myRobot, tell, asked(beer));
		.println("Owner ha pedido una cerveza al robot.");
	}
	+asked(beer). 
	
+!get(beer) <- !get(beer).
	
+!go_at(A,P) : at(A,P) <- true.
+!go_at(A,P) : not at(A,P)
  <- move_towards(P);
     !go_at(A,P).
	
+!mood: .my_name(N) & at(N,chair) <-
	.random(R);
	.wait(R * 2000 + 4000);
	?state(X);
	if(X \== 1){ //si no esta ya dormido
		if(X == 2){ //si va a pasar a dormido
			.send(myRobot, tell, msg("Voy a dormir en 5 segundos."));
			.wait(5000);
		}
		-+state(X-1);
		.println("El owner esta perdiendo su estado de animo.");
	}
	!mood.

+!mood <- !mood.

+!cleanHouse: not state(1) & inFloor(beer, N) & N > 0 & .my_name(X) & at(X,chair) & not has(X,beer)<-
	.send(myRobot, tell, "Voy a tirar esta cerveza a la papelera.");
	!go_at(X,bottle);
	getBeer;
	!go_at(X,basket);
	putBeer;
	.send(myRobot, tell, "He tirado una cerveza a la papelera.");
	!go_at(X,chair);
	!cleanHouse.

+!cleanHouse <- 
	.random(X); 
	.wait(X * 5000 + 10000);
	!cleanHouse.

+!sit: .my_name(N) <-
	!go_at(N,chair).

+msg(M)[source(Ag)] <- 
	.print("Message from ",Ag,": ",M);
	+~couldDrink(beer);
	-msg(M).

+answer(Request) <-
	.println("El Robot ha contestado: ", Request);
	show(Request).
	
-answer(What) <- .println("He recibido desde el robot: ", What).

+askedMoney(X) <-
	.abolish(askedMoney(X));
	!giveMoney(X).

+!giveMoney(X) : not state(1) & dinero(D) <-
	if(D == 0){
		.send(myRobot, tell, "No me queda dinero");
	}else{
		if(X <= D){ //si tiene más que la cantidad pedida, se envía la cantidad pedida
			-+dinero(D-X);
			.send(myRobot, tell, "Aqui tienes ", X, " centimos para comprar cerveza");
			.send(myRobot, tell, receiveMoney(X));
		} else{ //si no, envía todo lo que le queda
			-+dinero(0);
			.send(myRobot, tell, "Aqui tienes ", D, " centimos para comprar cerveza");
			.send(myRobot, tell, receiveMoney(D));
		}
	}.
