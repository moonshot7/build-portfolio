const mysql = require("mysql");

const db = mysql.createConnection({
    host:'0.0.0.0',
    user:'root',
    password:'',
    database:'smatrash',
    port: 3306
})
db.connect((err)=>{
    if(err) console.log(err);
    else console.log("Connected to database");
})

module.exports = db;