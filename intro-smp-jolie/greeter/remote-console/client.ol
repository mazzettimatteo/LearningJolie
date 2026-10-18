from .greeter import GreeterInterface
from console import ConsoleIface //Qui importo solo l'interfaccia della console

service Main {

	outputPort greeter {
		location: "socket://localhost:8000"
		protocol: sodep
		interfaces: GreeterInterface
	}


	//piuttosto che fare l'embedding all'interno del mio servizio, creo una dependency(output) verso la porta 8001
	outputPort console {
		location: "socket://localhost:8001"
		protocol: sodep
		interfaces: ConsoleIface
	}

	main { //il main del mio servizio corrente non ha bisogno così di modifiche
		greet@greeter( { name = args[0] } )( response ) //Questa volta decidiamo di prendere il nome da salutare in input
		println@console( response.greeting )()
	}
}

/*
Lanciare in tre terminali diversi i tre codici:
jolie greeter.ol
jolie remote-console.ol
jolie client.ol <name_to_print>
*/