'use strict';

const http = require('http');
const util = require('util');

// Configure our HTTP server to respond with Hello World to all requests.
var server = http.createServer((request, response) => {
    console.log(request.headers);
    response.writeHead(200, {"Content-Type": "application/json"});
    response.end(util.inspect(request.headers));
});

server.listen(8000);
console.log("Server running at http://127.0.0.1:8000/");
