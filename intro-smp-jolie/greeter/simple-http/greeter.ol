type GreetRequest { name: string }
type GreetResponse { greeting: string }

interface GreeterInterface {
RequestResponse:
	greet( GreetRequest )( GreetResponse )
}

service Greeter {
	execution: concurrent

	inputPort Input {
		location: "socket://localhost:8080" //Ho scelto di usare http, cambiamo la porta a 8080
		protocol: http { format = "json" } //Voglio la response in json, o anche xml va bene
		interfaces: GreeterInterface
	}

	/*a differenza di java, javascript, ecc. Jolie fornisce un abstract data format per lavorare con i dati,
	così da dire separatamente come dovrà essere encoded o decoded, così che se si cambia idea non bisognerà cambiare la logica delle funzioni che operano sui dati (separation of concerns)  
	Si possono anche usare più formati in contemporanea: usiamo adesso anche il protocollo binario sodep*/
	inputPort SodepInput {
		location: "socket://localhost:8000" 
		protocol: sodep  
		interfaces: GreeterInterface
	}


	main {
		greet( request )( response ) {
			response.greeting = "😀 Hello, " + request.name 
		}
	}
}

/*
In due terminali diversi lanciare 
jolie greeter.ol
./demo.sh
*/