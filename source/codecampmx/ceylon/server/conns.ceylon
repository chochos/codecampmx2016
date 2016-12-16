import ceylon.http.server {
    Request,
    Response
}
import codecampmx.ceylon.core {
    twitter,
    commonFollowers,
    commondFriends,
    fetchFollowers,
    Usuario
}
import guru.nidi.graphviz.model {
    Factory
}
import guru.nidi.graphviz.engine {
    Graphviz
}
import java.io { JFile=File }
import ceylon.http.common {
    contentType
}
import ceylon.file {
    File,
    parsePath
}
import ceylon.io {
    newOpenFile,
    OpenFile
}

import java.util.concurrent { CompletableFuture }

void conns(Request req, Response resp) {
    if (exists uno = req.pathParameter("uno"),
        exists dos = req.pathParameter("dos")) {
        print("Buscando a ``uno`` y ``dos``");
        if (exists u1 = twitter.findUser(uno),
            exists u2 = twitter.findUser(dos)) {
            value usuarios=commondFriends(u1, u2, commonFollowers(u1, u2));
            value file = createAsyncGraphFile(u1,u2,usuarios);

            resp.addHeader(contentType("image/png"));
            resp.transferFile(file.get());
        } else {
            error(resp, "Al menos uno de los usuarios no existe.");
        }
    } else {
        error(resp, "Debes indicar dos usuarios de twitter.");
    }


}

OpenFile graphFile(Usuario uno, Usuario dos,[Usuario*] usuarios){
    value g=Factory.graph("``uno``-``dos``").directed();
    for (u in usuarios) {
        fetchFollowers(u);
    }
    for (u in usuarios) {
        for (f in u.followers) {
            if (f!= u && f in usuarios) {
                value n1 = Factory.node(f.username);
                if (f.follows(u)) {
                    print("``f`` sigue a ``u``");
                    g.node(n1.link(Factory.node(u.username)));
                } else {
                    g.node(n1);
                }
            }
        }
    }
    value output = JFile("/tmp/caca.png");
    output.delete();
    Graphviz.fromGraph(g).renderToFile(output);
    return newOpenFile(parsePath(output.absolutePath).resource);
}

CompletableFuture<OpenFile> createAsyncGraphFile(Usuario uno, Usuario dos, [Usuario*] usuarios) {
    return CompletableFuture.supplyAsync(() => graphFile(uno,dos,usuarios));
}
