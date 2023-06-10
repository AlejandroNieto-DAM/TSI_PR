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
import java.io.File;  // Import the File class
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Scanner; // Import the Scanner class to read text files

class SortNodeRTA implements Comparator<Nodo>
{
    // Used for sorting in ascending order of
    // roll number
    public int compare(Nodo a, Nodo b)
    {
    	return a.getF() < b.getF() ? -1 : a.getF() > b.getF() ? 1 :  a.getG() < b.getG() ? -1 : a.getG() > b.getG() ? 1 : a.getOrder() < b.getOrder() ? -1 : 1  ;
    }
}


public class RTAStar  extends AbstractPlayer{
	
	static public String fileName;
	static public boolean saveH = false;

	Vector2d fescala;
	Vector2d portal;
	ArrayList<ArrayList<Nodo>> matrix_guia;
	Vector2d avatar;
	long tiempoTotalms;
	private int nodosExpandidos = 0;
	
	/**
	 * initialize all variables for the agent
	 * @param stateObs Observation of the current state.
     * @param elapsedTimer Timer when the action returned is due.
	 * @throws FileNotFoundException 
	 */
	public RTAStar(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) throws FileNotFoundException{
		//Calculamos el factor de escala entre mundos (pixeles -> grid)
        fescala = new Vector2d(stateObs.getWorldDimension().width / stateObs.getObservationGrid().length , 
        		stateObs.getWorldDimension().height / stateObs.getObservationGrid()[0].length);      
      
        //Se crea una lista de observaciones de portales, ordenada por cercania al avatar
        ArrayList<Observation>[] posiciones = stateObs.getPortalsPositions(stateObs.getAvatarPosition());
        //Seleccionamos el portal mas proximo
        portal = posiciones[0].get(0).position;
        portal.x = Math.floor(portal.x / fescala.x);
        portal.y = Math.floor(portal.y / fescala.y);
        
      
        matrix_guia = new ArrayList<ArrayList<Nodo>>();

      
        for (int i = 0; i < stateObs.getObservationGrid()[0].length; i++) {
        	ArrayList<Nodo> row = new ArrayList<Nodo>();
        	for(int j = 0; j < stateObs.getObservationGrid().length; j++) {
        		Nodo node = new Nodo(i, j, 0, 0);
        		node.setH(this.distanceToGoal(portal, node));
        		node.setType(1);
        		row.add(node);
        	}
        	matrix_guia.add(row);
        	
        }
        
        
        //Miramos si queremos guardar la matriz de heuristicas
        //si existe la leemos para despues ponersela a nuestros nodos
        //si no existe no la leemos y la crearemos mas adelante (esto solo pasa
        //en la primera iteración
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
        
        
        
        
        
        
             
        
        
	}
	
	/**
	 * return the best action to arrive faster to the closest portal
	 * @param stateObs Observation of the current state.
     * @param elapsedTimer Timer when the action returned is due.
	 * @return best	ACTION to arrive faster to the closest portal
	 */
	@Override
	public ACTIONS act(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {
		
		long tInicio = System.nanoTime();
		
		//Rellenamos nuestra matriz con los muros o trampas que puedan aparecer en cada iteración
		//debido a que no sabemos si hemos pisado una placa que nos desvela parte del mapa
        ArrayList<Observation>[] posiciones_muros = stateObs.getImmovablePositions();
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
        
		
        //Posicion del avatar
		avatar =  new Vector2d(stateObs.getAvatarPosition().x / fescala.x, 
        		stateObs.getAvatarPosition().y / fescala.y);
		
		//Obtenemos el nodo en el que estamos actualmente
		Nodo actual = matrix_guia.get((int) avatar.y).get((int)avatar.x);
		this.nodosExpandidos += 1;
		
		//Lista a la que añadiremos los vecinos para ordenarlos y asi saber cual escoger (para RTA el segundo mejor)
		ArrayList<Nodo> vecinos = new ArrayList<Nodo>();
		
		//Hacemos las operaciones con los vecinos pertinentes obteniendo 
		//de la matriz el puntero de cada uno y actualizando sus valores
		
    	Nodo node_up = matrix_guia.get((int)actual.getX() - 1).get((int) actual.getY()).getCopy();
    	if(node_up.getType() != 0) {
    		node_up.setG(actual.getG() + 1);
    		node_up.setOrder(0);
    		vecinos.add(node_up);
    	}
    	
    	Nodo node_down = matrix_guia.get((int)actual.getX() + 1).get((int) actual.getY()).getCopy();
    	if(node_down.getType() != 0) {
    		node_down.setG(actual.getG() + 1);
    		node_down.setOrder(1);
    		vecinos.add(node_down);
    	}
    	
    	Nodo node_left = matrix_guia.get((int)actual.getX()).get((int) actual.getY()-1).getCopy();
    	if(node_left.getType() != 0) {
    		node_left.setG(actual.getG() + 1);
    		node_left.setOrder(2);
    		vecinos.add(node_left);
    	}
    	
    	Nodo node_right = matrix_guia.get((int)actual.getX()).get((int) actual.getY()+1).getCopy();
    	if(node_right.getType() != 0) {
    		node_right.setG(actual.getG() + 1);
    		node_right.setOrder(3);
    		vecinos.add(node_right);
    	}
    	
    	Collections.sort(vecinos, new SortNodeRTA());

    	//Comprobamos que no solo haya un vecino al que podamos movermos (por ejemplo quedarnos en una posicion donde la salida solo esta en un sentido)
    	//ya que de esta manera solo habria un vecino posible y actualizamos la heuristica con el segundo mejor
    	if(vecinos.size() >= 2) {
			actual.setH(Math.max(actual.getH(), vecinos.get(1).getF()));
		} else {
			actual.setH(Math.max(actual.getH(), vecinos.get(0).getF()));
		}
    	
     	long tFin = System.nanoTime();
    	this.tiempoTotalms += (tFin - tInicio)/1000000;
    	
    	//Aqui comprobamos que cuando nos vayamos a mover a la meta hacemos el output
    	//y si tenemos que guardar la matriz de heuristicas escribimos el fichero
    	if(vecinos.get(0).getX() == portal.y && vecinos.get(0).getY() == portal.x) {
    		System.out.println("RTA* Runtime -- " + tiempoTotalms + "ms " + " Nodos expandidos -- " + this.nodosExpandidos);
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

    	}
    		
    	//Nos movemos al mejor vecino viendo en que posicion esta respecto de nosotros y asi sabemos el movimiento que debemos de hacer
    	if(actual.getY() < vecinos.get(0).getY()) {
    		return Types.ACTIONS.ACTION_RIGHT;
		} else if(actual.getY() > vecinos.get(0).getY()) {
			return Types.ACTIONS.ACTION_LEFT;
		} else if(actual.getX() < vecinos.get(0).getX()) {
			return Types.ACTIONS.ACTION_DOWN;
		}

    	return Types.ACTIONS.ACTION_UP;

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



