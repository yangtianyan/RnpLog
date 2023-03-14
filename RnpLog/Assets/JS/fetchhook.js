; (function() {
    var nativeFetch = window.fetch
    var interceptMethodList = ['POST', 'PUT', 'PATCH', 'DELETE'];
    window.fetch = function (url, opts) {
        window.alert("啊啊啊啊啊啊啊");
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

})();
