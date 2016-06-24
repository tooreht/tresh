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
    uuid: "667c1abc-7644-460e-b91e-15345ad7e5c7",
	name: "10battery",
	valueType: "int"
});

var battery11 = new siot.sensor({
    uuid: "be5cedb9-02c7-4154-8222-a1bc88cc6f07",
	name: "11battery",
	valueType: "int"
});

var battery12 = new siot.sensor({
    uuid: "2efd96ad-ead4-4b48-893d-458756248ab5",
	name: "12battery",
	valueType: "int"
});

var distance10 = new siot.sensor({
    uuid: "e4384b0b-e303-444b-87a3-ee8c8b72357a",
	name: "10distance",
	valueType: "int"
});

var distance11 = new siot.sensor({
    uuid: "2f35e3c5-622f-4b79-b2f5-55400ae910cc",
	name: "11distance",
	valueType: "int"
});

var distance12 = new siot.sensor({
    uuid: "20422825-9ebf-4643-b8b9-0379eac12c46",
	name: "12distance",
	valueType: "int"
});

var temperature10 = new siot.sensor({
    uuid: "fa6c37d9-a293-443c-b796-79db6c1f3020",
	name: "10temperature",
	valueType: "int"
});

var temperature11 = new siot.sensor({
    uuid: "ccba2a7f-78eb-49ae-83ce-0e491f6845a4",
	name: "11temperature",
	valueType: "int"
});

var temperature12 = new siot.sensor({
    uuid: "66898193-aa9d-4097-99a2-2cf08c00b93d",
	name: "12temperature",
	valueType: "int"
});

var snr10 = new siot.sensor({
    uuid: "adbc6409-c727-4c07-be6e-39847b475343",
	name: "10snr",
	valueType: "int"
});

var snr11 = new siot.sensor({
    uuid: "9b5e9384-fbdd-4afa-a8d9-9b1af9e5a1b5",
	name: "11snr",
	valueType: "int"
});

var snr12 = new siot.sensor({
    uuid: "78de9003-5bc2-4092-93bb-3d055524d2b8",
	name: "12snr",
	valueType: "int"
});

var rssi10 = new siot.sensor({
    uuid: "0b00846a-2724-456d-914b-22ad48880818",
	name: "10rssi",
	valueType: "int"
});

var rssi11 = new siot.sensor({
    uuid: "4ad07f0f-b456-4f5f-a022-2c1f88d6e373",
	name: "11rssi",
	valueType: "int"
});

var rssi12 = new siot.sensor({
    uuid: "cbb441a9-004a-4e7e-b157-30857a0f3429",
	name: "12rssi",
	valueType: "int"
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
}, function(done) {
    portName = process.argv.length > 2 ? process.argv[2] : process.env.DEVNAME;
    if (portName) {
        selection = [portName];
        startSerial(selection, null);
    } else {
        chooseSerialPort(done);
    }
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
        // console.log(serialports);
        serialportChoice = new cliselect(serialports);
        serialportPromise = serialportChoice.prompt();
        serialportPromise.done(startSerial, done);
    });
}

function startSerial(selection, done) {
    // console.log(selection);
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
        try {
        	obj = JSON.parse(data)
			switch (obj.address) {
				case 10:
					battery10.sendSensorData(obj.battery, done);
					distance10.sendSensorData(obj.distance, done);
					temperature10.sendSensorData(obj.temp, done);
					snr10.sendSensorData(obj.SNR, done);
					rssi10.sendSensorData(obj.RSSI, done);
					break;
				case 11:
					battery11.sendSensorData(obj.battery, done);
					distance11.sendSensorData(obj.distance, done);
					temperature11.sendSensorData(obj.temp, done);
					snr11.sendSensorData(obj.SNR, done);
					rssi11.sendSensorData(obj.RSSI, done);
					break;
				case 12:
					battery12.sendSensorData(obj.battery, done);
					distance12.sendSensorData(obj.distance, done);
					temperature12.sendSensorData(obj.temp, done);
					snr12.sendSensorData(obj.SNR, done);
					rssi12.sendSensorData(obj.RSSI, done);
					break;
			}
        } catch (e) {
            console.log(e);
        } finally {
           // console.log(typeof data);
           console.log(data);
        }
    }
    function showPortClose() {
        console.log("port closed.");
    }
    function showError(error) {
        console.log("Serial port error: " + error);
    }
}

