// Agent mySupermarket in project DomesticRobot.mas2j

/* Initial beliefs and rules */
// Identificador de la última orden entregada
last_order_id(1).
hayStock(no).

/* Initial goals */
!decirPrecio.
!crearGestor.
!deliverBeer.

/* Plans */
+!decirPrecio : precio(X) <-
	.send(myRobot, tell, precio(X)). //céntimos

+!crearGestor : gestor(G) & .my_name(N) & dinero(D) & precio(P) <-
	.println("Creando gestor.");
	.create_agent(G,"gestor.asl");
	.abolish(dinero(_));
	.abolish(precio(_));
	.send(G, tell, supermarket(N));
	.send(G, achieve, cambiarDinero(D));
	.send(G, tell,precio(P)).
	//.send(G, tell, save).

+!deliverBeer : last_order_id(N) & orderFrom(Ag, Qtd) <-
	OrderId = N+1;
    -+last_order_id(OrderId);
    deliver(Product,Qtd);
    .send(Ag, tell, delivered(Product, Qtd, OrderId));
	.abolish(orderFrom(Ag, Qtd));
	!deliverBeer.
	
+!deliverBeer <- !deliverBeer.
	
// plan to achieve the goal "order" for agent Ag
+!order(beer, Qtd)[source(Ag)] : gestor(G) <-
	.println("Pedido de ", Qtd, " cervezas recibido de ", Ag);
	.send(G, tell, processOrderFrom(Ag, Qtd)). //después de esto, llegará un orderFrom desde el gestor
	
+pagar(X)[source(myRobot)] : gestor(G) <-
	.send(G, tell, pagar(X));
	.abolish(pagar(_)).
	
+auction(N)[source(S)] : dinero(D) & default_bid_value(B)
   <- if(hayStock(no) & D > B){
   	  	?default_bid_value(B);
		.send(S, tell, place_bid(N,B));
	  } else{
	    .send(S, tell, place_bid(N,0));
	  }.
	  
+winner(I) : .my_name(I) & default_bid_value(P) & gestor(G)
   <- .abolish(winner(_));
	  .abolish(dinero(_));
      .send(G, achieve, prepRestock(P)).
