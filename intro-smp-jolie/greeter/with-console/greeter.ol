//Identico a greeter di simple

type GreetRequest { name: string }
type GreetResponse { greeting: string }

interface GreeterInterface {
RequestResponse:
	greet( GreetRequest )( GreetResponse )
}

service Greeter {
	execution: concurrent

	inputPort Input {
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