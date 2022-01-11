exports.handler = (event, context, callback) => {

    const fs = require("fs");

    fs.readFile("/tmp/vault_secret.json", "utf-8", (err, data) => {
        if (err) throw err;
        console.log(data);
    });
};