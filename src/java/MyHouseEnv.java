import jaca.CartagoEnvironment;

import jason.asSyntax.*;
import jason.asSyntax.Literal;
import jason.asSyntax.Structure;               
import jason.environment.Environment;
import jason.environment.grid.Location;                               

import java.util.logging.Logger;

public class MyHouseEnv extends Environment {

    // common literals
    public static final Literal of  	= Literal.parseLiteral("open(fridge)");       
    public static final Literal clf 	= Literal.parseLiteral("close(fridge)");    
    public static final Literal gb  	= Literal.parseLiteral("get(beer)");        
    public static final Literal hb  	= Literal.parseLiteral("hand_in(beer)");     
    public static final Literal sb  	= Literal.parseLiteral("sip(beer)");        
    public static final Literal hob 	= Literal.parseLiteral("has(myRobot,beer)");          
    public static final Literal cb	 	= Literal.parseLiteral("getBeer");    
	public static final Literal pb	 	= Literal.parseLiteral("putBeer"); 
	public static final Literal tb	 	= Literal.parseLiteral("troughtBeer"); 
	public static final Literal eb	 	= Literal.parseLiteral("emptyBasket"); 
	
	
    public static final Literal arf  	= Literal.parseLiteral("at(myRobot,fridge)");
    public static final Literal aro  	= Literal.parseLiteral("at(myRobot,myOwner)");
    public static final Literal ard  	= Literal.parseLiteral("at(myRobot,delivery)");
    public static final Literal arb  	= Literal.parseLiteral("at(myRobot,basket)");
    public static final Literal arc  	= Literal.parseLiteral("at(myRobot,chair)");
    public static final Literal arbo  	= Literal.parseLiteral("at(myRobot,bottle)");
    public static final Literal abr  	= Literal.parseLiteral("at(myRobot,base)");
	
    public static final Literal aof  	= Literal.parseLiteral("at(myOwner,fridge)");
    public static final Literal aor  	= Literal.parseLiteral("at(myOwner,myRobot)");
    public static final Literal aob  	= Literal.parseLiteral("at(myOwner,basket)");
    public static final Literal aoc  	= Literal.parseLiteral("at(myOwner,chair)");
    public static final Literal aobo  	= Literal.parseLiteral("at(myOwner,bottle)");
	
    static Logger logger = Logger.getLogger(MyHouseEnv.class.getName());
	
	private CartagoEnvironment cartagoEnv;

    MyHouseModel model; // the model of the grid

    @Override
    public void init(String[] args) {
        model = new MyHouseModel();
		
        MyHouseView view  = new MyHouseView(model);                        
        model.setView(view);
                                                                       
		startCartago(args);

        updatePercepts();
    }
	
	public void startCartago(String[] args) { 
		cartagoEnv = new CartagoEnvironment();
		cartagoEnv.init(args);
	}  
	
	/** Called before the end of MAS execution */
	@Override
	public void stop() {
		super.stop();
		if (cartagoEnv != null)
			cartagoEnv.stop();
	}
              
    /** creates the agents percepts based on the HouseModel */
    void updatePercepts() {

		clearAllPercepts();
		
		addPercept(Literal.parseLiteral("repartoProveedor("+model.lastAuction+","+model.providedBeers+")"));   
        addPercept(Literal.parseLiteral("inBasket(beer,"+model.basketBeers+")"));
		addPercept(Literal.parseLiteral("inFloor(beer,"+model.floorBeers+")"));
		
        // get the robot location
        Location lRobot = model.getAgPos(1);
        //System.out.println("Posición del robot:"+lRobot);
		
        // get the owner location
        Location lOwner = model.getAgPos(0);
        //System.out.println("Posición del agente owner:"+lOwner);
		
        // add agent location to its percepts
        if (model.lBottle != null && lOwner.isNeigbour(model.lBottle)) {
			addPercept("myOwner", aobo);
        }

        if (model.lBottle != null && lRobot.isNeigbour(model.lBottle)) {
            addPercept("myRobot", arbo);
        }

        if (lRobot.isNeigbour(model.lFridge)) {
            addPercept("myRobot", arf);
        }
		if (lRobot.isNeigbour(lOwner)) {
            addPercept("myRobot", aro);  
			addPercept("myOwner", aor);
        }

        if (lOwner.isNeigbour(model.lFridge)) {
            addPercept("myOwner", aof);    
        }
		
        if (lRobot.isNeigbour(model.lChair)) {
            addPercept("myRobot", arc);
        }
        
        if (lOwner.equals(model.lChair)) {
            addPercept("myOwner", aoc);
        }
        
		if (lRobot.equals(model.lDelivery)) {
            addPercept("myRobot", ard);
        }

		if (lRobot.isNeigbour(model.lBasket)) {
            addPercept("myRobot", arb);
        }

		if (lOwner.isNeigbour(model.lBasket)) {
            addPercept("myOwner", aob);
        }

		if (lRobot.equals(model.lBase)) {
            addPercept("myRobot", abr);
        }

        // add beer stock when the fridge is open
        if (model.fridgeOpen) {
            addPercept("myRobot", Literal.parseLiteral("stock(beer,"+model.availableBeers+")"));   
			addPercept("myOwner", Literal.parseLiteral("stock(beer,"+model.availableBeers+")"));
        }
		
        // Sips done by owner
        if (model.sipCount > 0) {  
			int tragos = model.SIPMAX - model.sipCount;  
			addPercept("myOwner", Literal.parseLiteral("sipDone("+tragos+")"));
            addPercept("myRobot", hob);  
            addPercept("myOwner", hob);
        }
    }

                       
    @Override
    public boolean executeAction(String ag, Structure action) {

		// Inform actions required on the environment        
		if (ag.equals("myRobot")) {
			//System.out.println("Robot interacciona con el entorno con: "+action);
		} else if (ag.equals("myOwner")) {
			//System.out.println("Owner interacciona en el entorno pidiendo:"+action);
		} else {
			//System.out.println("["+ag+"] doing: "+action);
        };
		
		boolean result = false;
		
        // of = open(fridge)
		if (action.equals(of)) { 
            result = model.openFridge();

        // clf = close(fridge)
		} else if (action.equals(clf)) { 
            result = model.closeFridge();
		
		// move_towards(Who, Where) move an agent named Who to Where
        } else if (action.getFunctor().equals("move_towards")) {
            // Where is moving
			String l = action.getTerm(0).toString();       	
            
			Location dest = null;
            if (l.equals("fridge")) {
                dest = model.lFridge;
            } else if (l.equals("myRobot")) {
                dest = model.lRobot;
            } else if (l.equals("chair")) {
                dest = model.lChair;
            } else if (l.equals("basket")) {
                dest = model.lBasket;
            } else if (l.equals("myOwner")) {
                dest = model.lOwner;
            } else if (l.equals("delivery")) {
                dest = model.lDelivery;
            } else if (l.equals("bottle")) {
                dest = model.lBottle;
            } else if (l.equals("base")) {
                dest = model.lBase;
            }

            try {
                if (ag.equals("myRobot")) {
					// Name of device that is moving
					//model.device = action.getTerm(0).toString();
					//It requires that robot was declared after owner on .mas2j
					result = model.moveTowards(1, dest); 
				} else { 
					//0 is the first agent declared on .mas2j
					result = model.moveTowards(0, dest); 
				};
				Thread.sleep(300);
            } catch (Exception e) {
                e.printStackTrace();
            }
                          
		// Throw a beer to floor
        } else if (action.equals(tb) & ag.equals("myOwner")) { 
            result = model.troughtBeer(); 
			
		// Get a beer from fridge	
        } else if (action.equals(gb)) { 
            result = model.getBeer();   
			
		// Updates the beer stock on fridge	
        } else if (action.getFunctor().equals("updateStock")) {
            try {
				System.out.println("Actualizo las cervezas en el frigorifico.");
				result = model.addBeer((int)((NumberTerm)action.getTerm(1)).solve());   
			} catch (Exception e) {
				logger.info("Failed to execute action updateStock"+e);
			}
			
		// Pick up a can from the floor	
        } else if (action.equals(cb)) {   
			result = model.collectBeer();
			
		// Put a beer on the basket	
        } else if (action.equals(pb)) { 
            result = model.putBeer();
		
		// Empty the basket	
        } else if (action.equals(eb)) {
            result = model.emptyBasket();

		// Robot informs that owner has a beer in his hand	
        } else if (action.equals(hb)) {
            result = model.handInBeer();

		// Owner informs that owner is taking a sip 	
        } else if (action.equals(sb) & ag.equals("myOwner")) {
            System.out.println("El owner está bebiendo.");
			result = model.sipBeer();

		// Super informs that has received a deliver from an auction 	
        } else if (action.getFunctor().equals("deliver")) {
            try {
                result = model.addBeerAuctionProvided( (int)((NumberTerm)action.getTerm(1)).solve());
            } catch (Exception e) {
                logger.info("Failed to execute action deliver <== beers auction provided!"+e);
            }
			
		// Super reports a beer delivery to the robot 	
        } else if (action.getFunctor().equals("deliverReady")) {
            try {
                result = model.addBeer( (int)((NumberTerm)action.getTerm(2)).solve());
            } catch (Exception e) {
                logger.info("Failed to execute action deliver <== beers auction provided!"+e);
            }
			
		// Super informs an alliance	
        } else if (action.getFunctor().equals("doneAlianza")) {
            try {
                logger.info("Here go the execution of doneAlianza action."); 
				result = true;
            } catch (Exception e) {
                logger.info("Failed to execute action doneAlianza!"+e);
            }
                                                                                                                                           
		// Provider informs a new auction	
        } else if (action.getFunctor().equals("newAuction") & ag.equals("provider")) {
            try {
                result = model.updateLastAuction( (int)((NumberTerm)action.getTerm(0)).solve(), (int)((NumberTerm)action.getTerm(1)).solve(), (int)((NumberTerm)action.getTerm(2)).solve());
            } catch (Exception e) {
                logger.info("Failed to execute action newAuction!"+e);
            }
                                                                                                                                           
        } else {
            logger.info("Failed to execute action "+action);
        }

        if (result) {
            updatePercepts();
            try {
                Thread.sleep(100);
            } catch (Exception e) {}
        }
        return result;
    }
}
