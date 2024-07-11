const express = require("express");
const mysql = require("mysql");
const bcrypt = require("bcrypt");
const db = require('./config/db');
const truckRoutes = require('./routes/truckRoutes');
const binRoutes = require('./routes/binRoutes');
const userRoutes = require('./routes/userRoutes');

const app = express();
const cors = require("cors")

app.use(cors({
    origin: "*"
}))
app.use(express.json())

app.use('/trucks', truckRoutes);
app.use('/bins', binRoutes);
app.use('/users', userRoutes);

app.get("/", async (req,res)=>{
    console.log("hi");
    const hashedPass = await bcrypt.hash("qwerty",10);
    res.send(hashedPass);
})
app.post("/login",(req,res)=>{
    console.log(req.body)
    if(req.body){
        let {username,password} = req.body;
       
        let sql = 'select * from users where username = ? and password = ?;';
        db.query(sql,[username,password], async (err,data)=>{
            if (err) res.status(400).send({ err });
            else{
                if(data.length == 0){
                    res.status(400).send("wrong email or password");
                }else{
                    res.send(data[0])
                }
            }
        })
    }
}) 

app.get('/getBinInfo', (req, res) => {
    let sql = "select * from poubelle";
    db.query(sql, (err, data) => {
        if (err) res.status(400).send({ err });
        else res.send(data);
    });
});

app.listen(3000,'0.0.0.0',()=>{
    console.log("listening to port 3000");
})