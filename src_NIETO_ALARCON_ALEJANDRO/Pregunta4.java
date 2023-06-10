package tracks.singlePlayer.evaluacion.src_NIETO_ALARCON_ALEJANDRO;

import java.io.File;

import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Random;
import java.util.Scanner;

import tools.Utils;
import tracks.ArcadeMachine;
import java.io.BufferedReader;
public class Pregunta4 {
	
	// *********************** RUTAS PARA WINDOWS *****************************
	private static String partialMapRoute = ".\\examples\\gridphysics\\";
	//private static String partialSaveDataRoute = ".\\src\\tracks\\singlePlayer\\evaluacion\\src_NIETO_ALARCON_ALEJANDRO\\";
	private static String partialRoute = ".\\src\\tracks\\singlePlayer\\evaluacion\\src_NIETO_ALARCON_ALEJANDRO\\";
	
	// *********************** RUTAS PARA LINUX *****************************
	//private static String partialMapRoute = "./examples/gridphysics/";
	//private static String partialRoute = "./src/tracks/singlePlayer/evaluacion/src_NIETO_ALARCON_ALEJANDRO/";

    public static void main(String[] args) throws IOException {
  
    	String fileName = partialMapRoute + "labyrinth_lvl6.txt";
    	String fileNameSave = partialMapRoute + "labyrinth_lvl11.txt";
    	
    	//Leemos el mapa que vamos a modificar y lo traemos como una matriz sin un avatar
    	//en una posicion concreta
    	ArrayList<String> mapa = loadMap(fileName);

		String spGamesCollection =  "examples/all_games_sp.csv";
		String[][] games = Utils.readGames(spGamesCollection);

		boolean visuals = true;
		int seed = new Random().nextInt();
		
		//Cargamos el nivel 11 porque lo hemos llamado asi donde guardaremos el fichero
		//del mapa que modifiquemos
		int gameIdx = 58; 
		int levelIdx = 11; 
		String gameName = games[gameIdx][1];
		String game = games[gameIdx][0];
		String level1 = game.replace(gameName, gameName + "_lvl" + levelIdx);

		String recordActionsFile = null;
				
		String myController2 = "tracks.singlePlayer.evaluacion.src_NIETO_ALARCON_ALEJANDRO.AStarAgent";
		String myController3 = "tracks.singlePlayer.evaluacion.src_NIETO_ALARCON_ALEJANDRO.RTAStar";
		String myController4 = "tracks.singlePlayer.evaluacion.src_NIETO_ALARCON_ALEJANDRO.LRTAStar";
		
		//Variables staticas de los controladores que nos serviran para saber cuando guardar
		//los datos
		LRTAStar.fileName = partialRoute + "HeuristicasLRTA.txt";
		LRTAStar.saveH = true;
		
		RTAStar.fileName = partialRoute + "HeuristicasRTA.txt";
		RTAStar.saveH = true;
		
		AStarAgent.fileName = partialRoute + "HeuristicasA.txt";
		AStarAgent.saveH = true;
		
		//Ejecutamos 
		for(int i = 0; i < 3; i++){
			//Cogemos el mapa cargado anteriormente le ponemos una posicion nueva y lo guardamos
			modifyAndSave(mapa, fileNameSave);
			ArcadeMachine.runOneGame(game, level1, visuals, myController2, recordActionsFile, seed, 0);
			ArcadeMachine.runOneGame(game, level1, visuals, myController3, recordActionsFile, seed, 0);
			ArcadeMachine.runOneGame(game, level1, visuals, myController4, recordActionsFile, seed, 0);
		}		
		
		//Borramos el mapa 11 creado con anterioridad
		File myObj = new File(fileNameSave); 
		myObj.delete();
    	
		//Ejecutamos el script de python para generar los heatmaps
		executePythonHeatMaps();
    	 
    }
    
    /**
     * A traves de una ruta leemos un fichero mapa al cual le sustituimos
     * la posicion actual del avatar por una posicion normal y asi ya podemos escoger
     * donde poner al jugador aleatoriamente
     * @param fileName
     * @return
     * @throws FileNotFoundException
     */
    public static ArrayList<String> loadMap(String fileName) throws FileNotFoundException{
    	File myObj	 = new File(fileName);
    	ArrayList<String> mapa = new ArrayList<String>();
        if (myObj.exists()) {
            Scanner myReader = new Scanner(myObj);
            if(myReader.hasNextLine() != false) {
            	while (myReader.hasNextLine()) {
                    mapa.add(myReader.nextLine());                    
                 }
        	}
        	
        	myReader.close();     
        }
        
        return mapa;
    }
    
    /**
     * LLama a un script de python que leera los archivos donde hemos guardado los valores heuristicos
     * y genera el mapa de calor
     */
    public static void executePythonHeatMaps() {
    	String[] cmd = {
  		      "python",
  		    partialRoute + "scriptGeneraHeatmaps..py"
  		    };

	  	 String s = null;
	
	       try {
	           
	       
	           Process p = Runtime.getRuntime().exec(cmd);
	           
	           BufferedReader stdInput = new BufferedReader(new 
	                InputStreamReader(p.getInputStream()));
	
	           BufferedReader stdError = new BufferedReader(new 
	                InputStreamReader(p.getErrorStream()));
	
	          
	           while ((s = stdInput.readLine()) != null) {
	               System.out.println(s);
	           }
	           
	          
	           while ((s = stdError.readLine()) != null) {
	               System.out.println(s);
	           }
	           
	           System.exit(0);
	       }
	       catch (IOException e) {
	          
	           e.printStackTrace();
	           System.exit(-1);
	       }
    }
    
    /**
     * Dado un mapa escogemos una posicion aleatoria donde color el avatar
     * y guardamos el fichero para que pueda ser cargado
     * @param mapa
     * @param fileNameSave
     */
    public static void modifyAndSave(ArrayList<String> mapa, String fileNameSave) {
    	
    	//Copiamos el mapa original en otro que será el que guardemos
    	//para no modificar el original
    	ArrayList<String> mapaF = new ArrayList<String>();

        for(int i = 0; i < mapa.size(); i++) {
        	if(mapa.get(i).indexOf('A') != -1) {
        		char[] arr = mapa.get(i).toCharArray();
        		arr[mapa.get(i).indexOf('A')] = '.';
        		mapaF.add(String.valueOf(arr));
        		
        	} else {	
        		mapaF.add(mapa.get(i));
        	}
        	
        }
        
  
        //Escogemos una posicion aleatoria donde 
        //pondremos al avatar
        Random r = new Random();
        int randx = 0;
        int randy = 0;
        while(mapaF.get(randx).charAt(randy) != '.' ) {
        	randx = r.nextInt(mapaF.size());
         	randy = r.nextInt(mapaF.get(0).length());
        }
        
        char[] arr = mapaF.get(randx).toCharArray();
		arr[randy] = 'A';
		mapaF.remove(randx);
		mapaF.add(randx, String.valueOf(arr));
		
		//Guardamos el nuevo mapa en un fichero
		 try {
	      FileWriter myWriter = new FileWriter(fileNameSave);
	      for (int i = 0; i < mapaF.size(); i++) {
         	myWriter.write(mapaF.get(i));
         	myWriter.write("\n");
	      }
	      myWriter.close();
	    } catch (IOException e) {
	      e.printStackTrace();
	    }
    }

}
