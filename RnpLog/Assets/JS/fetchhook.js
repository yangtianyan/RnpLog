; (function() {
    var nativeFetch = window.fetch
    var interceptMethodList = ['POST', 'PUT', 'PATCH', 'DELETE'];
    window.fetch = function (url, opts) {
        
        // 判断是否包含请求体
        var hasBodyMethod = opts != null && opts.method != null && (interceptMethodList.indexOf(opts.method.toUpperCase()) !== -1);
        if (hasBodyMethod) {
            // 判断是否为iOS 11.3之前(可通过navigate.userAgent判断)
            var shouldSaveParamsToNative = isLessThan11_3;
            if (!shouldSaveParamsToNative) {
                // 如果为iOS 11.3之后请求体是否带有Blob类型数据
                shouldSaveParamsToNative = opts != null ? isBlobBody(opts) : false;
            }
            if (shouldSaveParamsToNative) {
                // 此时需要收集请求体数据保存到原生应用
                return saveParamsToNative(url, opts).then(function (newUrl) {
                    // 应用保存完成后调用原生fetch接口
                    return nativeFetch(newUrl, opts)
                });
            }
        }
        // 调用原生fetch接口
        return nativeFetch(url, opts);
    }

    function saveParamsToNative(url, opts) {
        return new Promise(function (resolve, reject) {
            // 构造标识符
            let identifier = generateUUID();
            let appendIdentifyUrl = urlByAppendIdentifier(url, "identifier", identifier)
            // 解析body数据并保存到原生应用
            if (opts && opts.body) {
                getBodyString(opts.body, function (body) {
                    // 设置保存完成回调，原生应用保存完成后调用此js函数后将请求发出
                    finishSaveCallbacks[identifier] = function () {
                        resolve(appendIdentifyUrl)
                    }
                    // 通知原生应用保存请求体数据
                    window.webkit.messageHandlers.IMYXHR.postMessage({'body': body, 'identifier': identifier})
                });
            } else {
                resolve(url);
            }
        });

        function getBodyString(body, callback) {
            if (typeof body == 'string') {
                callback(body)
            } else if (typeof body == 'object') {
                if (body instanceof ArrayBuffer) body = new Blob([body])
                if (body instanceof Blob) {
                    // 将Blob类型转换为base64
                    var reader = new FileReader()
                    reader.addEventListener("loadend", function () {
                        callback(reader.result.split(",")[1])
                    })
                    reader.readAsDataURL(body)
                } else if (body instanceof FormData) {
                    generateMultipartFormData(body)
                        .then(function (result) {
                            callback(result)
                        });
                } else if (body instanceof URLSearchParams) {
                    // 遍历URLSearchParams进行键值对拼接
                    var resultArr = []
                    for (pair of body.entries()) {
                        resultArr.push(pair[0] + '=' + pair[1])
                    }
                    callback(resultArr.join('&'))
                } else {
                    callback(body);
                }
            } else {
                callback(body);
            }
        }

    }

    window.imy_realfetch_callback = function(id, message) {
        var hookFetch = window.OMTFetch.hookedFetch[id];
        if (hookFetch) {
            var statusCode = message.status;
            var responseText = (!!message.data) ? message.data : "";
            var responseHeaders = message.headers;
            window.OMTFetch.nativeCallback(id, statusCode, responseText, responseHeaders, null);
        }
        window.OMTFetch.hookedFetch[id] = null;
    };

    window.OMTFetch = {
        hookedFetch: {},
        hookFetch: hookFetch,
        nativePost: nativePost,
        nativeCallback: nativeCallback
    };

    function nativePost(fetchId, params) {
        // 请求 Native
        params.fetchId = fetchId;
        window.webkit.messageHandlers.IMYFETCH.postMessage(params);
    }

    function nativeCallback(fetchId, statusCode, responseText, responseHeaders, error) {
        var fetchData = window.OMTFetch.hookedFetch[fetchId];
        if (fetchData.isAborted) {
            fetchData.reject(new DOMException("The user aborted a request", "AbortError"));
        } else {
            // 修改状态文本的生成逻辑，根据HTTP标准设置statusText
            var statusText = "OK";
            if (statusCode >= 400 && statusCode < 500) {
                statusText = "Client Error";
                if (statusCode === 400) statusText = "Bad Request";
                else if (statusCode === 401) statusText = "Unauthorized";
                else if (statusCode === 403) statusText = "Forbidden";
                else if (statusCode === 404) statusText = "Not Found";
                else if (statusCode === 409) statusText = "Conflict";
                else if (statusCode === 429) statusText = "Too Many Requests";
            } else if (statusCode >= 500) {
                statusText = "Server Error";
                if (statusCode === 500) statusText = "Internal Server Error";
                else if (statusCode === 502) statusText = "Bad Gateway";
                else if (statusCode === 503) statusText = "Service Unavailable";
            } else if (statusCode >= 300 && statusCode < 400) {
                statusText = "Redirect";
                if (statusCode === 301) statusText = "Moved Permanently";
                else if (statusCode === 302) statusText = "Found";
                else if (statusCode === 304) statusText = "Not Modified";
            } else if (statusCode >= 200 && statusCode < 300) {
                statusText = "OK";
                if (statusCode === 201) statusText = "Created";
                else if (statusCode === 204) statusText = "No Content";
            }
            
            var responseInit = {
                status: parseInt(statusCode, 10), // 确保状态码是数字类型
                statusText: statusText,
                headers: new Headers(responseHeaders || {})
            };
            
            var responseObj = new Response(responseText, responseInit);
            
            // 确保响应对象的状态码和文本被正确设置
            Object.defineProperty(responseObj, 'status', {
                value: parseInt(statusCode, 10),
                writable: false
            });
            
            Object.defineProperty(responseObj, 'ok', {
                value: statusCode >= 200 && statusCode < 300,
                writable: false
            });
            
            fetchData.resolve(responseObj);
        }
    }

    function hookFetch() {
        window._realfetch = window._realfetch || fetch;
        
        window.fetch = function(input, init) {
            // 只处理 URL 字符串类型的请求
            var url = input;
            if (input instanceof Request) {
                url = input.url;
                init = Object.assign({}, {
                    method: input.method,
                    headers: input.headers,
                    body: input.body,
                    mode: input.mode,
                    credentials: input.credentials,
                    cache: input.cache,
                    redirect: input.redirect,
                    referrer: input.referrer,
                    integrity: input.integrity
                }, init || {});
            }
            
            var method = (init && init.method) ? init.method.toUpperCase() : 'GET';
            
            // 只拦截特定方法的请求
            if (method === 'POST' || method === 'PUT' || method === 'DELETE' || method === 'PATCH') {
                return new Promise(function(resolve, reject) {
                    var params = {};
                    params.method = method;
                    params.url = url.trim();
                    
                    // 处理请求头
                    var headers = {};
                    if (init && init.headers) {
                        if (init.headers instanceof Headers) {
                            init.headers.forEach(function(value, key) {
                                headers[key] = value;
                            });
                        } else if (typeof init.headers === 'object') {
                            headers = Object.assign({}, init.headers);
                        }
                    }
                    
                    headers['Cookie'] = document.cookie;
                    headers["User-Agent"] = window.navigator.userAgent;
                    params.headers = headers;
                    
                    // 处理请求体
                    if (init && init.body) {
                        params.data = init.body;
                    }
                    
                    // 生成唯一ID
                    var fetchId = 'fetchId' + (new Date()).getTime();
                    while (window.OMTFetch.hookedFetch[fetchId] != null) {
                        fetchId = fetchId + '0';
                    }
                    params.id = fetchId;
                    
                    // 保存请求信息和回调
                    window.OMTFetch.hookedFetch[fetchId] = {
                        resolve: resolve,
                        reject: reject,
                        isAborted: false
                    };
                    
                    // 发送到原生
                    window.OMTFetch.nativePost(fetchId, params);
                    
                    // 支持中止请求
                    if (init && init.signal) {
                        init.signal.addEventListener('abort', function() {
                            if (window.OMTFetch.hookedFetch[fetchId]) {
                                window.OMTFetch.hookedFetch[fetchId].isAborted = true;
                                reject(new DOMException("The user aborted a request", "AbortError"));
                            }
                        });
                    }
                });
            } else {
                // 不拦截的请求使用原生fetch
                return window._realfetch(input, init);
            }
        };
        
        return window._realfetch;
    }
    
    // 初始化钩子
    window.OMTFetch.hookFetch();
})();
