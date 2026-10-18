from ...greeter.by-username import GreeterInterface
from ...users.with-db-sodep import UsersInterface

type Authorization {
	apiKey: string
}

interface extender AuthorizationExtender { //mi permette di aggiungere un API-key/token a tutti i messaggi usati per la creazione di utenti
RequestResponse:
	//specifica che quando arriva una call da createUser vogliamo aggiungere come feat la Auth, e il possibile nuovo fault
	createUser( Authorization )( void ) throws Unauthorized( void )
}

service Gateway {
	outputPort greeter {
		location: "socket://localhost:8000"
		protocol: sodep
		interfaces: GreeterInterface
	}

	outputPort users {
		location: "socket://localhost:8001"
		protocol: sodep
		interfaces: UsersInterface
	}

	inputPort WebInput {
		location: "socket://localhost:8080"
		protocol: http {
			format = "json"
			osc << {
				greet << {
					template = "/greeting/{username}"
					method = "get"
				}
				listUsers << {
					template = "/user"
					method = "get"
				}
				getUser << {
					template = "/user/{username}"
					method = "get"
					statusCodes.UserNotFound = 404
				}
				createUser << {
					template = "/user/{username}"
					method = "post"
					inHeaders.Authorization = "apiKey"
					statusCodes.Unauthorized = 401
				}
			}
		}
		aggregates:
			greeter,
			users with AuthorizationExtender //utilizzo un interface extender 
	}


	//con courier viene eseguito a ogni invio di messaggio
	courier WebInput { //all'access point WebInput, quando arria una call createUser esegui il seguente codice
		[ createUser( request )( response ) {
			if( request.apiKey != "Bearer 123" ) {
				throw( Unauthorized )
			}
			forward( request )( response ) //primitiva che rimuove i dati che abbiamo usato in "locale" per estendere l'API
		} ]
	}

	main {
		linkIn( Exit )
	}
}