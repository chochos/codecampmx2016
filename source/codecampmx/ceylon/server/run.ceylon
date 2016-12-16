import java.lang {
    System
}
import ceylon.http.server {
    newServer,
    Endpoint,
    template,
    Options
}
import ceylon.io {
    SocketAddress
}
shared void run() {
    "You must specify a port through the server.port system property"
    assert(is Integer port = Integer.parse(System.getProperty("server.port", "8080")));
    value server = newServer {
        Endpoint {
            path = template("/followers/{uno}/{dos}");
            followers;
        },
        Endpoint {
            path = template("/friends/{uno}/{dos}");
            friends;
        },
        Endpoint {
            path = template("/conexiones/{uno}/{dos}");
            conns;
        }
    };
    server.startInBackground(SocketAddress("localhost", port),
        Options { sessionId = "codecampmx-ceylon"; });}
