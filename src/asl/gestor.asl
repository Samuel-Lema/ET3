// Agent store in project DomesticRobot.mas2j

/* Initial beliefs and rules */
max_stock(beer,3). //num cervezas máximo
stock(beer,0). //num cervezas actuales
available(beer).

/* Initial goals */
!cambiarDinero(260).

/* Plans */

/*+save <-
	.println("Guardando en gestor1-saved.asl");
	.save_agent("gestor1-saved.asl");
	.abolish(save).*/

+processOrderFrom(Ag, Qtd) : stock(beer,X) & supermarket(Super) <-
	if (Qtd < X) {
		.print(Ag," ha comprado ",Qtd," cervezas.");
		.send(Super, tell, orderFrom(Ag, Qtd));
		-+stock(beer,X-Qtd);
	}
	else {
		.print(Ag," ha comprado ",X," cervezas.");
		.send(Super, tell, orderFrom(Ag, X));
		-+stock(beer,0);
	}
	.abolish(processOrderFrom(Ag, Qtd)).
	
//comprobar si se necesita reponer
+stock(beer,0) :  available(beer) & supermarket(Super) & precio(P) <-
	.send(Super,untell,hayStock(P));
	.send(Super,tell,hayStock(no));
	-available(beer);
	.println("Se necesita reponer.").
	//!prepRestock.
+stock(beer,N) :  N > 0 & not available(beer) <-
	-+available(beer).

//comprobar el num de cervezas que se pueden reponer con el precio de compra (P) que se le ha enviado
+!prepRestock(P) : max_stock(beer,Max) & dinero(D) <-
	Posibles = (D-(D mod P))/P; //división entera
	if (Posibles < Max) {
		.print("Reponiendo ",Posibles," cervezas.");
		!restock(Posibles,P);
	}
	else {
		.print("Reponiendo ",Max," cervezas.");
		!restock(Max,P);
	}.

+!restock(X,B) : dinero(D) & supermarket(Super) & precio(P) <-
	Din=D-X*B;
	!cambiarDinero(Din);
	if (X == 0) {
		.print("No hay dinero para reponer.");
	} else {
		.print("Me quedan ",Din," céntimos.");
		//.print(X," cervezas se repondrán en 20 segundos.");
		//.wait(20000);
		.print("Se han repuesto ",X," cervezas.");
		.send(Super,untell,hayStock(no));
		.send(Super,tell,hayStock(P));
	}
	-+stock(beer,X).
	
+!cambiarDinero(Din) : supermarket(Super) <-
	.send(Super,tell,dinero(Din));
	-+dinero(Din).
	
+pagar(Pago) : dinero(D) & stock(beer,X) <- //recibir pago
	Din=D+Pago;
	!cambiarDinero(Din);
	.println(Pago," céntimos recibidos. Tengo ",Din);
	//if (X == 0 & not available(beer)) {
	//	!prepRestock;
	//}
	.abolish(pagar(_)).
