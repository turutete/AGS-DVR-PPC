require "functions"

function index_restart()
end

function index_html_get(this, sds, oids)
   if not oids then oids = _G end -- Si no se especifica tabla de OIDs se supone global
   local template

   if access.get(sds, zigorNetVncPassword .. ".0")=="" then
      template = this.tmpl_no_password
   else
      template = this.tmpl_password
   end

   -- Sustituimos subidentificadores por OIDs
   local t=string.gsub(template, "%$(%w+)", function (k) return oids[k] or "$" .. k end)
   -- Sustituimos OIDs por valor
   t=string.gsub(t, "%$([%.%d]+)", function (k) local v=access.get(sds, k) return v end)

   return t
end

local this  = {
   file     = "/usr/local/zigor/activa/www/html/index.html",
   get      = index_html_get,
   save     = tmpl_save,
   restart  = index_restart,
   tmpl_no_password  = [[
<!-- NO EDITAR ESTE FICHERO. Created by AGS. -->
<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <title>AVC DVR</title>
  <link rel="stylesheet" href="main.css">

  <!-- promise polyfills promises for IE11 -->
  <script src="./noVNC/vendor/promise.js"></script>
  <!-- ES2015/ES6 modules polyfill -->
  <script type="module">
      window._noVNC_has_module_support = true;
  </script>
  <script>
      window.addEventListener("load", function() {
          if (window._noVNC_has_module_support) return;
          var loader = document.createElement("script");
          loader.src = "./noVNC/vendor/browser-es-module-loader/dist/browser-es-module-loader.js";
          document.head.appendChild(loader);
      });
  </script>
  <script type="module" crossorigin="anonymous">
      // Load supporting scripts
      import * as WebUtil from './noVNC/app/webutil.js';
      import RFB from './noVNC/core/rfb.js';

      var rfb;
      var desktopName;


      WebUtil.init_logging(WebUtil.getConfigVar('logging', 'warn'));
      // By default, use the host and port of server that served this file
      var host = WebUtil.getConfigVar('host', window.location.hostname);

      var password = WebUtil.getConfigVar('password', '');
      var path = WebUtil.getConfigVar('path', 'websockify');

      // If a token variable is passed in, set the parameter in a cookie.
      // This is used by nova-novncproxy.
      var token = WebUtil.getConfigVar('token', null);
      if (token) {
          // if token is already present in the path we should use it
          path = WebUtil.injectParamIfMissing(path, "token", token);

          WebUtil.createCookie('token', token, 1)
      }

      (function() {
          var url = 'ws';

          url += '://' + host + '/tcp_proxy';

          rfb = new RFB(document.getElementById('noVNC_container'), url,
                        { repeaterID: WebUtil.getConfigVar('repeaterID', ''),
                          shared: WebUtil.getConfigVar('shared', true),
                          credentials: { password: password } });
          rfb.viewOnly = WebUtil.getConfigVar('view_only', false);
          rfb.scaleViewport = WebUtil.getConfigVar('scale', true);
          rfb.resizeSession = WebUtil.getConfigVar('resize', true);
      })();
  </script>
</head>

<body>
  <div class="container header">
    <p class="title-text">AVC DVR</p>
  </div>

  </div>
    <div id="noVNC_container" style="display: flex; width: 100%; height: 100%; overflow: auto; background-color: rgb(40, 40, 40);">
  </div>

  <div class="container footer">
    <div class="footer-cols">
      <img src="images/logo_zigor.png">
    </div>
    <div class="footer-cols">
      <a href="downloads.html"><img class="center" src="images/down48.png"></a>
    </div>
    <div class="footer-cols">
      <p class="footer-text">ZIGOR CORPORACIÓN S.A.</p>
      <p class="footer-text">E-mail: zigor@zigor.com</p>
      <p class="footer-text">Web: www.zigor.com</p>
    </div>
  </div>
</body>
</html>

]],
   tmpl_password  = [[
<!-- NO EDITAR ESTE FICHERO. Created by AGS. -->
<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <title>AVC DVR</title>
  <link rel="stylesheet" href="main.css">

  <!-- promise polyfills promises for IE11 -->
  <script src="./noVNC/vendor/promise.js"></script>
  <!-- ES2015/ES6 modules polyfill -->
  <script type="module">
      window._noVNC_has_module_support = true;
  </script>
  <script>
      window.addEventListener("load", function() {
          if (window._noVNC_has_module_support) return;
          var loader = document.createElement("script");
          loader.src = "./noVNC/vendor/browser-es-module-loader/dist/browser-es-module-loader.js";
          document.head.appendChild(loader);
      });
  </script>
  <script type="module" crossorigin="anonymous">
      // Load supporting scripts
      import * as WebUtil from './noVNC/app/webutil.js';
      import RFB from './noVNC/core/rfb.js';

      var rfb;
      var desktopName;


      WebUtil.init_logging(WebUtil.getConfigVar('logging', 'warn'));
      // By default, use the host and port of server that served this file
      var host = WebUtil.getConfigVar('host', window.location.hostname);

      var password = WebUtil.getConfigVar('password', '');
      var path = WebUtil.getConfigVar('path', 'websockify');

      // If a token variable is passed in, set the parameter in a cookie.
      // This is used by nova-novncproxy.
      var token = WebUtil.getConfigVar('token', null);
      if (token) {
          // if token is already present in the path we should use it
          path = WebUtil.injectParamIfMissing(path, "token", token);

          WebUtil.createCookie('token', token, 1)
      }

      function connect() {
          var url = 'ws';
          var vnc_div = document.getElementById("noVNC_container");

          vnc_div.style.height = '100%';
          url += '://' + host + '/tcp_proxy';
          password = document.getElementById("password").value;
          rfb = new RFB(document.getElementById('noVNC_container'), url,
                        { repeaterID: WebUtil.getConfigVar('repeaterID', ''),
                          shared: WebUtil.getConfigVar('shared', true),
                          credentials: { password: password } });
          rfb.viewOnly = WebUtil.getConfigVar('view_only', false);
          rfb.scaleViewport = WebUtil.getConfigVar('scale', true);
          rfb.resizeSession = WebUtil.getConfigVar('resize', true);
      };

      var button = document.getElementById("connect");
      button.onclick = connect;

      var input = document.getElementById("password");
      // Execute a function when the user releases a key on the keyboard
      input.addEventListener("keyup", function(event) {
         // Cancel the default action, if needed
         event.preventDefault();
          // Number 13 is the "Enter" key on the keyboard
         if (event.keyCode === 13) {
            // Trigger the button element with a click
            button.click();
         }
      });
  </script>
</head>

<body>
  <div class="container header">
    <p class="title-text">AVC DVR</p>
  </div>

  <div align="center">
    <p>Enter password for VNC connection:</p>
    <input type="password" id="password"><br>
    <input id="connect" type="submit" value="Connect">
  </div>

  </div>
    <div id="noVNC_container" style="display: flex; width: 100%; height: 0%; overflow: auto; background-color: rgb(40, 40, 40);">
  </div>

  <div class="container footer">
    <div class="footer-cols">
      <img src="images/logo_zigor.png">
    </div>
    <div class="footer-cols">
      <a href="downloads.html"><img class="center" src="images/down48.png"></a>
    </div>
    <div class="footer-cols">
      <p class="footer-text">ZIGOR CORPORACIÓN S.A.</p>
      <p class="footer-text">E-mail: zigor@zigor.com</p>
      <p class="footer-text">Web: www.zigor.com</p>
    </div>
  </div>
</body>
</html>
]]
}

return this
