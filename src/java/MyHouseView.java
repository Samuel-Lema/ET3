import jason.environment.grid.*;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;


/** class that implements the View of Domestic Robot application */
public class MyHouseView extends GridWorldView {

    MyHouseModel hmodel;

    public MyHouseView(MyHouseModel model) {
        super(model, "Domestic Robot", 700);
        hmodel = model;
        defaultFont = new Font("Arial", Font.BOLD, 16); // change default font
        setVisible(true);
        repaint();
    }

    /** draw application objects */
    @Override
    public void draw(Graphics g, int x, int y, int object) {
        Location lRobot = hmodel.getAgPos(0);
        Location lOwner = hmodel.getAgPos(1);
        //super.drawObstacle(g,x,y);
		//super.drawAgent(g, x, y, Color.lightGray, -1);
        switch (object) {
        case MyHouseModel.FRIDGE:
			super.drawObstacle(g,x,y);
			super.drawAgent(g, x, y, Color.white, -1);
			if (lRobot.equals(hmodel.lFridge)) {
                super.drawAgent(g, x, y, Color.yellow, -1);
            }
			if (lOwner.equals(hmodel.lFridge)) {
                super.drawAgent(g, x, y, Color.blue, -1);
            }
            g.setColor(Color.black);
            drawString(g, x, y, defaultFont, "Fdg ("+hmodel.availableBeers+")");
            break;
		case MyHouseModel.BOTTLE:
			super.drawAgent(g, x, y, Color.red, -1);
            g.setColor(Color.black);
            drawString(g, x, y, defaultFont, "Bot");
            break;
		case MyHouseModel.BASKET:
			super.drawObstacle(g,x,y);
			super.drawAgent(g, x, y, Color.magenta, -1);
            if (lRobot.equals(hmodel.lBasket)) {
                super.drawAgent(g, x, y, Color.yellow, -1);
            }
			if (lOwner.equals(hmodel.lBasket)) {
                super.drawAgent(g, x, y, Color.blue, -1);
            }
            g.setColor(Color.black);
            drawString(g, x, y, defaultFont, "Bsk ("+hmodel.basketBeers+")");
            break;
		case MyHouseModel.DELIVER:
			super.drawObstacle(g,x,y);
			super.drawAgent(g, x, y, Color.green, -1);
            if (lRobot.equals(hmodel.lDelivery)) {
                super.drawAgent(g, x, y, Color.yellow, -1);
            }
            g.setColor(Color.black);
            drawString(g, x, y, defaultFont, "Del ("+hmodel.deliveredBeers+")");
            break;
		case MyHouseModel.BASE:
			super.drawObstacle(g,x,y);
			super.drawAgent(g, x, y, Color.orange, -1);
            if (lRobot.equals(hmodel.lBase)) {
                super.drawAgent(g, x, y, Color.yellow, -1);
            }
            String r = "Bas";
            g.setColor(Color.black);
            drawString(g, x, y, defaultFont, r);
            break;
		case MyHouseModel.CHAIR:
			super.drawObstacle(g,x,y);
			super.drawAgent(g, x, y, Color.blue, -1);
            String o = "Cha";         
            g.setColor(Color.black);
            drawString(g, x, y, defaultFont, o);
            break;
        }
        repaint();           
    }
                                                                                 
    @Override
    public void drawAgent(Graphics g, int x, int y, Color c, int id) {
		if (id == 1) {
			c = Color.yellow; 
			if (hmodel.carryingBeer) c = Color.orange;        
			if (hmodel.carryingEmptyBeer) c = Color.lightGray; 
			super.drawAgent(g, x, y, c, -1);
			g.setColor(Color.black);
			super.drawString(g, x, y, defaultFont, hmodel.device);
		} else { 
			c = Color.blue; 
			if (hmodel.carryingBeer) c = Color.cyan;
			if (hmodel.carryingEmptyBeer) c = Color.lightGray;
			super.drawAgent(g, x, y, c, -1);
			g.setColor(Color.black);
			String o = "owner"; 
			int tragos = hmodel.SIPMAX - hmodel.sipCount;
			if (hmodel.sipCount > 0) {
				o +=  " ("+tragos+")";
			}               
			super.drawString(g, x, y, defaultFont, o);
		}                  	
    }
}                                                                                 
