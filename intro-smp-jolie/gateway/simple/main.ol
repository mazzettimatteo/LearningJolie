from ...greeter.by-username import GreeterInterface
from ...users.with-db-sodep import UsersInterface

//Il gateway fornisce ai client un'API tramite http, mentre comunica poi con il backend usando sodep
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
				greet << { //greet è implementata in greeter/by-username
					template = "/greeting/{username}"
					method = "get"
				}
				listUsers << { //implementata in users/with-db-sodep, come anche le prossime due
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
				}
			}
		}
		aggregates: greeter, users //quando arriva una chiamata da un client a WebInput ed è per greeter oppure users(che sono le due output port prima definite), la chiamata viene inviata automaticamente
	}

	main { //non c'è implementazione perché il gateway fa solo forwarding
		linkIn( Exit ) //aspetta un interrupt per uscire
	}
}

/*
Lancia il db-with-sodep della dir users(sia il setup-db che il main)
Spostati in greeter/by-username e lancia il main
Ora lancia questo gateway
In un quarto terminale sempre in gateway/simple fai partire demo.sholie@c7a4d3b0a0cd:/workspaces/LearningJolie/intro-smp-jolie/gateway/simple$ chmod +X demo.sh 
jolie@c7a4d3b0a0cd:/workspaces/LearningJolie/intro-smp-jolie/gateway/simple$ ./demo.sh
bash: ./demo.sh: Permission denied
*/