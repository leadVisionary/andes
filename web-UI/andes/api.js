dojo.provide("andes.api");
dojo.require("andes.rpc");
dojo.require("andes.error");


(function(){

	var startTime = null,
	    requestInFlight = false,
	    queue = [],
	    tries = 0;

	var MAX_RETRIES = 5,
	    RETRY_TIMEOUT = 2000; // milliseconds

	// AOP-style function replacement that performs before-advice
	// to add to the headers on all XHR requests. See dojox/rpc/Client.js
	(function(){
		console.info("api set headers", andes.sessionId)
		andes._originalXhr = dojo.xhr;
		dojo.xhr = function(method,args){
			var headers = args.headers = args.headers || {};
			headers["Client-Id"] = andes.sessionId;
			return andes._originalXhr.apply(dojo,arguments);
		};
	})();

	function prepRequest(req){
		// add common elements to our requests
		var tm = ((new Date()).getTime() - (startTime || (new Date()).getTime()))/1000.0;
		return dojo.mixin({ time:tm }, req || {});
	}

	function sendRequest(req){
		// send an RPC request
		var request = prepRequest(req.params);
		requestInFlight = true;
		andes.rpc[req.method](request).addCallbacks(
			function(result){
				requestInFlight = false;
				if(result[0] && result[0].action!="log" && result[0].error || result[0].errorType){
					req.dfd.errback(result[0]);
					andes.error({
						title: "General Error",
						message: "<p>The server reported an error:</p><pre>" + result[0].error + "</pre>",
						errorType: andes.error.OK
					});
					// FIXME: Not calling nextRequest() here means we freeze
					//        processing the queue and don't start up again.
					//        What *is* the correct behavior?
				}else{
					console.warn("CALLBACK!")
					console.dir(result);
					req.dfd.callback(result);
					nextRequest();
				}
			},
			function(error){
				//requestInFlight = false;
				if(error._rpcErrorObject){
					req.dfd.errback(error);
					var msg = "<p>The server reported an error:</p><pre>" + error.name + ": " + error.message;
					if(error._rpcErrorObject.code){
						msg += " (code " + error._rpcErrorObject.code + ")";
					}
					msg += "</pre>";
					andes.error({
						title: "Server Error",
						message: msg,
						errorType: andes.error.OK
					});
				}else{
					// FIXME: What other kind of errors come up here? Are we
					//        safe in assuming this is something we can simply
					//        try again?
					if(++tries <= MAX_RETRIES){
						setTimeout(function(){
							sendRequest(req);
						}, RETRY_TIMEOUT);
					}else{
						req.dfd.errback(error);
						console.error(error);
						andes.error({
							title: "Connection Error",
							message: "The connection to the server failed and couldn't be re-established after retrying " + MAX_RETRIES + " times; giving up.",
							dialogType: andes.error.OK
						});
					}
				}
			}
		);
	}

	function nextRequest(){
		// process the next request in the queue, if any
		if(!requestInFlight){
			var req = queue.shift();
			if(req){
				tries = 0;
				sendRequest(req);
			}
		}
	}

	function queueRequest(method, params){
		// add a request to the queue for processing when the current
		// pending request (if any) returns
		var dfd = new dojo.Deferred();
		queue.push({dfd:dfd, method:method, params:params});
		if(queue.length == 1){
			nextRequest();
		}
		return dfd;
	}

	andes.api = {
		open: function(params){
			console.warn("andes.api.open", params);
			startTime = (new Date()).getTime();
			var dfd = queueRequest("open-problem", params);
			
			dfd.addCallback(function(result){
				// look for help embedded in the returned result, so we can
				// queue it up in case the user opens the Help pane
				andes.help.processStep(result);
			});
			return dfd;
		},

		step: function(params){
			console.warn("andes.api.step", params);
			var dfd = queueRequest("solution-step", params);
			dfd.addCallback(function(result){
				console.log("HELP CALLBACK", result)
				// look for help embedded in the returned result, so we can
				// queue it up in case the user opens the Help pane
				andes.help.processStep(result);
			});
			return dfd;
		},

		help: function(params){
			console.warn("andes.api.help", params);
			return queueRequest("seek-help", params);
		},

		close: function(params){
			console.warn("andes.api.close", params);
			return queueRequest("close-problem", params);
		}
	};

})();

