//calcShell();


// Parameters
//============
wCalc    = printHoles(30);    //width of the calculator
hCalc    = printHoles(58);    //heighth of the calculator
dCalc    = 18;                //depth of the calculator
rCalc    = printHoles(2);     //radius of the calculator
gapCalc  = 1;                 //extra room for the calculator
wRim     = 4;                 //width of the RIM
dRim     = 2;                 //depth of the RIM
slope    = 1.6;               //slope of top, bottom, and right side
dScrew   = 2.4;               //depth of a screw head
rScrew   = 4;                 //radius of the screw head
dKey     = 2.4;               //depth of a key
rKey     = 2;                 //radius of the screw head
hHinge   = 10;                //height of each hinge element
gapHinge = 0.4;               //gap between hinge parts
rLatch   = 1;                 //radius of thre latch
hLatch   = printHoles(8);     //height of ther patch
dLatch   = 4;                 //depth of the latch
gapLatch = 0.2;               //gap between latch parts
dEngrave = 0.6;               //engrave depth
text     = "AriCalculator";   //logo
segments = 48;

// Functions
//===========
//Convert print hole distance to mm
// x: print hole count
function printHoles(x=1) = x * 2.54;

// Modules
//=========
//Calculator footprint
//calcFootprint();
module calcFootprint(s=1) {
    scale([s,s,1]) {
        hull() {
            translate([printHoles(-13),printHoles( 27),0]) cylinder(r=rCalc, h=dEngrave, $fn=segments);
            translate([printHoles( 13),printHoles( 27),0]) cylinder(r=rCalc, h=dEngrave, $fn=segments);
            translate([printHoles( 13),printHoles(-27),0]) cylinder(r=rCalc, h=dEngrave, $fn=segments);
            translate([printHoles(-13),printHoles(-27),0]) cylinder(r=rCalc, h=dEngrave, $fn=segments);
        }
    }
}

//Engravings
//engravings();
module engravings(x=0,y=0,z=0) {
    translate([(x+printHoles(15)),y,z]) {
        difference() {  
            calcFootprint(s=0.95);
            calcFootprint(s=0.93);
        }
        difference() {  
            calcFootprint(s=0.85);
            calcFootprint(s=0.83);
        }
        difference() {  
            calcFootprint(s=0.75);
            calcFootprint(s=0.73);
        }
        difference() {  
            calcFootprint(s=0.65);
            calcFootprint(s=0.63);
        }
        difference() {  
            calcFootprint(s=0.55);
            calcFootprint(s=0.53);
        }
        difference() {  
            calcFootprint(s=0.45);
            calcFootprint(s=0.43);
        }
        difference() {  
            calcFootprint(s=0.35);
            calcFootprint(s=0.33);
        }
        difference() {  
            calcFootprint(s=0.25);
            calcFootprint(s=0.23);
        }
        difference() {  
            calcFootprint(s=0.15);
            calcFootprint(s=0.13);
        }
        difference() {  
            calcFootprint(s=0.05);
            calcFootprint(s=0.03);
        }
    }
}

//Logo
//logo();
module logo(x=0,y=0,z=0) {
    translate([(x+printHoles(15)),y,z]) {
        linear_extrude(height=dEngrave) rotate([0,0,70]) mirror([1,0,0]) text(text, halign="center", valign="center");
    }
}

//Screw molds
//screwMolds();
module screwMolds(x=0,y=0,z=0) {
    translate([x,y,z]) {
        translate([printHoles( 2),printHoles( 25),0]) cylinder(r=rScrew, h=dScrew, $fn=segments);
        translate([printHoles(28),printHoles( 25),0]) cylinder(r=rScrew, h=dScrew, $fn=segments);
        translate([printHoles( 2),printHoles(  0),0]) cylinder(r=rScrew, h=dScrew, $fn=segments);
        translate([printHoles(28),printHoles(  0),0]) cylinder(r=rScrew, h=dScrew, $fn=segments);
        translate([printHoles( 2),printHoles(-25),0]) cylinder(r=rScrew, h=dScrew, $fn=segments);
        translate([printHoles(28),printHoles(-25),0]) cylinder(r=rScrew, h=dScrew, $fn=segments);
    }
}

//Key molds
//keyMolds();
module keyMolds(x=0,y=0,z=0) {
    translate([x,y,z]) {
        hull() {
            translate([printHoles( 5),printHoles(  2),0]) cylinder(r=rKey, h=dKey, $fn=segments);
            translate([printHoles(25),printHoles(  2),0]) cylinder(r=rKey, h=dKey, $fn=segments);
            translate([printHoles( 5),printHoles(-22),0]) cylinder(r=rKey, h=dKey, $fn=segments);
            translate([printHoles(25),printHoles(-22),0]) cylinder(r=rKey, h=dKey, $fn=segments);
        }
    }
}

//Hinges
//hinge_male_positive();
module hinge_male_positive(x=0,y=0,z=0,flip=false) {
    translate([x,y,z]) {
        rotate([90,0,0]) mirror([0,0,flip?1:0]) {
            translate([0,0,(printHoles(1)-(gapHinge/2))]) cylinder(r1=dRim, r2=0, h=dRim, $fn=segments);
            cylinder(r=dRim, h=(printHoles(1)-(gapHinge/2)), $fn=segments);
            rotate([0,0,225]) cube(size=[dRim,(2*dRim),(printHoles(1)-(gapHinge/2))]);
        }
    }
}
//hinge_male_negative();
module hinge_male_negative(x=0,y=0,z=0,flip=false) {
    translate([x,y,z]) {
        rotate([90,0,0]) mirror([0,0,flip?1:0]) {
            translate([0,0,(printHoles(1)+(gapHinge/2))]) cylinder(r1=dRim, r2=0, h=dRim, $fn=segments);
            translate([0,0,-gapHinge]) cylinder(r=(dRim+gapHinge), h=(printHoles(1)+(gapHinge*1.5)), $fn=segments);
            rotate([0,0,225]) translate([0,0,-gapHinge]) cube(size=[(dRim+gapHinge),(2*(dRim+gapHinge)),(printHoles(1)+(gapHinge*1.5))]);
        }
    }
}
//hinge_female_positive();
module hinge_female_positive(x=0,y=0,z=0,flip=false) {
    translate([x,y,z]) {
        rotate([90,0,0]) mirror([0,0,flip?1:0]) {
            difference() {
                union() {
                    cylinder(r=dRim, h=(printHoles(1)-(gapHinge/2)), $fn=segments);
                    rotate([0,0,225]) cube(size=[(2*dRim),dRim,(printHoles(1)-(gapHinge/2))]);
                }
                translate([0,0,(printHoles(1)-(gapHinge/2)-dRim)])cylinder(r2=dRim, r1=0, h=dRim, $fn=segments);
            }
        }
    }
}
//hinge_female_negative();
module hinge_female_negative(x=0,y=0,z=0,flip=false) {
    translate([x,y,z]) {
        rotate([90,0,0]) mirror([0,0,flip?1:0]) {
            cylinder(r=(dRim+gapHinge), h=(printHoles(1)+(gapHinge/2)), $fn=segments);
            rotate([0,0,225]) cube(size=[(2*(dRim+gapHinge)),(dRim+gapHinge),(printHoles(1)+(gapHinge/2))]);
        }
    }
}

//Latch
//latch();
module latch(x=0,y=0,z=20,inv=false) {
    gap=inv?gapLatch:0;
    translate([x,y,z]) rotate([90,inv?180:0,0]) {
        translate([0,dLatch,-((hLatch+gap)/2)]) cylinder(r=(rLatch+gap), h=(hLatch+gap), $fn=segments);
        translate([0,0,-((hLatch+gap)/2)]) cube(size=[(inv?(2*(rLatch+gap)):(rLatch+gap)),dLatch,(hLatch+gap)]);
    }
}

//Calculator corners
//calcCorners();
module calcCorners(x=0,y=0,z=0) {
    translate([x,y,z]) {
        //Left corner
        linear_extrude(height=((dCalc/2)+gapCalc-dRim), scale=(slope))
            translate([rCalc,0,0]) circle(r=(rCalc+gapCalc), $fn=segments);
        translate([(rCalc*(slope)),0,((dCalc/2)+gapCalc-dRim)]) cylinder(h=dRim, r=((rCalc+gapCalc)*slope), $fn=segments);

        //Right corner
        translate([(wCalc-rCalc),0,0]) {
            linear_extrude(height=((dCalc/2)+gapCalc-dRim), scale=(slope)) circle(r=(rCalc+gapCalc), $fn=segments);
            translate([0,0,((dCalc/2)+gapCalc-dRim)]) cylinder(h=dRim, r=((rCalc+gapCalc)*slope), $fn=segments);   
        }
    }
}

//Calculator excavation
//calcExcavation();
module calcExcavation(x=0,y=0,z=0) {
    translate([x,y,z]) {
        hull(){
            calcCorners(y=((hCalc/2)-rCalc)); //top
            calcCorners(y=(rCalc-(hCalc/2))); //bottom
        }
    }
}    

//Shell
//shell();
module shell(x=0,y=0,z=0, frontSide=false) {
    translate([x,y,z]) {
        difference() {
            union() {
                minkowski() {
                    calcExcavation();
                    sphere(r=wRim, $fn=segments);
                }
            }
            union() {
                translate([-(0.25*wCalc),-hCalc,((dCalc/2)+gapCalc)]) cube(size=[(2*wCalc),(2*hCalc),(2*wRim)]);
                calcExcavation();
                screwMolds(z=-dScrew+0.001);
                if(frontSide) keyMolds(z=-dKey+0.001);
                engravings(z=-wRim);
                //logo(z=-wRim);               
            }
        }        
    }
}

//Case
case(z=wRim);
module case(x=0,y=0,z=0) {
    translate([x,y,z]) {
        //Front side
        difference() {   
            translate([-(wRim+(4.5*gapHinge)),0,0]) {
                difference() {
                    rotate([0,0,180]) 
                        shell(frontSide=true);
                    //Latch
                    latch(x=-(wCalc+(((dCalc/2)-dRim)/slope)+3.1),z=((dCalc/2)+gapCalc+0.001),inv=true);
                }
            }
            //Negative hinges
            union() {
                hinge_male_negative(y=printHoles(26),z=((dCalc/2)+gapCalc),flip=false);
                for(i=[-22:4:22]) {      
                    hinge_male_negative(y=printHoles(i),z=((dCalc/2)+gapCalc),flip=true);
                    hinge_male_negative(y=printHoles(i),z=((dCalc/2)+gapCalc),flip=false);
                }
                hinge_male_negative(y=printHoles(-26),z=((dCalc/2)+gapCalc),flip=true);
            }
        }
        //Positive hinges
        for(i=[-24:4:24]) {      
            hinge_female_positive(y=printHoles(i),z=((dCalc/2)+gapCalc),flip=true);
            hinge_female_positive(y=printHoles(i),z=((dCalc/2)+gapCalc),flip=false);
        }
                        
        //Back side
        difference() {   
            translate([(wRim+(4.5*gapHinge)),0,0]) {
                shell(frontSide=false);
                //Latch
                latch(x=(wCalc+(((dCalc/2)-dRim)/slope)+3.1), z=((dCalc/2)+gapCalc));
            }
            //Negative hinges
            union() {
                for(i=[-24:4:24]) {      
                    hinge_female_negative(y=printHoles(i),z=((dCalc/2)+gapCalc),flip=true);
                    hinge_female_negative(y=printHoles(i),z=((dCalc/2)+gapCalc),flip=false);
                }
            }
        }
        //Positive hinges
        hinge_male_positive(y=printHoles(26),z=((dCalc/2)+gapCalc),flip=false);
        for(i=[-22:4:22]) {      
            hinge_male_positive(y=printHoles(i),z=((dCalc/2)+gapCalc),flip=true);
            hinge_male_positive(y=printHoles(i),z=((dCalc/2)+gapCalc),flip=false);
        }
        hinge_male_positive(y=printHoles(-26),z=((dCalc/2)+gapCalc),flip=true);
    }
}