// this agent manages the supply of beers to supermarkets
// using a closed auction protocol and identify the winner
         
/* Initial beliefs and rules */  
auctionNumber(1).            

/* Initial goals */  
!start_auction.
       
/* Plans */ 
+!start_auction : auctionNumber(N) <-                                               
	.wait(6000);
    PUBeer = math.round(math.random(30))+1; // stablish the Prix of Beer (PUBeer) randomly
    NBeer = math.round(math.random(10))+1;  // stablish the Number of Beer auctioned randomly      
	.broadcast(tell, subasta(N, NBeer, PUBeer)); 
	newAuction(N);
	.println("Se anuncia una subasta de ", NBeer," con un precio inicial de ", PUBeer, " por unidad.");
	.wait(200);
	!place_bid(N,_);
	-+auctionNumber(N+1);   
	!start_auction.   
	

/* 
@pb1[atomic]
+place_bid(N,_)     // receives bids and checks for new winner
   :  .findall(b(V,A),place_bid(N,V)[source(A)],L) &                                       
      .length(L,3)  // all 3 expected bids was received
   <- .max(L,b(V,W));
      .print("Winner is ",W," with ", V);
      show_winner(N,W); // show it in the GUI
      .broadcast(tell, winner(W));
      .abolish(place_bid(N,_)).  
*/
@pb1[atomic]
+!place_bid(N,_) :  offer(N,_)  <- // receives bids and checks for new winner 
	.wait(2000);
	.findall(b(V,A),offer(N,V)[source(A)],L);                                  
    .max(L,b(V,W));
	.print("El ganador de la subasta ", N, " es ", W," con ", V, " centimos totales.");
    .broadcast(tell, winner(N,W,V)).  
	
+!place_bid(N,_) :  not offer(N,_)  <- 
	.wait(10000);
	.findall(b(V,A),offer(N,V)[source(A)],[]);  
	.println("Se cierra la subasta ", N, " sin ofertas.").
