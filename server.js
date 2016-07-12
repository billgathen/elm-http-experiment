//
// Run with: node server.js
//
var app         = require('http');
var querystring = require('querystring');
var urlParser   = require('url');
var port        = 8080;

var hello = { greeting: "Howdy" };

var rpt1  = { name: "Bill's Report 1", id: 1, active: true };
var rpt2  = { name: "Bill's Report 2", id: 2, active: true };
var rpt3  = { name: "Liam's Report 1", id: 3, active: true };
var rpt4  = { name: "Liam's Report 2", id: 4, active: false };
var reports = { reports: [ rpt1, rpt2, rpt3, rpt4 ] };

var user1 = { name: "Bill", id: 1, reports: [ rpt1, rpt2 ] };
var user2 = { name: "Liam", id: 2, reports: [ rpt3, rpt4 ] };
var users = { users: [ user1, user2 ] };

function respondWithJson(rsp, code, obj) {
  headers = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Origin, X-Requested-With, Content-Type, Accept",
    "Content-Type": "application/json"
  };

  rsp.writeHeader(code, headers);
  rsp.end(JSON.stringify(obj));
}

function urlNotFound(url) {
  return { error: "" + url + " is not found" };
};

function idNotFound(id) {
  return { error: "Id " + id + " is not found" };
};

function getRecord(dataset, id) {
  var idx = parseInt(id || -1) - 1;
  return dataset[idx] || idNotFound(id);
}

app.createServer(function(req,rsp) {
  var url = urlParser.parse(req.url);
  var path = url.pathname;
  var args = querystring.parse(url.query);

  if (path === '/favicon.ico') {
    rsp.writeHeader(404);
    rsp.end();
  } else {
    console.log(path, args);
    if (path === '/hello') {
      respondWithJson(rsp, 200, hello);
    } else if (path === '/reports') {
      respondWithJson(rsp, 200, reports);
    } else if (path.startsWith('/report')) {
      respondWithJson(rsp, 200, getRecord(reports.reports, args.id));
    } else if (path === '/users') {
      respondWithJson(rsp, 200, users);
    } else if (path.startsWith('/user')) {
      respondWithJson(rsp, 200, getRecord(users.users, args.id));
    } else {
      respondWithJson(rsp, 404, urlNotFound(path));
    }
  }
}).listen(port);

console.log("Listening on " + port);
