//$fn = 300;
//$fn = 100;

// Box sizes
bX = 110;
bY = 70;
bZ = 50;
bT = 3;

// Knob
kT = 1.6; // knob-"thickness"
knobX = 20;

compartmentHeight = 25;
sensorWidth = 25;
sensorLength = 50;


// Waspmote sizes
wmL = 73.5;
wmW = 51;
wmH = 13;

// Waspmote sockets
wmSh = 5;
wmSr = 3;


module sidewall() {
   difference() { 
    cube([bX, bT, bZ]);
    translate([0, bT/2, compartmentHeight]) cube([bX, bT, kT]);
   }
}

module sidewallLeft() {
    r = 5.5;
    difference() {
        sidewall();
//        translate([r+9, 0, compartmentHeight+bT+wmSh+bT/2+3])
        // 8 = distance of the case front to the waspmote
        // 6 = distance of antenna center from the mainboard margin
        // 6 = distance of antenna center from the mainboard bottom
        translate([r+8+8.5, 0, compartmentHeight+bT+wmSh+7.5]){
            rotate([0, 90, 90]){
                translate([-5,0,-0.5])cube([11,8+8.5+r+1,bT+1]);
            translate([0.5,0,-0.1])cylinder(r=r, h=bT+1);};}; // +1 because of weird rendering error
    };
}


module sidewallRight() {
    r = 6;
    difference() {
        sidewall();
//        translate([8, 0, compartmentHeight+bT+wmSh])
        translate([8, 0, compartmentHeight+bT])
            cube([wmL, bT, 10]);
    };
}

module backwall() {
    difference() {
        cube([bT, bY+2*bT, bZ]);
        translate([0, bT/2, compartmentHeight])
            cube([kT, bY+bT, kT]);
    }
}

module ceiling(x, y, z) {
    difference() {
        cube([x+z, y+2*z, z]);
//        translate([x-sensorWidth/2-5, ((y+2*z)-sensorWidth)/2, 0])
        translate([x-(sensorWidth/2+3), ((y+2*z)-sensorWidth)/2, 0])
//        translate([8+wmL+(sensorWidth/2), ((y+2*z)-sensorWidth)/2, 0])
            ceilingHole();
    }
}

module ceilingHole() {
    hull() {
        cylinder(r=sensorWidth/2, h=bT);
        translate([0, sensorLength - sensorWidth, 0])
            cylinder(r=sensorWidth/2, h=bT);
    }
}

module bottom() {
    cube([bX, bY + 2*bT, bT]);
    
}

// Box
module box() {
    union() {
        // left sidewall
        sidewallLeft();
        // right sidewall
        translate([0, bY+2*bT, 0])
            mirror([0, 1, 0])
            sidewallRight();
        // backwall
        translate([bX, 0, 0]) backwall();
        
        bottom();
        translate([0, 0, bZ]) ceiling(bX, bY, bT);
    }
}

module compartment(x, y, z, k) {
    shiftX = 3;
    kx = x + k;
    ky = y + 2 * k;
    kz = z / 2;
    union() {
        difference() {
            union() {
                difference() {
                    difference(){
                        union() {
                        // main board
                            translate([0,0,0]) cube([kx,ky,kz]);
                            translate([0,k,0]) cube([x,y,z]);
                        };
                        //Cut-Off 
                        cube([shiftX ,ky, z]);
                    };
                    // rail downside
                    translate([shiftX + 1,0,0])cube([1,ky,1.2]);
                };
                //rail upside
                translate([shiftX + 0,k,z])cube([1,y,1]);
                
                // waspmote socket 1
                translate([wmSr+8, wmSr+k+8, kT])
                    cylinder(h=5, r=wmSr, center=false);
                // waspmote socket 2
                translate([-wmSr+8+wmL, -wmSr+k+8+wmW-4, kT])
                    cylinder(h=wmSh, r=wmSr, center=false);
            };
            // waspmote hole
            translate([bT*2+8, kT+8, 0])
                cube([wmL-(wmSr*2*2), wmW, wmH]);
            translate([8+wmL-(bT*2+20+2), wmW+9.5, 0])
                cube([20,4,z]);
            // waspmote socket hole 1
            translate([wmSr+8, wmSr+k+8, 0])
                cylinder(h=wmSh + kT, r=wmSr/2, center=false);
            // waspmote socket hole 2
            translate([-wmSr+8+wmL, -wmSr+k+8+wmW-4, 0])
                cylinder(h=wmSh + kT, r=wmSr/2, center=false);
        };
    };
}

module waspmote() {
    cube([wmL, wmW, wmH]);
}

module wm_socket() {
    difference() {
        cylinder(h=wmSh , r=wmSr, center=false);
        cylinder(h=wmSh, r=wmSr/2, center=false);
    }
}

module cover() {
    shortenX = 3;
    translate([shortenX,0,0])cube([bZ - shortenX, bY, 1]);
    translate([0,0,1]) {
        difference() {
            difference(){
                difference(){
                    cube([bZ,bY,bT]);
                    cube([shortenX,bY,bT]);
                };
                    translate([compartmentHeight-0.05,0,bT-2.05])cube([bT + 0.1,bY,2.1]);
                };
            //rail upside
            translate([compartmentHeight + bT ,0,bT-2.05])cube([1.2,bY,1.3]);
        };
        //rail downside
        translate([compartmentHeight-0.1,0,bT-0.9])cube([1,bY,0.9]);
        
        //SideCover
        rotate([270, 0, 00]) {
        translate([compartmentHeight+bT+wmSh+7.5,-21.5,bY]){
            difference(){
                translate([-4.5,0,0])cube([7,22.5,bT]);
                translate([-0.9,2.1,0])cylinder(r=5, h=bT);
            };
        };
    };
};
}

// For printing all at once
translate([0 , bZ+bT, bX+bT]) rotate([0, 90, -90]) box();
translate([0 , 60, 0]) compartment(bX, bY, bT, kT);
translate([90, 50, 0]) rotate([0,0,-90]) cover();

// For Printing without box
//translate([0 , 60, 0]) compartment(bX, bY, bT, kT);
//translate([0, 50, 0]) rotate([0,0,-90])cover();

// compartment and cover together
//translate([0 , 60, 0]) compartment(bX, bY, bT, kT);
//translate([0.95, 63.5,-20]) mirror([0,0,1])rotate([90,90,90]) cover();

// For printing separately
//translate([0 , bZ+bT, bX+bT]) rotate([0, 90, -90]) box();
//compartment(bX, bY, bT, kT);

// All put together
//box();
//translate([0 , bT/2, compartmentHeight]){ compartment(bX, bY, bT, kT);
//translate([0, 1.5,-20]) mirror([0,0,1])rotate([90,90,90]) cover();};
//translate([8, kT+8, kT+compartmentHeight+wmSh]) waspmote();
