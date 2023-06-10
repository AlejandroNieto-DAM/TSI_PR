package tracks.singlePlayer.evaluacion.src_NIETO_ALARCON_ALEJANDRO;

import java.util.ArrayList;


import java.util.Comparator;
import java.util.PriorityQueue;

import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import ontology.Types.ACTIONS;
import tools.ElapsedCpuTimer;
import tools.Vector2d;

//Clase que usaremos para ordenar la priorityqueue
class SortNodev2 implements Comparator<Nodo>
{
	public int compare(Nodo a, Nodo b) {
		return  a.getG() > b.getG() ? 1 : a.getG() < b.getG() ? -1 : a.getOrder() < b.getOrder() ? -1 : 1;
	}
}

public class DjkistraAgent  extends AbstractPlayer{

	Vector2d fescala;
	Vector2d portal;
	PriorityQueue<Nodo> no_visitados_2;
	ArrayList<ArrayList<Nodo>> matrix_guia;
	Vector2d avatar;
	ArrayList<Integer> path;
	int indexPath = 0;
	private int nodosExpandidos = 0;
	private boolean pathCalculated = false;
	
	/**
	 * initialize all variables for the agent
	 * @param stateObs Observation of the current state.
     * @param elapsedTimer Timer when the action returned is due.
	 */
	public DjkistraAgent(StateObservation stateObs, ElapsedCpuTimer elapsedTimer){
		//Calculamos el factor de escala entre mundos (pixeles -> grid)
        fescala = new Vector2d(stateObs.getWorldDimension().width / stateObs.getObservationGrid().length , 
        		stateObs.getWorldDimension().height / stateObs.getObservationGrid()[0].length);      
      
        //Se crea una lista de observaciones de portales, ordenada por cercania al avatar
        ArrayList<Observation>[] posiciones = stateObs.getPortalsPositions(stateObs.getAvatarPosition());
        //Seleccionamos el portal mas proximo
        portal = posiciones[0].get(0).position;
        portal.x = Math.floor(portal.x / fescala.x);
        portal.y = Math.floor(portal.y / fescala.y);
        
        //Obtenemos muros y trampas
        ArrayList<Observation>[] posiciones_muros = stateObs.getImmovablePositions();

        //Creamos la matriz que albergara nuestros nodos
        matrix_guia = new ArrayList<ArrayList<Nodo>>();
        
        //Creamos la cola que mantendra en memoria nuestros nodos no visitados
        no_visitados_2 = new PriorityQueue<Nodo>(new SortNodev2());
        
   
        //Añadimos a nuestra matriz nodos cada una de las posiciones con sus caracteristicas
        //por defecto le ponemos a todas una G de 9999 para que al ordenar
        //no se encuentren al principio
        //parametro visitado 0 = no visitado 1 = visitado Los inicializamos todos a no visitados
        //parametro type 0 = muro/trampa 1 = casilla visitable
        for (int i = 0; i < stateObs.getObservationGrid()[0].length; i++) {
        	ArrayList<Nodo> row = new ArrayList<Nodo>();
        	for(int j = 0; j < stateObs.getObservationGrid().length; j++) {
        		Nodo node = new Nodo(i, j, 9999, 0);
        		node.setVisited(0);
        		node.setType(1);
        		row.add(node);
        	}
        	matrix_guia.add(row);
        	
        }
        
        //Ponemos a cada nodo si es de tipo muro o trampa poniendole el tipo a 0
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
        
        
        //Obtenemos la posicion del avatar
        avatar =  new Vector2d(stateObs.getAvatarPosition().x / fescala.x, 
        		stateObs.getAvatarPosition().y / fescala.y);
        
        
        //Cambiamos el valor G inicial para que sea 0 y le ponemos a null su padre
        matrix_guia.get((int) avatar.y).get((int)avatar.x).setG(0);
        matrix_guia.get((int) avatar.y).get((int)avatar.x).setPadre(null);
        
        //Añadimos como no visitado el primer nodo para que sea el primero en seleccionar
        no_visitados_2.add(matrix_guia.get((int) avatar.y).get((int)avatar.x));
	}
	
	/**
	 * return the best action to arrive faster to the closest portal
	 * @param stateObs Observation of the current state.
     * @param elapsedTimer Timer when the action returned is due.
	 * @return best	ACTION to arrive faster to the closest portal
	 */
	@Override
	public ACTIONS act(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {
        //Posicion del avatar

		if (!this.pathCalculated) {
			long tInicio = System.nanoTime();
			
	        while (true) {
	        	
	        	//Obtenemos nodo con menor G y lo borramos de la cola de no visitados
	        	Nodo actual = this.no_visitados_2.remove();	 
	        	this.nodosExpandidos +=1;

	        	//Comprobamos que el nodo actual sea la meta
	        	if(actual.getX() == portal.y && actual.getY() == portal.x) {

	        		this.pathCalculated = true;
	        		
	        		//Recuperamos el camino
	        		path = this.recuperarCamino(actual);
	        		
	        		indexPath = path.size() - 1;
	        		long tFin = System.nanoTime();
	        		long tiempoTotalms = (tFin - tInicio)/1000000;
	       
	        		System.out.println("Djkistra Runtime -- " + tiempoTotalms + "ms " + "Path size -- " + this.path.size() + " Nodos expandidos -- " + this.nodosExpandidos);
	        		break;
	        		
	        	}
	        	
	        	//Lo ponemos a visitado
	        	actual.setVisited(1);
	        	
	        	//Actualizamos las G de los hijos si son mejores y no estan visitados y los
	        	//añadimos a la cola de no visitados
	        	
	        	//El parametro order simplemente es para ayudar a la ordenacion de los nodos en la cola 
	        	//dando 0,1,2,3 para UP,DOWN,LEFT,RIGHT respectivamente
	        	Nodo node_up = matrix_guia.get((int)actual.getX() - 1).get((int) actual.getY());
	        	if(node_up.getType() != 0) {
		        	if(node_up.getVisited() == 0 && (node_up.getG() > (actual.getG() + 1))) {
		        		node_up.setG(actual.getG() + 1);
		        		node_up.setPadre(actual);
			        	node_up.setOrder(0);
		        		no_visitados_2.add(node_up);
		        	}
	        	}
	        	
	        	Nodo node_down = matrix_guia.get((int)actual.getX() + 1).get((int) actual.getY());
	        	if(node_down.getType() != 0) {
		        	if(node_down.getVisited() == 0 && (node_down.getG() > (actual.getG() + 1))) {
		        		node_down.setG(actual.getG() + 1);
		        		node_down.setPadre(actual);
		        		node_down.setOrder(1);
		        		no_visitados_2.add(node_down);
		        	}
	        	}
	        	
	        	Nodo node_left = matrix_guia.get((int)actual.getX()).get((int) actual.getY() - 1);
	        	if(node_left.getType() != 0) {
		        	if(node_left.getVisited() == 0 && (node_left.getG() > (actual.getG() + 1))) {
		        		node_left.setG(actual.getG() + 1);
		        		node_left.setPadre(actual);
		        		node_left.setOrder(2);
		        		no_visitados_2.add(node_left);
		        	}
	        	}
	        	
	        	Nodo node_right = matrix_guia.get((int)actual.getX()).get((int) actual.getY() + 1);
	        	if(node_right.getType() != 0) {        	
		        	if(node_right.getVisited() == 0 && (node_right.getG() > (actual.getG() + 1))) {
		        		node_right.setG(actual.getG() + 1);
		        		node_right.setPadre(actual);
		        		node_right.setOrder(3);
		        		no_visitados_2.add(node_right);
		        	}
	        	}   		
	        }
     
		}
		

		this.indexPath -= 1;

		if(path.get(this.indexPath + 1) == 0) {
			return Types.ACTIONS.ACTION_UP;
		} else if(path.get(this.indexPath + 1) == 1) {
			return Types.ACTIONS.ACTION_DOWN;
		} else if(path.get(this.indexPath + 1) == 2) {
			return Types.ACTIONS.ACTION_LEFT;
		} else {
			return Types.ACTIONS.ACTION_RIGHT;
		}
		
		
		
        
	}
	
	/**
	 * Funcion para recuperar el camino desde el nodo portal hasta el inicio
	 * La representacion de las acciones  es 0,1,2,3 para UP,DOWN,LEFT,RIGHT respectivamente
	 * @param portal
	 * @return
	 */
	public ArrayList<Integer> recuperarCamino(Nodo portal) {
		

		Nodo current = portal;
		ArrayList<Integer> path = new ArrayList<Integer>();
		while(current.getPadre() != null) {
			
			if(current.getY() < matrix_guia.get((int)current.getPadre().getX()).get((int) current.getPadre().getY()).getY()) {
				path.add(2);
			} else if(current.getY() > matrix_guia.get((int)current.getPadre().getX()).get((int) current.getPadre().getY()).getY()) {
				path.add(3);
			} else if(current.getX() < matrix_guia.get((int)current.getPadre().getX()).get((int) current.getPadre().getY()).getX()) {
				path.add(0);
			} else if(current.getX() > matrix_guia.get((int)current.getPadre().getX()).get((int) current.getPadre().getY()).getX()) {
				path.add(1);
			}
			
			current = matrix_guia.get((int)current.getPadre().getX()).get((int) current.getPadre().getY());
			
		}
		
		return path;
	}
}



