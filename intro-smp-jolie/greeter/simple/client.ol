from .greeter import GreeterInterface //importo l'interfaccia del servizio che voglio usare

service Main { //Scrivo un servizio per implementare il client, perchè in Jolie tutti i components sono servizi, un client è un servizio che non offre niente al resto del sistema, chiede solo
	outputPort greeter { //Duale dell'inputport, non esprime un accesspoint ma una dependency
		location: "socket://localhost:8000" //Contatterò l'API che mi interessa a questo URI
		protocol: sodep //Con questo protocollo
		interfaces: GreeterInterface //E mi aspetto di usare questa interfaccia
	}

	main {
		greet@greeter( { name = "Matteo" } )( response ) //nomeOperazione@serviceProvider({payload})(response)
	}
}

/*
Per eseguire andare nella dir corrente con entrambi i terminali T1 e T2
poi si lancia il greeter service con:    jolie greeter.ol
In un secondo terminale T2 avvio il client:   jolie client.ol
(Se eseguo questo comando ottengo tutti gli step fatti fra req e res:   jolie --trace client.ol  )
*/