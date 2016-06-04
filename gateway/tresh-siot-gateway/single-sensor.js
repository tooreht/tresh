var async = require("async");

var cliselect = require("list-selector-cli");

var serialport = require("serialport");

var siot = require("siot.net-nodejs-api");

var serialports = [];

var serialportChoice;

var serialportPromise;

var gateway = new siot.gateway({
    centerLicense: "7F73-24E5-EBAB-4B71-A62F-98D4FDA02809"
});

var distance = new siot.sensor({
    uuid: "e42093a5-f420-894a-cf1b-1c8215014454",
    name: "Distance Sensor",
    valueType: "int",
});

var battery = new siot.sensor({
    uuid: "35aff35c-c8d3-e0cd-40ab-2c797ae102a7",
    name: "Battery Sensor",
    valueType: "int",
});

var temperature = new siot.sensor({
    uuid: "fa6c37d9-a293-443c-b796-79db6c1f3021",
	name: "temperature",
	valueType: "int"
});

var snr = new siot.sensor({
    uuid: "adbc6409-c727-4c07-be6e-39847b475344",
	name: "snr",
	valueType: "int"
});

var rssi = new siot.sensor({
    uuid: "0b00846a-2724-456d-914b-22ad48880819",
	name: "rssi",
	valueType: "int"
});

async.series([ function(done) {
    gateway.registerDevice(distance, done);
}, function(done) {
    gateway.registerDevice(battery, done);
}, function(done) {
    gateway.registerDevice(temperature, done);
}, function(done) {
    gateway.registerDevice(snr, done);
}, function(done) {
    gateway.registerDevice(rssi, done);
}, function(done) {
    gateway.connect(done);
}, function(done) {
    chooseSerialPort(done);
} ], function(err) {
    if (err) return console.error(err);
    // actor.on("siot_data", function(message) {
    //     console.log("received data for actor:", message);
    // });
    console.log("setup complete");
});

function chooseSerialPort(done) {
    // list serial ports:
    serialport.list(function(err, ports) {
        ports.forEach(function(port) {
            console.log(port.comName);
            console.log(port.pnpId);
            console.log(port.manufacturer);
            serialports.push(port.comName);
        });
        console.log(serialports);
        serialportChoice = new cliselect(serialports);
        serialportPromise = serialportChoice.prompt();
        serialportPromise.done(startSerial, done);
    });
}

function startSerial(selection, done) {
    console.log(selection);
    portName = selection[0];
    var treshPort = new serialport.SerialPort(portName, {
        baudRate: 115200,
        // look for return and newline at the end of each data packet:
        parser: serialport.parsers.readline("\n")
    });
    treshPort.on("open", showPortOpen);
    treshPort.on("data", sendSerialData);
    treshPort.on("close", showPortClose);
    treshPort.on("error", showError);
    function showPortOpen() {
        console.log("port open. Data rate: " + treshPort.options.baudRate);
    }
    function sendSerialData(data) {
        console.log(typeof data);
        console.log(data);
        try {
        	obj = JSON.parse(data)
        	distance.sendSensorData(obj.distance, done);
            battery.sendSensorData(obj.battery, done);
			temperature.sendSensorData(obj.temp, done);
			snr.sendSensorData(obj.SNR, done);
			rssi.sendSensorData(obj.RSSI, done);
        } catch (e) {
            console.log(e);
        }
    }
    function showPortClose() {
        console.log("port closed.");
    }
    function showError(error) {
        console.log("Serial port error: " + error);
    }
}
