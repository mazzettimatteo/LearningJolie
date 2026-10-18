from database import Database

type User {
	username: string
	name: string
	email: string
	karma: int
}
type ListUsersRequest { minKarma?: int }
type ListUsersResponse { usernames*: string }
type GetUserRequest { username: string }

interface UsersInterface {
RequestResponse:
	listUsers( ListUsersRequest )( ListUsersResponse ),
	getUser( GetUserRequest )( User ) throws UserNotFound( string ),
	createUser( User )( void ) //Nuovo rispetto a in-memory
}

service Users {
	execution: concurrent
	
	inputPort Input {
		location: "socket://localhost:8080"
		protocol: http {
			format = "json"
			osc << {
				listUsers << {
					template = "/user"
					method = "get"
				}
				getUser << {
					template = "/user/{username}"
					method = "get"
					statusCodes.UserNotFound = 404
				}
				createUser << { //aggiunto per il nuovo metodo
					template = "/user/{username}"
					method = "post"
				}
			}
		}
		interfaces: UsersInterface
	}

	embed Database as db //Utilizzo il servizio della stdlib per connettermi al db

	init {
		connect@db( { //metodo di init per connettersi al db
			driver = "hsqldb_embedded"
			database = "db/users;sql.lowercase_ident=true"
			username = "jolie"
			password = "hs"
			host = ""
		} )()
	}

	main { //Le funzioni adesso utilizzano queries SQL
		[ createUser( request )() { 
			//Jolie offre anche un metodo per per proteggere il proprio servizio da SQL injections: 
			//invece che mettere i valori in maniera hardcoded si mettono con i :value e po si passano come children
			update@db( "INSERT INTO users(username, name, email, karma) VALUES(:username, :name, :email, :karma)" {
				username = request.username
				name = request.name
				email = request.email
				karma = request.karma
			} )() //Questo servizio è stateless
		} ]

		[ getUser( request )( response ) {
			query@db( "SELECT username, name, email, karma FROM users WHERE username=:username" {
				username = request.username
			} )( result )
			if( #result.row == 0 ) {
				throw( UserNotFound, "Could not find username " + request.username )
			}
			response << result.row[0]
		} ]

		[ listUsers( request )( response ) {
			query@db( "SELECT username FROM users WHERE karma >= :minKarma" {
				minKarma = request.minKarma
			} )( result )
			i = 0
			for( row in result.row ) {
				response.usernames[i++] = row.username
			}
		} ]
	}
}

/*Per eseguire fare in ordine:
./setup.sh          (potrebbe necessitare dei permessi di esecuzione:     chmod +x setup.sh    )
jolie main.ol
./demo.sh           (potrebbe necessitare dei permessi di esecuzione:     chmod +x demo.sh    )   
**NB** dopo ogni step della demo il CSV del db si aggiorna


*/