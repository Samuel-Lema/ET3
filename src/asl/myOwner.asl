/* Initial beliefs and rules */

state(5). 	// 5 Animado
			// 4 Euforico
			// 3 Crispado
			// 2 Amodorrado
			// 1 Dormido
dinero(3000).

/* Initial goals */

!setupTool("Owner", "Robot").
!ask_time.
!mood.
!sit.

/* subobjectives for cheerUp */

!talkRobot.
!cleanHouse.
!drinkBeer. 
!wakeUp.

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
	
// Segun el estado del Owner comenta diferentes cosas cuando esta aburrido
+!talkRobot: state(5) <-
	.println("Owner esta animado y le da conversacion al robot");
	.send(myRobot, tell, msg("Me encuentro animado"));
	.send(myRobot, tell, msg("Hola, que haces?"));
	.wait(5000);
	!talkRobot.
+!talkRobot: state(4) <-
	.println("Owner esta euforico, y le da conversacion al robot");
	.send(myRobot, tell, msg("Me encuentro euforico"));
	.send(myRobot, tell, msg("Hola, que andas haciendo!"));
	.wait(5000);
	!talkRobot.	
+!talkRobot: state(3) <-
	.println("Owner esta crispado y le da conversacion al robot");
	.send(myRobot, tell, msg("Me encuentro crispado"));
	.send(myRobot, tell, msg("Que demonios haces!"));
	.wait(5000);
	!talkRobot.
+!talkRobot: state(2) <-
	.println("Owner esta amodorrado y le da conversacion al robot");
	.send(myRobot, tell, msg("Me encuentro amodorrado"));
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
		.wait(X * 6000 + 6000);
	    .println("El owner pregunta la hora");
		.send(myRobot, tell, msg("Que hora es"));
		!ask_time.

+!ask_time <- !ask_time.

+!gottaGetBeer: not state(1) & at(myOwner,chair) <-
	.send(myRobot, tell, "Voy yo a recoger una cerveza al frigorifico");
	!go_at(myOwner,fridge);
	!take(fridge,beer);
	.send(myRobot, tell, "He cogido una cerveza del frigorifico");
	!go_at(myOwner,chair);
	hand_in(beer);
	+has(myOwner,beer).
	
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
+!drink(beer) : state(S) & S > 1 & has(myOwner,beer) & asked(beer) <-
	.println("Owner va a empezar a beber cerveza.");
	-asked(beer);  
	sip(beer);
	if(S < 5){
		-+state(S+1);
		.println("El Owner ha bebido cerveza y aumenta su estado de animo.");
	}
	!drink(beer).
+!drink(beer) : not state(1) & has(myOwner,beer) & not asked(beer) <-
	.wait(200);
	sip(beer);
	.println("Owner esta bebiendo cerveza.");
	!drink(beer).
+!drink(beer) : not state(1) & not has(myOwner,beer) & not asked(beer) & at(myOwner,chair) & emptyCan <-
	troughtBeer;
	-emptyCan;
	.println("El owner ha tirado una lata.");
	!drink(beer).
+!drink(beer) : not state(1) & not has(myOwner,beer) & not asked(beer) & at(myOwner,chair) & not emptyCan <-
	.println("Owner no tiene cerveza.");
	!get(beer);
	!drink(beer).
+!drink(beer) : not state(1) & not has(myOwner,beer) & asked(beer) <- 
	.println("Owner esta esperando una cerveza.");
	.wait(5000);                                                                          
	!drink(beer).
+!drink(beer) <- !drink(beer).
	      
-has(myOwner,beer) <-
	+emptyCan.

+!get(beer) : not asked(beer) <-
	.random(R);
	if(R > 0.5){ //la mitad de las veces va a por cerveza
		//.println("El Owner decidi� ir a coger cerveza");
		!gottaGetBeer;
	}else{ //la otra mitad se la pide al robot
		//.println("El Owner decidi� pedirle la cerveza al robot");
		.send(myRobot, tell, msg("Traeme una cerveza."));
		.send(myRobot, tell, asked(beer));
		.println("Owner ha pedido una cerveza al robot.");
	}
	+asked(beer). 
	
+!go_at(myOwner,P) : at(myOwner,P) <- true.
+!go_at(myOwner,P) : not at(myOwner,P)
  <- move_towards(P);
     !go_at(myOwner,P).
	
+!mood: at(myOwner,chair) <-
	.random(R);
	.wait(R * 1000 + 3000);
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

+!cleanHouse: not state(1) & inFloor(beer, N) & N > 0 & at(myOwner,chair) & not has(myOwner,beer)<-
	.send(myRobot, tell, "Voy a tirar esta cerveza a la papelera.");
	!go_at(myOwner,bottle);
	getBeer;
	!go_at(myOwner,basket);
	putBeer;
	.send(myRobot, tell, "He tirado una cerveza a la papelera.");
	!go_at(myOwner,chair);
	!cleanHouse.

+!cleanHouse <- 
	.random(X); 
	.wait(X * 4000 + 8000);
	!cleanHouse.

+!sit <-
	!go_at(myOwner,chair).

//Esta regla debe modificarse adecuadamente
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
	!darDinero(X).

+!darDinero(X) : not state(1) & dinero(D) <-
	if(D == 0){
		.send(myRobot, tell, "No me queda dinero");
	}else{
		if(X <= D){ //si tiene m�s que la cantidad pedida, se env�a la cantidad pedida
			-+dinero(D-X);
			.send(myRobot, tell, "Aqui tienes ", X, " centimos para comprar cerveza");
			.send(myRobot, tell, recibirDinero(X));
		} else{ //si no, env�a todo lo que le queda
			-+dinero(0);
			.send(myRobot, tell, "Aqui tienes ", D, " centimos para comprar cerveza");
			.send(myRobot, tell, recibirDinero(D));
		}
	}.
