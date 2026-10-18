type User {
	username: string
	name: string
	email: string
	karma: int
}
type ListUsersRequest { minKarma?: int } //? indica che è un param opzionale
type ListUsersResponse { usernames*: string } //* indica che è variadica
type GetUserRequest { username: string }

interface UsersInterface {
RequestResponse:
	listUsers( ListUsersRequest )( ListUsersResponse ), //ritorna lista di stringhe username con almeno minKarma
	getUser( GetUserRequest )( User ) throws UserNotFound( string ) //getter per le info di user, come si vede dalla def. dei tipi l'argomento è una string
}

service App {
	execution: concurrent
    
	inputPort Web { 
		location: "socket://localhost:8080"
		protocol: http { //Implemento un servizio REST
			format = "json"
			osc << {
				listUsers << { //se accedo a /user con il metodo GEt, allora sto facendo una chiamata a listUsers 
					template = "/user"
					method = "get"
				}
				getUser << {
					template = "/user/{username}"
					method = "get"
					statusCodes.UserNotFound = 404
				}
			}
		}
		interfaces: UsersInterface
	}

	init { //Codice da runnare quando il servizio parte (seeding)
		users << { //nella datastruct user faccio una deepcopy(<<) del data-tree che specifico sulla destra
			alice << {
				name = "Alice Apple"
				email = "alice@jolie-lang.org"
				karma = 4
			}
			bob << {
				name = "Bob Banana"
				email = "bob@jolie-lang.org"
				karma = 6
			}
			carol << {
				name = "Carol Cantaloupe"
				email = "carol@jolie-lang.org"
				karma = 3
			}
		}
	}
    
	main { //Utiliuzzo le parentesi quadre per dire che questo servizio accetta invocazio sia su getUser che su listUsers, in pi-calcolo è detta input-choice 
		[ getUser( request )( resulting_user ) {
			username = request.username
			if( is_defined( users.(username) ) ) {   //la sintassi dict.(key) fa si che users di comporti come dizionario, è essenzialmente uguale a users[username]
				resulting_user << users.(username)
				resulting_user.username = username
			} else {
				throw( UserNotFound, username ) //Lancio un fault (molto simile ad un exception)
			}
		} ]

		[ listUsers( request )( response ) {
			i = 0
			foreach( username : users ) { //scansiono tutti gli user che sono sottonodi di users
				user << users.(username)
				if( !( is_defined( request.minKarma ) && user.karma < request.minKarma ) ) {
					response.usernames[i++] = username
				}
			}
		} ]
	}
}

/*Per eseguire: jolie main.ol*/