package tracks.singlePlayer.evaluacion.src_NIETO_ALARCON_ALEJANDRO;

import java.util.ArrayList;

public class Nodo {
	
	private Nodo padre;
	private double g;
	private double h;
	
	private double x;
	private double y;
	private int type;
	private int visited;
	private int order;
	
	

	public Nodo(double x, double y, double g, double h) {
		super();
		this.g = g;
		this.h = h;
		this.x = x;
		this.y = y;	
	}
	
	public int getOrder() {
		return order;
	}

	public void setOrder(int order) {
		this.order = order;
	}

	public int getVisited() {
		return visited;
	}

	public void setVisited(int visited) {
		this.visited = visited;
	}

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public Nodo getPadre() {
		return padre;
	}

	public void setPadre(Nodo padre) {
		if(padre != null) {
			this.padre = new Nodo(padre.getX(), padre.getY(), 0 , 0);
		}		
	}

	public double getG() {
		return g;
	}

	public void setG(double g) {
		this.g = g;
	}

	public double getH() {
		return h;
	}

	public void setH(double h) {
		this.h = h;
	}

	public double getF() {
		return this.h + this.g;
	}

	public double getX() {
		return x;
	}

	public void setX(double x) {
		this.x = x;
	}

	public double getY() {
		return y;
	}

	public void setY(double y) {
		this.y = y;
	}
	
	
	public Nodo getCopy() {
		Nodo e = new Nodo(this.x, this.y, this.g, this.h);
		e.setPadre(this.getPadre());
		e.setType(this.getType());
		e.setVisited(this.getVisited());
		return e;
	}
	
 
	
	

}
