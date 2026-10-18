/*Jolie è CONTRACT FIRST, quindi si inizia a ragionare partendo dall'Interfaccia*/

type GreetRequest { name: string }
type GreetResponse { greeting: string }

interface GreeterInterface {
RequestResponse: //In questo caso l'operazione è di tipo RR
	greet( GreetRequest )( GreetResponse )
}

//Definiamo i servizi che implementano questa interfaccia
service Greeter {
	execution: concurrent //Appena arriva una richiesta, iniziamo a lavorarci in contemporanea alle altre richieste arrivate

	inputPort Input { //Definisco gli accesspoint
		location: "socket://localhost:8000" //Ci si accede con TCP/IP socket tramite questo URI
		protocol: sodep  //Protocollo che descirive come trasportiamo i dati, http andrebbe bene al posto di sodep
		interfaces: GreeterInterface //Dico quale API si può utilizzare usando questo access point
	}

	//In main c'è l'implementazione dell'interfaccia
	main {
		greet( request )( response ) { //Fra le graffe dico cosa succede fra il ricevimento della req e l'invio della ress
			response.greeting = "😀 Hello, " + request.name
		}
	}
}

/*
Per eseguire andare nella dir corrente con entrambi i terminali T1 e T2
poi si lancia il greeter service con:    jolie greeter.ol
In un secondo terminale T2 avvio il client:   jolie client.ol
(Se eseguo questo comando ottengo tutti gli step fatti fra req e res:   jolie --trace client.ol  )
*/