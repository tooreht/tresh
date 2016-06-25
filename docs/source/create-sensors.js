// This script creates the sensors for the 3 Waspmote Sensors. 
// until the current version of SIOT.net The UUID's of the new created
// sensors have to be looked up manually in the SIOT.net interface http://siot.net:15780/welcome
// and put into the index.js file.

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

var battery10 = new siot.sensor({
	"name":"10 Battery Sensor",
	"description": "Battery Sensor of node 10",
	"type":"sensor",
	"valueType":"int"
});

var battery11 = new siot.sensor({
	"name":"11 Battery Sensor",
	"description": "Battery Sensor of node 11",
	"type":"sensor",
	"valueType":"int"
});

var battery12 = new siot.sensor({
	"name":"12 Battery Sensor",
	"description": "Battery Sensor of node 12",
	"type":"sensor",
	"valueType":"int"
});

var distance10 = new siot.sensor({
	"name":"10 Distance Sensor",
	"description": "Distance Sensor of node 10",
	"type":"sensor",
	"valueType":"int"
});

var distance11 = new siot.sensor({
	"name":"11 Distance Sensor",
	"description": "Distance Sensor of node 11",
	"type":"sensor",
	"valueType":"int"
});

var distance12 = new siot.sensor({
	"name":"12 Distance Sensor",
	"description": "Distance Sensor of node 12",
	"type":"sensor",
	"valueType":"int"
});

var temperature10 = new siot.sensor({
	"name":"10 Temperature Sensor",
	"description": "Temperature Sensor of node 10",
	"type":"sensor",
	"valueType":"int"
});

var temperature11 = new siot.sensor({
	"name":"11 Temperature Sensor",
	"description": "Temperature Sensor of node 11",
	"type":"sensor",
	"valueType":"int"
});

var temperature12 = new siot.sensor({
	"name":"12 Temperature Sensor",
	"description": "Temperature Sensor of node 12",
	"type":"sensor",
	"valueType":"int"
});

var snr10 = new siot.sensor({
	"name":"10 SNR Sensor",
	"description": "SNR Sensor of node 10",
	"type":"sensor",
	"valueType":"int"
});

var snr11 = new siot.sensor({
	"name":"11 SNR Sensor",
	"description": "SNR Sensor of node 11",
	"type":"sensor",
	"valueType":"int"
});

var snr12 = new siot.sensor({
	"name":"12 SNR Sensor",
	"description": "SNR Sensor of node 12",
	"type":"sensor",
	"valueType":"int"
});

var rssi10 = new siot.sensor({
	"name":"10 RSSI Sensor",
	"description": "RSSI Sensor of node 10",
	"type":"sensor",
	"valueType":"int"
});

var rssi11 = new siot.sensor({
	"name":"11 RSSI Sensor",
	"description": "RSSI Sensor of node 11",
	"type":"sensor",
	"valueType":"int"
});

var rssi12 = new siot.sensor({
	"name":"12 RSSI Sensor",
	"description": "RSSI Sensor of node 12",
	"type":"sensor",
	"valueType":"int"
});


async.series([ function(done) {
    gateway.registerDevice(battery10, done)
	},function(done) {
    gateway.registerDevice(battery11, done)
	},function(done) {
    gateway.registerDevice(battery12, done)
	},function(done) {
    gateway.registerDevice(distance10, done)
	},function(done) {
    gateway.registerDevice(distance11, done)
	},function(done) {
    gateway.registerDevice(distance12, done)
	},function(done) {
    gateway.registerDevice(temperature10, done)
	},function(done) {
    gateway.registerDevice(temperature11, done)
	},function(done) {
    gateway.registerDevice(temperature12, done)
	},function(done) {
    gateway.registerDevice(snr10, done)
	},function(done) {
    gateway.registerDevice(snr11, done)
	},function(done) {
    gateway.registerDevice(snr12, done)
	},function(done) {
    gateway.registerDevice(rssi10, done)
	},function(done) {
    gateway.registerDevice(rssi11, done)
	},function(done) {
    gateway.registerDevice(rssi12, done)
	}, function(done) {
    gateway.connect(done);
}], function(err) {
    if (err) return console.error(err);
    console.log("setup complete");
});


