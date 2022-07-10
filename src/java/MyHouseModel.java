import jason.environment.grid.GridWorldModel;
import jason.environment.grid.Location;

/** class that implements the Model of Domestic Robot application */
public class MyHouseModel extends GridWorldModel {

    // constants for the grid objects
    public static final int FRIDGE 		= 16;
    public static final int CHAIR  		= 32;
    public static final int DELIVER  	= 64;
    public static final int BASKET  	= 128;                      
    public static final int BOTTLE  	= 256; 
	public static final int BASE  		= 512;
	
	public static final int SIPMAX = 10;

    // the grid size
    public static final int GSize = 12;

    boolean fridgeOpen   		= false; 	// whether the fridge is open
    boolean carryingBeer 		= false; 	// whether the robot is carrying beer
    boolean carryingEmptyBeer 	= false; 	// whether the robot is carrying an emptybeer

    int sipCount         		= 0;   		// how many sip the owner did  
    int availableBeers   		= 6;     	// how many beers are available at fridge
    int deliveredBeers   		= 0;     	// how many beers has been delivered by super	
	int lastAuction      		= 0;     	// last auction Id
	int providedBeers    		= 0;     	// beers provided in last auction
	int paidMoney        		= 0;     	// money paid in last auction 	
	int basketBeers      		= 0;     	// beers in the basket   
	int floorBeers       		= 0;     	// beers in the floor   
	
	String device				= "Rob"; 	// active robot device 
	
	// Initial location for agents and places	
    Location lFridge = new Location(0,0); 	
    Location lChair  = new Location(GSize-1, GSize-1); 
    Location lDelivery  = new Location(0, GSize-1); 
	Location lBase = new Location(GSize-1, 0);
	Location lOwner = new Location(GSize/2+1,GSize/3-1);
	Location lRobot = new Location(GSize/3+1,GSize/2-1); 
	Location lBasket = new Location(0, 4);
	Location lBottle;
	Location aBottle = new Location(GSize/2,1);
	
    public MyHouseModel() {
        // create a 7x7 grid with one mobile agent
        super(GSize, GSize, 2);

        // Base location of robot
        // setAgPos(0, lBase);
		setAgPos(1, new Location(GSize/3+1,GSize/2-1));
		
		// Chair location of owner
        // setAgPos(1, lChair);
		setAgPos(0, new Location(GSize/2+1,GSize/3-1));
		
        // initial location of fridge and owner
        add(FRIDGE, lFridge);
        add(CHAIR, lChair);
		add(DELIVER, lDelivery);
		add(BASKET, lBasket);
		add(BASE, lBase);
		
		//lBottle = new Location(GSize/2+1,GSize/2-1);
		//add(BOTTLE, lBottle);
    }                                                             
	
	boolean updateLastAuction(int number, int beer, int prix) {
        lastAuction = number;
		providedBeers = beer; // Number of beers provided in auction
		paidMoney = prix;  
		return true;
    }
	
    boolean openFridge() {
        if (!fridgeOpen) {
            fridgeOpen = true;
            return true;
        } else {
            return false;
        }
    }

    boolean closeFridge() {
        if (fridgeOpen) {
            fridgeOpen = false;
            return true;
        } else {
            return false;
        }
    }
 
/*
	boolean atFridge(Location pos) {
		return pos.equals(lFridge);
	}       
                                                                                           
	boolean atOwner(Location pos) {
		return pos.equals(lChair);
	}   
*/	
    boolean moveTowards(int Index, Location dest) {
        Location r1 = getAgPos(Index);
        if (r1.x < dest.x)        r1.x++;
        else if (r1.x > dest.x)   r1.x--;                                                
        if (r1.y < dest.y)        r1.y++;
        else if (r1.y > dest.y)   r1.y--;
		              
		if (Index >0) { //robot
			if(r1.x == lOwner.x && r1.y == lOwner.y){
				lOwner.y--;
				setAgPos(0, lOwner);
			}
			lRobot.x = r1.x; lRobot.y = r1.y;
			//System.out.println("Posicion del robot =======>"+lRobot);
		} else { //owner
			if(r1.x == lRobot.x && r1.y == lRobot.y){
				lRobot.y--;
				setAgPos(1, lRobot);
			}
			lOwner.x = r1.x; lOwner.y = r1.y;
			//System.out.println("Posicion del owner =======>"+lOwner);
		}
        setAgPos(Index, r1); // move the robot in the grid   
		
		// repaint the locations
        if (view != null) {
			view.update();	
		} 
		                    
		return true;
    }

    boolean emptyBasket() {
        if (basketBeers > 0){// && !carryingBeer) {
            basketBeers = 0;
            if (view != null) { 
				view.update(); 
			};
                //view.update(lBasket.x,lBasket.y);
            return true;
        } else {
            return false;
        }
    }

    boolean getBeer() {
        if (fridgeOpen && availableBeers > 0) {// && !carryingBeer) {
            availableBeers--;
            carryingBeer = true;
            if (view != null)
                view.update(lFridge.x,lFridge.y);
            return true;
        } else {
            return false;
        }
    }

    boolean putBeer() { 
        if (carryingEmptyBeer) {  
            basketBeers++;
			carryingEmptyBeer = false; 
            //if (view != null)
                //view.update(lBasket.x,lBasket.y);
            return true;
        } else {
            return false;
        }
    }
	
    boolean collectBeer() { 
		/*
		if (hasObject(BOTTLE,lBottle)) {
			System.out.println("Hay una botella en el suelo");
		} else {   
			System.out.println("NO hay una botella en el suelo");
		};
		*/
        if (floorBeers>0 && hasObject(BOTTLE,lBottle)) {
            floorBeers--;                                                           
			remove(BOTTLE,lBottle);
			set(CLEAN,lBottle.x,lBottle.y);
            carryingEmptyBeer = true;
            //if (view != null)
               // view.update(lBottle.x,lBottle.y);                                  
            return true;
        } else {
            return false;
        }
    }

    boolean addBeerAuctionProvided(int n) {
		providedBeers = n;                                             
		return true;
    }

	boolean troughtBeer() {
		lBottle = aBottle;
		aBottle = new Location(lBottle.x/3+1, lOwner.y/2+1); 
		add(BOTTLE, lBottle.x, lBottle.y);
		floorBeers++; 
		//if (view != null)
        //    view.update(lBottle.x, lBottle.y);
        return true;
	}
	
    boolean addBeer(int n) {
		System.out.println("Actualizo las cervezas con "+n);
        availableBeers += n;
        if (view != null)
            view.update(lFridge.x,lFridge.y);
        return true;
    }

    boolean handInBeer() {
        if (carryingBeer) {
            sipCount = SIPMAX;
            carryingBeer = false;
            if (view != null)
                view.update(lChair.x,lChair.y);
            return true;
        } else {
            return false;
        }
    }

    boolean sipBeer() {
		System.out.println("El numero de tragos que le quedan a owner son "+sipCount);
		//System.out.println("El numero maximo de tragos es de "+SIPMAX);
        if (sipCount > 0) {
            sipCount--;
            if (view != null)
                view.update(lChair.x,lChair.y);
            return true;
        } else {
			//sipCount = 0;
            return false;
        }
    }
}
