package tracks.singlePlayer.evaluacion.src_NIETO_ALARCON_ALEJANDRO;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;


import java.util.Collections;
import java.util.Comparator;
import java.util.Scanner;

import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import ontology.Types.ACTIONS;
import tools.ElapsedCpuTimer;
import tools.Vector2d;

//Clase que usaremos como comparator para ordenar nuestra lista de nodos abiertos
class SortNodeF implements Comparator<Nodo>
{
    public int compare(Nodo a, Nodo b)
    {
    	return a.getF() < b.getF() ? 1 : a.getF() > b.getF() ? -1 :  a.getG() < b.getG() ? 1 : a.getG() > b.getG() ? -1 : a.getOrder() < b.getOrder() ? 1 : -1  ;
    }
}


public class AStarAgent  extends AbstractPlayer{

	static public String fileName;
	static public boolean saveH = false;

	Vector2d fescala;
	Vector2d portal;
	ArrayList<Nodo> abiertos;
	ArrayList<ArrayList<Nodo>> matrix_guia;
	Vector2d avatar;
	ArrayList<String> path;
	
	boolean pathCalculated = false;
	private int nodosExpandidos = 0;
	
	/**
	 * initialize all variables for the agent
	 * @param stateObs Observation of the current state.
     * @param elapsedTimer Timer when the action returned is due.
	 * @throws FileNotFoundException 
	 */
	public AStarAgent(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) throws FileNotFoundException{
		//Calculamos el factor de escala entre mundos (pixeles -> grid)
        fescala = new Vector2d(stateObs.getWorldDimension().width / stateObs.getObservationGrid().length , 
        		stateObs.getWorldDimension().height / stateObs.getObservationGrid()[0].length);      
      
        //Se crea una lista de observaciones de portales, ordenada por cercania al avatar
        ArrayList<Observation>[] posiciones = stateObs.getPortalsPositions(stateObs.getAvatarPosition());
        //Seleccionamos el portal mas proximo
        portal = posiciones[0].get(0).position;
        portal.x = Math.floor(portal.x / fescala.x);
        portal.y = Math.floor(portal.y / fescala.y);
        
        //Obtenemos la posicion del avatar
        avatar =  new Vector2d(stateObs.getAvatarPosition().x / fescala.x, 
        		stateObs.getAvatarPosition().y / fescala.y);
        
        //Obtenemos la posicion de muros y trampas en el mapa
        ArrayList<Observation>[] posiciones_muros = stateObs.getImmovablePositions();

        //Será nuestra matriz que hará de representación del mapa y contendrá los nodos en su interior
        //por cada casilla
        matrix_guia = new ArrayList<ArrayList<Nodo>>();
        
        //Será el vector donde se encuentren los nodos que esten en abiertos.
        abiertos = new ArrayList<Nodo>();
        
        //Añadimos a nuestra matriz nodos cada una de las posiciones con sus caracteristicas
        //por defecto le ponemos a todas una G de 9999 para que al ordenar
        //no se encuentren al principio
        //parametro visitado  0  = no visitado y no pendiente de visitar 1 = esta en abiertos 2 = esta en cerrados
        //parametro type 0 = muro/trampa 1 = casilla visitable
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
        
        
        //Ponemos a cada nodo si es de tipo muro o trampa poniendole el tipo a 0
        for (int i = 0; i < posiciones_muros[0].size(); i++) {
        	Vector2d muro = posiciones_muros[0].get(i).position;
        	muro.x = Math.floor(muro.x / fescala.x);
        	muro.y = Math.floor(muro.y / fescala.y);
        	matrix_guia.get((int) muro.y).get((int)muro.x).setType(0);
        	matrix_guia.get((int) muro.y).get((int)muro.x).setH(-1);
        }
        
        
        for (int i = 0; i < posiciones_muros[1].size(); i++) {
        	Vector2d muro = posiciones_muros[1].get(i).position;
        	muro.x = Math.floor(muro.x / fescala.x);
        	muro.y = Math.floor(muro.y / fescala.y);
        	matrix_guia.get((int) muro.y).get((int)muro.x).setType(0);
        	matrix_guia.get((int) muro.y).get((int)muro.x).setH(-1);
        }
        
        //Miramos si queremos guardar la matriz de heuristicas
        //si existe la leemos para despues ponersela a nuestros nodos
        //si no existe no la leemos y la crearemos mas adelante (esto solo pasa
        //en la primera iteración esto servirá para la pregunta4
        ArrayList<ArrayList<String>> matrixHeur = new ArrayList<ArrayList<String>>();
        if(saveH) {
        	File myObj = new File(fileName);
            if (myObj.exists()) {
                Scanner myReader = new Scanner(myObj);
                if(myReader.hasNextLine() != false) {
	            	while (myReader.hasNextLine()) {
	                    String data = myReader.nextLine();
	                    String [] splitValues = data.split(" ");
	                    
	                    ArrayList<String> row2 = new ArrayList<String>();
	                    for(int i = 0; i < splitValues.length; i++) {
	                    	row2.add(splitValues[i]);
	                    }
	                    	
	                    matrixHeur.add(row2);
	                 }
	            	
	            	for (int i = 0; i < matrix_guia.size(); i++) {
	                	for(int j = 0; j < matrix_guia.get(0).size(); j++) {
	                		matrix_guia.get(i).get(j).setH(Double.valueOf( matrixHeur.get(i).get(j)));
	                	}                	
	                }
            	}
            	
            	myReader.close();    
            } 
        }
        
        

        //Inicializamos por defecto el primer nodo que es el de
        //la posicion actual del avatar le ponemos visitado 1 lo
        //añadimos a la lista de nodos abiertos y  ponemos el padre a null
        matrix_guia.get((int) avatar.y).get((int) avatar.x).setVisited(1);
        matrix_guia.get((int) avatar.y).get((int)avatar.x).setPadre(null);
        abiertos.add(matrix_guia.get((int) avatar.y).get((int) avatar.x));
        
        
        
        
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
		
		long tInicio = System.nanoTime();
		
		if (!this.pathCalculated) {

	        while (true) {
	        	
	        	//Ordenamos la lista de nodos abiertos
	        	Collections.sort(this.abiertos, new SortNodeF());
	  
	        	//Obtenemos nodo con menor F
	        	Nodo actual = this.abiertos.get(this.abiertos.size() -1);	 
	        	this.nodosExpandidos += 1;

	        	//Comprobamos que el nodo actual sea la meta
	        	if(actual.getX() == portal.y && actual.getY() == portal.x) {
	        		long tFin = System.nanoTime();
	        		long tiempoTotalms = (tFin - tInicio)/1000000;
	        		
	        		this.pathCalculated = true;
	        		
	        		//Recuperamos el camino
	        		path = this.recuperarCamino(actual);
	        		
	        		//Guardamos en un fichero el valor de las heuristicas una 
	        		//vez llegado a la meta (sirve para la pregunta 4)
	        		if(saveH) {
	            		try {
	        		      FileWriter myWriter = new FileWriter(fileName);
	        		      for (int i = 0; i < matrix_guia.size(); i++) {
	                      	for(int j = 0; j < matrix_guia.get(0).size(); j++) {
	                      		myWriter.write(matrix_guia.get(i).get(j).getH() + " ");
	                      	}
	                      	myWriter.write("\n");
	                      }
	        		      myWriter.close();
	        		    } catch (IOException e) {
	        		      e.printStackTrace();
	        		    }
	            	}
	        		

	        		
	        		System.out.println("A* Runtime -- " + tiempoTotalms + "ms " + "Path size -- " + this.path.size() + " Nodos expandidos -- " + this.nodosExpandidos);


	        		
	        		break;
	        	}
	        	
	        	//Borramos de la lista de abiertos el nodo actual
	        	this.abiertos.remove(this.abiertos.size() -1);
	        	//Lo ponemos el valor de visitado a 2 y pasa a ser un
	        	//nodo que pertenece a la lista de nodos cerrados
	        	actual.setVisited(2);	
	        	
	        	//Implementacion del pseudocodigo del algoritmo A*
	        	//Obtenemos una copia del nodo vecino actual de arriba y comprobamos 
	        	//comprobamos que no sea un muro
	        	//Le ponemos su nueva G que es la del nodo actual +1 y hacemos las comprobaciones
	        	//para no modificar el real si es que es peor modificamos la copia
	        	//y si es mejor si que modificamos el original
	        	//Hacemos lo mismo para todos los vecinos posibles (UP,DOWN,LEFT,RIGHT)
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
	
	/**
	 * Funcion para recuperar el camino desde el nodo portal hasta el inicio
	 * La representacion de las acciones  es 0,1,2,3 para UP,DOWN,LEFT,RIGHT respectivamente
	 * @param portal
	 * @return
	 */
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
	
	/**
	 * Calcula la distancia heuristica desde el nodo actual al portal mediante la distancia manhattan
	 * @param portal
	 * @param actual
	 * @return
	 */
	public int distanceToGoal(Vector2d portal, Nodo actual) {
		int x_value = (int) Math.abs((portal.y - actual.getX()));
		int y_value = (int) Math.abs((portal.x - actual.getY()));
		return x_value + y_value;
	}
}



