; (function() {
    window.imy_realxhr_callback = function(id, message) {
        var hookAjax = window.OMTAjax.hookedXHR[id];
        if (hookAjax) {
            var statusCode = message.status;
            var responseText = (!!message.data) ? message.data : "";
            var responseHeaders = message.headers;
            window.OMTAjax.nativeCallback(id, statusCode, responseText, responseHeaders, null);
        }
        window.OMTAjax.hookedXHR[id] = null;
    };

	window.OMTAjax = {
		hookedXHR: {},
		hookAjax: hookAjax,
		nativePost: nativePost,
		nativeCallback: nativeCallback
	};

	function nativePost(xhrId, params) {
		// TODO: 请求 Native
		params.xhrId = xhrId;
        window.webkit.messageHandlers.IMYXHR.postMessage(params);
	}

	function nativeCallback(xhrId, statusCode, responseText, responseHeaders, error) {
		var xhr = window.OMTAjax.hookedXHR[xhrId];
		if (xhr.isAborted) { // 如果该请求已经手动取消了

			xhr.readyState = 1;
		} else {
			xhr.status = statusCode;
			xhr.responseText = responseText;
			xhr.readyState = 4;

			xhr.omtResponseHeaders = responseHeaders;
		}
        if (xhr.readyState >= 3) {
            if (xhr.status >= 200 && xhr.status < 300) {
                xhr.statusText = "OK"
            } else {
                xhr.statusText = "Fail"
            }
        }
        if (xhr.onreadystatechange) {
            xhr.onreadystatechange()
        }
        if (xhr.readyState == 4) {
            if (xhr.statusText == "OK") {
                xhr.onload ? xhr.onload() : ""
            } else {
                xhr.onerror ? xhr.onerror() : ""
            }
        }
	}
	// hook ajax send 方法
	window.OMTAjax.hookAjax({
		setRequestHeader: function(arg, xhr) {
			if (!this.omtHeaders) {
				this.omtHeaders = {};
			}
			this.omtHeaders[arg[0]] = arg[1];
		},
		getAllResponseHeaders: function(arg, xhr) {
			var headers = this.omtResponseHeaders;
			if (headers) {
				if (typeof(headers) === 'object') {
					var result = '';
					for (var key in headers) {
						result = result + key + ':' + headers[key] + '\r\n'
					}
					return result;
				}
				return headers;
			}
		},
		getResponseHeader: function(arg, xhr) {
            for (key in this.omtResponseHeaders) {
                if (key.toLowerCase() == arg[0].toLowerCase()) {
                    return this.omtResponseHeaders[key];
                }
            }
            return null
		},
		open: function(arg, xhr) {
			this.omtOpenArg = arg;
		},
		send: function(arg, xhr) {
			// this.addEventListener('readystatechange', function() {
				this.isAborted = false;
				// iOS9需要对get方式进行hook，10及以上可以不需要
				if (this.omtOpenArg[0].toUpperCase() === 'POST'  || this.omtOpenArg[0].toUpperCase() === 'PUT'
					|| this.omtOpenArg[0].toUpperCase() === 'DELETE' || this.omtOpenArg[0].toUpperCase() === 'PATCH') {
					var params = {};
					params.data = arg[0];
					params.method = this.omtOpenArg[0];
					params.headers = this.omtHeaders;
					params.headers['Cookie'] = document.cookie;
					params.headers["User-Agent"] = window.navigator.userAgent;

					let url = this.omtOpenArg[1];
					params.url = url.trim();
					let xhrId = 'xhrId' + (new Date()).getTime();
					while (window.OMTAjax.hookedXHR[xhrId] != null) {// 防止1ms内请求多个接口导致value覆盖
						xhrId = xhrId + '0';
					}
					params.id = xhrId;
					window.OMTAjax.hookedXHR[xhrId] = this;
					window.OMTAjax.nativePost(xhrId, params);

					return true;
				}

			// });
			// 通过 return true 可以阻止默认 Ajax 请求，不返回则会继续原来的请求
		},
		abort: function(arg, xhr) {
			if (this.omtOpenArg[0] === 'POST' || this.omtOpenArg[0] === 'post'
			|| this.omtOpenArg[0] === 'PUT' || this.omtOpenArg[0] === 'put'
			|| this.omtOpenArg[0] === 'DELETE' || this.omtOpenArg[0] === 'delete') {
				if (xhr.onabort) {
					xhr.onabort()
				}
				return true;
			}
		},
	});

	function hookAjax(proxy) {
		// 保存真正的XMLHttpRequest对象
		window._ahrealxhr = window._ahrealxhr || XMLHttpRequest;
		XMLHttpRequest = function() {
			var xhr = new window._ahrealxhr;
			// 直接在一个对象上定义一个新属性，或者修改一个对象的现有属性， 并返回这个对象
			Object.defineProperty(this, 'xhr', {
				value: xhr
			})
		};
		// 获取 XMLHttpRequest 对象的属性
		var prototype = window._ahrealxhr.prototype;
		for (var attr in prototype) {
			var type = "";
			try {
				type = typeof prototype[attr]
			} catch(e) {}
			if (type === "function") {
				XMLHttpRequest.prototype[attr] = hookfunc(attr);
			} else {
				// 给属性提供 getter、setter 方法
				Object.defineProperty(XMLHttpRequest.prototype, attr, {
					get: getFactory(attr),
					set: setFactory(attr),
					enumerable: true
				})
			}
		}
		function getFactory(attr) {
			return function() {
				// 判断对象是否包含特定的自身（非继承）属性
				var v = this.hasOwnProperty(attr + "_") ? this[attr + "_"] : this.xhr[attr];
				var attrGetterHook = (proxy[attr] || {})["getter"];
				return attrGetterHook && attrGetterHook(v, this) || v
			}
		}

		function setFactory(attr) {
			return function(v) {
				var xhr = this.xhr;
				var that = this;
				var hook = proxy[attr];
				if (typeof hook === "function") { // 回调属性 onreadystatechange 等
					xhr[attr] = function() {
						hook.call(that, xhr) || v.apply(xhr, arguments); // 修改 3
					}
				} else {
					//If the attribute isn't writeable, generate proxy attribute
					var attrSetterHook = (hook || {})["setter"];
					v = attrSetterHook && attrSetterHook(v, that) || v;

					// 修改 1
					xhr[attr] = v;
					this[attr + "_"] = v;
				}
			}
		}

		function hookfunc(func) {
			return function() {
				var args = [].slice.call(arguments);
				// window.alert("hookfunc " + args);
				// call() 方法调用一个函数, 其具有一个指定的this值和分别地提供的参数
				// 该方法的作用和 apply() 方法类似，只有一个区别，就是call()方法接受的是若干个参数的列表，而apply()方法接受的是一个包含多个参数的数组
				if (proxy[func]) {
					// 修改 2
					var result = proxy[func].call(this, args, this.xhr);
					if (result) {
						return result;
					}
				}

				return this.xhr[func].apply(this.xhr, args);
			}
		}
		return window._ahrealxhr;
	}

	// function log(msg) {
	// 	var xhr = new XMLHttpRequest();
	// 	xhr.open('GET', "http://debugger/" +
	// 		encodeURIComponent(msg));
	// 	xhr.withCredentials = true;
	// 	xhr.send(null);
	// }

})();
