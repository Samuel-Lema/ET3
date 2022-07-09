/* Initial beliefs and rules */

state(5). 	// 5 Animado
			// 4 Euforico
			// 3 Crispado
			// 2 Amodorrado
			// 1 Dormido
dinero(3000).

/* Initial goals */

!setupTool("Owner", "Robot").
!gottaGetBeer.
!ask_time.
!mood.
!sit.

/* subobjectives for cheerUp */

!talkRobot.
!cleanHouse.
!drinkBeer. 
!wakeUp .

/* Plans */

// if I have not beer finish, in other case while I have beer, sip

+!setupTool(Name, Id)
	<- 	makeArtifact("GUI","gui.Console",[],GUI);
		setBotMasterName(Name);
		setBotName(Id);
		focus(GUI). 
		
+say(Msg) <-
	.println("Owner esta aburrido y desde la consola le dice ", Msg, " al Robot");
	.send(myRobot,tell,msg(Msg)).
	
// Según el estado del Owner comenta diferentes cosas cuando esta aburrido
+!talkRobot: state(5) <-
	.println("Owner esta animado y le da conversación al robot");
	.send(myRobot, tell, msg("Me encuentro animado"));
	.send(myRobot, tell, msg("Hola, ¿qué haces?"));
	.wait(5000);
	!talkRobot.
+!talkRobot: state(4) <-
	.println("Owner esta eufórico, y le da conversación al robot");
	.send(myRobot, tell, msg("Me encuentro eufórico"));
	.send(myRobot, tell, msg("Hola, que andas haciendo!"));
	.wait(5000);
	!talkRobot.	
+!talkRobot: state(3) <-
	.println("Owner esta crispado y le da conversación al robot");
	.send(myRobot, tell, msg("Me encuentro crispado"));
	.send(myRobot, tell, msg("Que demonios haces!"));
	.wait(5000);
	!talkRobot.
+!talkRobot: state(2) <-
	.println("Owner esta amodorrado y le da conversación al robot");
	.send(myRobot, tell, msg("Me encuentro amodorrado"));
	.send(myRobot, tell, msg("¿Qué vas a zzZZ hacer hoy?"));
	.wait(5000);
	!talkRobot.
	
+!talkRobot <- !talkRobot.

+!wakeUp: state(1) <-
	.println("Owner esta dormido y se escucha zzZZZ");
	.send(myRobot,tell,msg("zzZZ"));
	.random(R);	//se despierta en un tiempo aleatorio
	.wait(R * 5000 + 5000);
	-+state(4);
	.send(myRobot,tell,msg("Me he despertado"));
	!cleanHouse;
	!wakeUp.
	
+!wakeUp <- !wakeUp.
	
// Plan que se activa en un tiempo aleatorio
+!ask_time : state(S) & S > 1 <-
   		.random(X); 
		.wait(X * 6000 + 6000);
	    .println("El owner pregunta la hora");
		.send(myRobot, tell, msg("Que hora es"));
		!ask_time.

+!ask_time <- !ask_time.

+!gottaGetBeer: state(S) & S > 1 & at(myOwner,chair) <-
	.wait(15000);
	.send(myRobot, tell, "Voy yo a recoger una cerveza al frigorifico");
	!go_at(myOwner,fridge);
	!take(fridge,beer);
	.send(myRobot, tell, "He cogido una cerveza del frigorifico");
	!go_at(myOwner,chair);
	hand_in(beer);
	+has(myOwner,beer);
	+asked(beer);
	!gottaGetBeer.
	
+!gottaGetBeer <- !gottaGetBeer.
	
+!take(fridge, beer) <-
	.println("El Owner está cogiendo una cerveza.");
	!check(fridge, beer).
	
+!check(fridge, beer) <-
	.println("El Owner está en el frigorífico y coge una cerveza.");
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
+!drink(beer) : state(S) & S > 1 & has(myOwner,beer) & asked(beer) <-
	.println("Owner va a empezar a beber cerveza.");
	-asked(beer);  
	sip(beer);
	if(S<= 2){
		-+state(S+1);
		.println("el Owner ha bebido cerveza y aumenta un poco su estado de animo");
	}
	troughtBeer;
	.println("El owner ha tirado una lata");
	!drink(beer).
+!drink(beer) : state(S) & S > 1 & has(myOwner,beer) & not asked(beer) <-
	sip(beer);
	.println("Owner está bebiendo cerveza.");
	!drink(beer).
+!drink(beer) : state(S) & S > 1 & not has(myOwner,beer) & not asked(beer) <-
	.println("Owner no tiene cerveza.");
	!get(beer);
	!drink(beer).
+!drink(beer) : state(S) & S > 1 & not has(myOwner,beer) & asked(beer) <- 
	.println("Owner está esperando una cerveza.");
	.wait(5000);                                                                          
	!drink(beer).
+!drink(beer) <- !drink(beer).
	                                                                                                         
+!get(beer) : not asked(beer) <-
	.send(myRobot, tell, msg("Tráeme una cerveza"));
	.send(myRobot, tell, bring(myOwner,beer));
	.println("Owner ha pedido una cerveza al robot.");
	+asked(beer). 
	
+!go_at(myOwner,P) : at(myOwner,P) <- true.
+!go_at(myOwner,P) : not at(myOwner,P)
  <- move_towards(P);
     !go_at(myOwner,P).
	
+!mood: true <-
	.random(R);
	.wait(R * 800 + 3000);
	?state(X);
	if(X \== 1){ //si no está ya dormido
		if(X == 2){ //si va a pasar a dormido
			.send(myRobot, tell, msg("Voy a dormir en 5000 msec"));
			.wait(5000);
		}
		-+state(X-1);
		.println("El owner esta perdiendo su estado de animo");
	}
	!mood.

+!cleanHouse: state(S) & S > 1 & inFloor(beer, N) & N > 0 <-
	!go_at(myOwner,bottle);
	getBeer;
	.send(myRobot, tell, "Voy a tirar esta cerveza a la papelera");
	!go_at(myOwner,basket);
	putBeer;
	.send(myRobot, tell, "He tirado una cerveza a la papelera");
	!go_at(myOwner,chair);
	!cleanHouse.

+!cleanHouse <- 
	.random(X); 
	.wait(X * 6000 + 6000);
	!cleanHouse.

+!sit <-
	!go_at(myOwner,chair);.

//Esta regla debe modificarse adecuadamente
+msg(M)[source(Ag)] <- 
	.print("Message from ",Ag,": ",M);
	+~couldDrink(beer);
	-msg(M).

+answer(Request) <-
	.println("El Robot ha contestado: ", Request);
	show(Request).
	
-answer(What) <- .println("He recibido desde el robot: ", What).

+!darDinero(X) : state(S) & S > 1 & dinero(D) <-
	-+dinero(D-X);
	.send(myRobot, tell, "Aquí tienes ", X, " céntimos para comprar cerveza");
	.send(myRobot, tell, recibirDinero(X)).
