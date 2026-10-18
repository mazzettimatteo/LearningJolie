from .greeter import GreeterInterface
from console import Console //importo la Console dalla stdlib

service Main {
	outputPort greeter {
		location: "socket://localhost:8000"
		protocol: sodep
		interfaces: GreeterInterface
	}

	embed Console as console //embed prende il nome di un servizio come parametro, in questo caso "Console", gli dà il nome "console"

	main {
		greet@greeter( { name = "Alice" } )( response )
		println@console( response.greeting )() //stampo il greeting che ho ricevuto
	}
}

/*
Trattiamo la console, che viene eseguita internamente nel nostro client service della nostra
implementazione, come se fosse un servizio esterno. 
O meglio, non distinguiamo fra servizi interni ed esterni nell'implementazione del nostro behavior.
Ciò facilità il refactor della microservice architecture.
Se un giorno decidessi che non voglio più stampare il messsaggrio ottenuto localmente 
ma voglio stamparlo in una location remota, basta cambiare il client come si vede nella dir remote-console
*/