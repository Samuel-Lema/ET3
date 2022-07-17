/* Initial beliefs and rules */

state(5). 	// 5 Animado
			// 4 Euforico
			// 3 Crispado
			// 2 Amodorrado
			// 1 Dormido
dinero(3000).

/* Initial goals */

!setupTool.
!initBot.
!ask_time.
!mood.
!sit.
 
/* subobjectives for cheerUp */

!talkRobotInicial.
!cleanHouse.
!drinkBeer. 
!wakeUp.

/* Plans */

+!setupTool : gui(G) & .my_name(N) <-     
	makeArtifact(G,"gui.Console",[],GUI);
	setHeader(N);
    focus(GUI).

+!initBot: botname(N) <-
	makeArtifact(N,"bot.ChatBOT",["bot"],BOT);
	focus(BOT);
	+bot("bot").
	
+say(Msg) <-
	.println("Owner esta aburrido y desde la consola le dice ", Msg, " al Robot");
	.send(myRobot,tell,msg(Msg));
	-say(Msg).

+healthMsg(Msg)[source(Ag)] <- 
	.print("Message from ",Ag,": ",Msg);
	+~couldDrink(beer);
	-healthMsg(Msg).
	
+msg(Msg)[source(Ag)] <-
	.println(Ag," ha dicho: ", Msg);
	show(Msg, Ag);
	chatSincrono(Msg,Answer);
	show(Answer, "Yo");
	.send(Ag,tell,answer(Answer));
	-msg(Msg)[source(Ag)].

+answer(Msg)[source(Ag)] <-
	.println(Ag," ha contestado: ", Msg);
	show(Msg, Ag);
	-answer(Msg)[source(Ag)].

+!talkRobotInicial <-
	.wait(5000);
	!talkRobot.
	
// Segun el estado del Owner comenta diferentes cosas cuando esta aburrido
+!talkRobot: state(5) <-
	.println("Owner esta animado y da conversacion");
	show("Hola, que haces?","Yo");
	.send(myRobot, tell, msg("Hola, que haces?"));
	?compa(C);
	.send(C, tell, msg("Hola, que haces?"));
	.wait(5000);
	!talkRobot.
+!talkRobot: state(4) <-
	.println("Owner esta euforico y da conversacion");
	show("Hola, que andas haciendo!", "Yo");
	.send(myRobot, tell, msg("Hola, que andas haciendo!"));
	?compa(C);
	.send(C, tell, msg("Hola, que andas haciendo!"));
	.wait(5000);
	!talkRobot.	
+!talkRobot: state(3) <-
	.println("Owner esta crispado y da conversacion");
	show("Que demonios haces!", "Yo");
	.send(myRobot, tell, msg("Que demonios haces!"));
	?compa(C);
	.send(C, tell, msg("Que demonios haces!"));
	.wait(5000);
	!talkRobot.
+!talkRobot: state(2) <-
	.println("Owner esta amodorrado y da conversacion");
	show("Que vas a zzZZ hacer hoy?", "Yo");
	.send(myRobot, tell, msg("Que vas a zzZZ hacer hoy?"));
	?compa(C);
	.send(C, tell, msg("Que vas a zzZZ hacer hoy?"));
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
