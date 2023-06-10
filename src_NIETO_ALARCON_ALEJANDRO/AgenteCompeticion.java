package tracks.singlePlayer.evaluacion.src_NIETO_ALARCON_ALEJANDRO;

import java.util.ArrayList;


import java.util.Collections;
import java.util.Comparator;

import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import ontology.Types.ACTIONS;
import tools.ElapsedCpuTimer;
import tools.Vector2d;

class SortNodeAgent implements Comparator<Nodo>
{
    // Used for sorting in ascending order of
    // roll number
    public int compare(Nodo a, Nodo b)
    {
    	return a.getF() < b.getF() ? 1 : a.getF() > b.getF() ? -1 :  a.getG() < b.getG() ? 1 : a.getG() > b.getG() ? -1 : a.getOrder() < b.getOrder() ? 1 : -1  ;
    }
}


public class AgenteCompeticion  extends AbstractPlayer{
	//Greedy Camel: 
	// 1) Busca la puerta m�s cercana. 
	// 2) Escoge la accion que minimiza la distancia del camello a la puerta.

	Vector2d fescala;
	Vector2d portal;
	ArrayList<Nodo> abiertos;
	ArrayList<ArrayList<Nodo>> matrix_guia;
	Vector2d avatar;
	ArrayList<String> path;
	 ArrayList<Observation>[] posiciones_muros;
	
	boolean pathCalculated = false;
	private int nodosExpandidos = 0;
	
	/**
	 * initialize all variables for the agent
	 * @param stateObs Observation of the current state.
     * @param elapsedTimer Timer when the action returned is due.
	 */
	public AgenteCompeticion(StateObservation stateObs, ElapsedCpuTimer elapsedTimer){
		//Calculamos el factor de escala entre mundos (pixeles -> grid)
        fescala = new Vector2d(stateObs.getWorldDimension().width / stateObs.getObservationGrid().length , 
        		stateObs.getWorldDimension().height / stateObs.getObservationGrid()[0].length);      
      
        //Se crea una lista de observaciones de portales, ordenada por cercania al avatar
        ArrayList<Observation>[] posiciones = stateObs.getPortalsPositions(stateObs.getAvatarPosition());
        //Seleccionamos el portal mas proximo
        portal = posiciones[0].get(0).position;
        portal.x = Math.floor(portal.x / fescala.x);
        portal.y = Math.floor(portal.y / fescala.y);
        
        
           
        
	}
	
	/**
	 * return the best action to arrive faster to the closest portal
	 * @param stateObs Observation of the current state.
     * @param elapsedTimer Timer when the action returned is due.
	 * @return best	ACTION to arrive faster to the closest portal
	 */
	@Override
	public ACTIONS act(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {
		
		/*
		 * 
		 * A partir de aqui contenemos el mismo codigo que usamos en el A*
		 * pero lo llamamos en cada iteracion para calcular el camino en caso
		 * de que hayamos pisado (no lo sabemos) una casilla que nos desbloquea
		 * parte del mapa por lo cual lo que hacemos en cada iteracion es generar
		 * la matriz que nos sirve como representacion del mapa y poner todos los muros y trampas en ella
		 * a partir de ahi volvemos a calcular el camino hasta la meta y devolvemos el primer movimiento a realizar
		 * y asi hasta que lleguemos a la meta.
		 * 
		 * Basicamente esto se hace ya que en el agente de la competicion solo se tiene en cuenta el numero minimo de ticks
		 * en encontrar la meta por lo cual A* será siempre lo más optimo debido a que estamos
		 * en un entorno de informacion completa y contamos con que sabemos el lugar de la meta
		 * y el valor heuristico de cada una de las casillas.
		 * 
		 */
		
		long tInicio = System.nanoTime();
		
		posiciones_muros = stateObs.getImmovablePositions();

        abiertos = new ArrayList<Nodo>();
        matrix_guia = new ArrayList<ArrayList<Nodo>>();
        

        for (int i = 0; i < stateObs.getObservationGrid()[0].length; i++) {
        	ArrayList<Nodo> row = new ArrayList<Nodo>();
        	for(int j = 0; j < stateObs.getObservationGrid().length; j++) {
        		Nodo node = new Nodo(i, j, 0, 0);
        		node.setH(this.distanceToGoal(portal, node));
        		node.setVisited(0);
        		node.setType(1);
        		row.add(node);
        	}
        	matrix_guia.add(row);
        	
        }

        for (int i = 0; i < posiciones_muros[0].size(); i++) {
        	Vector2d muro = posiciones_muros[0].get(i).position;
        	muro.x = Math.floor(muro.x / fescala.x);
        	muro.y = Math.floor(muro.y / fescala.y);
        	matrix_guia.get((int) muro.y).get((int)muro.x).setType(0);
        }
        
        
        for (int i = 0; i < posiciones_muros[1].size(); i++) {
        	Vector2d muro = posiciones_muros[1].get(i).position;
        	muro.x = Math.floor(muro.x / fescala.x);
        	muro.y = Math.floor(muro.y / fescala.y);
        	matrix_guia.get((int) muro.y).get((int)muro.x).setType(0);
        }
        

		
        avatar =  new Vector2d(stateObs.getAvatarPosition().x / fescala.x, 
        		stateObs.getAvatarPosition().y / fescala.y);

        
	    
        matrix_guia.get((int) avatar.y).get((int) avatar.x).setVisited(1);
        matrix_guia.get((int) avatar.y).get((int)avatar.x).setPadre(null);
        abiertos.add(matrix_guia.get((int) avatar.y).get((int) avatar.x));

        while (true) {
        	
        	Collections.sort(this.abiertos, new SortNodeAgent());

        	Nodo actual = this.abiertos.get(this.abiertos.size() -1);	 
        	this.nodosExpandidos += 1;
        	
        	if(actual.getX() == portal.y && actual.getY() == portal.x) {
        		long tFin = System.nanoTime();
        		long tiempoTotalms = (tFin - tInicio)/1000000;
        		
        		this.pathCalculated = true;
        		path = this.recuperarCamino(actual);
        		
        		System.out.println("Runtime -- " + tiempoTotalms + "ms");
        		System.out.println("Path size -- " + this.path.size());
        		System.out.println("Nodos expandidos -- " + this.nodosExpandidos);

        		
        		break;
        	}
        	
        	this.abiertos.remove(this.abiertos.size() -1);
        	actual.setVisited(2);	
        	
        	Nodo node_up_new = matrix_guia.get((int)actual.getX() - 1).get((int) actual.getY()).getCopy();
        	Nodo node_up = matrix_guia.get((int)actual.getX() - 1).get((int) actual.getY());
        	if(node_up_new.getType() != 0) {
        		
        		node_up_new.setG(actual.getG() + 1);
	        	
	        	if(node_up_new.getVisited() == 2 && (node_up_new.getF() < node_up.getF())) {
	        		node_up.setG(node_up_new.getG());
	        		node_up.setOrder(0);
	        		node_up.setPadre(actual);
	        		node_up.setVisited(1);
	        		abiertos.add(node_up);
	        	} else if(node_up_new.getVisited() != 2 && node_up_new.getVisited() != 1) {
	        		node_up.setG(node_up_new.getG());
	        		node_up.setVisited(1);
	        		node_up.setPadre(actual);
	        		node_up.setOrder(0);
	        		abiertos.add(node_up);
	        	} else if(node_up_new.getVisited() == 1 && (node_up_new.getF() < node_up.getF())){
	        		node_up.setG(node_up_new.getG());
	        		node_up.setPadre(actual);
	        		node_up.setVisited(1);
	        		node_up.setOrder(0);
	        	}
        	}
        	
        	
        	Nodo node_down_new = matrix_guia.get((int)actual.getX() + 1).get((int) actual.getY()).getCopy();
        	Nodo node_down = matrix_guia.get((int)actual.getX() + 1).get((int) actual.getY());
        	if(node_down_new.getType() != 0) {
        		
        		node_down_new.setG(actual.getG() + 1);
	        	
	        	if(node_down_new.getVisited() == 2 && (node_down_new.getF() < node_down.getF())) {
	        		node_down.setG(node_down_new.getG());
	        		node_down.setOrder(1);
	        		node_down.setVisited(1);
	        		node_down.setPadre(actual);
	        		abiertos.add(node_down);
	        		
	        	} else if(node_down_new.getVisited() != 2 && node_down_new.getVisited() != 1) {
	        		node_down.setG(node_down_new.getG());
	        		node_down.setVisited(1);
	        		node_down.setOrder(1);
	        		node_down.setPadre(actual);
	        		abiertos.add(node_down);
	        	} else if(node_down_new.getVisited() == 1 && (node_down_new.getF() < node_down.getF())){
	        		node_down.setG(node_down_new.getG());
	        		node_down.setOrder(1);
	        		node_down.setPadre(actual);
	        		node_down.setVisited(1);
	        	}
        	}
        	
        	
        	Nodo node_left_new = matrix_guia.get((int)actual.getX()).get((int) actual.getY()-1).getCopy();
        	Nodo node_left = matrix_guia.get((int)actual.getX()).get((int) actual.getY()-1);
        	if(node_left_new.getType() != 0) {
        		
        		node_left_new.setG(actual.getG() + 1);
	        	
	        	if(node_left_new.getVisited() == 2 && (node_left_new.getF() < node_left.getF())) {
	        		node_left.setG(node_left_new.getG());
	        		node_left.setOrder(2);
	        		node_left.setPadre(actual);
	        		node_left.setVisited(1);
	        		abiertos.add(node_left);
	        	} else if(node_left_new.getVisited() != 2 && node_left_new.getVisited() != 1) {
	        		node_left.setG(node_left_new.getG());
	        		node_left.setVisited(1);
	        		node_left.setOrder(2);
	        		node_left.setPadre(actual);
	        		abiertos.add(node_left);
	        	} else if(node_left_new.getVisited() == 1 && (node_left_new.getF() < node_left.getF())){
	        		node_left.setG(node_left_new.getG());
	        		node_left.setOrder(2);
	        		node_left.setPadre(actual);
	        		node_left.setVisited(1);
	        	}
        	}
        	
        	//System.out.println(actual.getX() + " " + actual.getY());
        	Nodo node_right_new = matrix_guia.get((int)actual.getX()).get((int) actual.getY()+1).getCopy();
        	Nodo node_right = matrix_guia.get((int)actual.getX()).get((int) actual.getY()+1);
        	if(node_right_new.getType() != 0) {
        		
        		node_right_new.setG(actual.getG() + 1);
        		
	        	if(node_right_new.getVisited() == 2 && (node_right_new.getF() < node_right.getF())) {
	        		node_right.setG(node_right_new.getG());
	        		node_right.setOrder(3);
	        		node_right.setPadre(actual);
	        		node_right.setVisited(1);
	        		abiertos.add(node_right);
	        	} else if(node_right_new.getVisited() != 2 && node_right_new.getVisited() != 1) {
	        		node_right.setG(node_right_new.getG());
	        		node_right.setVisited(1);
	        		node_right.setOrder(3);
	        		node_right.setPadre(actual);
	        		abiertos.add(node_right);
	        	} else if(node_right_new.getVisited() == 1 && (node_right_new.getF() < node_right.getF())){
	        		node_right.setG(node_right_new.getG());
	        		node_right.setOrder(3);
	        		node_right.setPadre(actual);
	        		node_right.setVisited(1);
	        	}
        	}
        	
        }

		
		if(path.get(0) == "UP") {
			path.remove(0);
			return Types.ACTIONS.ACTION_UP;
		} else if(path.get(0) == "DOWN") {
			path.remove(0);
			return Types.ACTIONS.ACTION_DOWN;
		} else if(path.get(0) == "LEFT") {
			path.remove(0);
			return Types.ACTIONS.ACTION_LEFT;
		} else {
			path.remove(0);
			return Types.ACTIONS.ACTION_RIGHT;
		}
		
		
        
	}
	
	public ArrayList<String> recuperarCamino(Nodo portal) {
		
		Nodo current = portal;
		ArrayList<String> path = new ArrayList<String>();
		while(current.getPadre() != null) {
			
			if(current.getY() < matrix_guia.get((int)current.getPadre().getX()).get((int) current.getPadre().getY()).getY()) {
				path.add(0, "LEFT");
			} else if(current.getY() > matrix_guia.get((int)current.getPadre().getX()).get((int) current.getPadre().getY()).getY()) {
				path.add(0, "RIGHT");
			} else if(current.getX() < matrix_guia.get((int)current.getPadre().getX()).get((int) current.getPadre().getY()).getX()) {
				path.add(0, "UP");
			} else if(current.getX() > matrix_guia.get((int)current.getPadre().getX()).get((int) current.getPadre().getY()).getX()) {
				path.add(0, "DOWN");
			}
			
			current = matrix_guia.get((int)current.getPadre().getX()).get((int) current.getPadre().getY());
			
		}
		
		return path;
	
	}
	
	public int distanceToGoal(Vector2d portal, Nodo actual) {
		int x_value = (int) Math.abs((portal.y - actual.getX()));
		int y_value = (int) Math.abs((portal.x - actual.getY()));
		return x_value + y_value;
	}
}



