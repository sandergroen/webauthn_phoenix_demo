// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"
import * as Credential from "./credential";
import * as Encoder from "./encoder";

function callback(data) {
    var credentialOptions = data;
    credentialOptions["challenge"] = Encoder.strToBin(credentialOptions["challenge"]);
    // Registration
    if (credentialOptions["user"]) {
      credentialOptions["user"]["id"] = Encoder.strToBin(credentialOptions["user"]["id"]);
      var credential_name = document.getElementById("registration-create").querySelector("input[name='credential_name']").value;
      var name = document.getElementById("registration-create").querySelector("input[name='name']").value;
      var callback_url = `/api/registration/callback?credential_name=${credential_name}&name=${name}`;
      
      Credential.create(encodeURI(callback_url), credentialOptions);
    }
}

[document.getElementById("registration-create")].filter(item => item).forEach((registrationForm) => {
    registrationForm.addEventListener("submit", (e) => {
        e.preventDefault();
        let data = new FormData(e.target);
        const url = "/api/registration";
        fetch(url, {
            method: "POST",
            body: data
        })
        .then((response) => {
            return response.json();
        }).then((data) => {
            callback(JSON.parse(data))
        }).catch((e) => {
            console.log(e);
        });
    });
});


[document.getElementById("session-create")].filter(item => item).forEach((sessionForm) => {
    sessionForm.addEventListener("submit", (e) => {
        e.preventDefault();
        let data = new FormData(e.target);
        const url = "/api/session";
        fetch(url, {
            method: "POST",
            body: data
        })
        .then((response) => {
            return response.json();
        }).then((data) => {
            var credentialOptions = JSON.parse(data);
            credentialOptions["challenge"] = Encoder.strToBin(credentialOptions["challenge"]);
            credentialOptions["allowCredentials"].forEach(function(cred, i){
            cred["id"] = Encoder.strToBin(cred["id"]);
            })
            Credential.get(credentialOptions);
        }).catch((e) => {
            console.log(e);
        });
    });
});

[document.getElementById("credential-create")].filter(item => item).forEach((sessionForm) => {
    sessionForm.addEventListener("submit", (e) => {
        e.preventDefault();
        let data = new FormData(e.target);
        const url = "/api/credential";
        fetch(url, {
            method: "POST",
            body: data
        })
        .then((response) => {
            return response.json();
        }).then((data) => {
            var credentialOptions = JSON.parse(data);
            
            credentialOptions["challenge"] = Encoder.strToBin(credentialOptions["challenge"]);
            credentialOptions["user"]["id"] = Encoder.strToBin(credentialOptions["user"]["id"]);
            
            var credential_name = document.getElementById("credential-create").querySelector("input[name='credential_name']").value;
            var callback_url = `/api/credential/callback?credential_name=${credential_name}`;
            Credential.create(encodeURI(callback_url), credentialOptions);
        }).catch((e) => {
            console.log(e);
        });
    });
});

