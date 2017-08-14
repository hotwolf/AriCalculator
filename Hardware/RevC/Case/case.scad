//calcShell();


// Parameters
//============
wCalc    = printHoles(30);    //width of the calculator
hCalc    = printHoles(58);    //heigth of the calculator
dCalc    = 18;                //depth of the calculator
rCalc    = printHoles(2);     //radius of the calculator
gapCalc  = 1;                 //extra room for the calculator
wRim     = 4;                 //width of the RIM
dRim     = 2;                 //depth of the RIM
slope    = 1.6;               //slope of top, bottom, and right side
dScrew   = 2.4;               //depth of a screw head
rScrew   = 5;                 //radius of the screw head
dKey     = 1.8;               //depth of a key
rKey     = 4;                 //radius of the screw head
hHinge   = 10;                //height of each hinge element
gapHinge = 0.4;               //gap between hinge parts
rLatch   = 1;                 //radius of thre latch
hLatch   = printHoles(8);     //height of ther patch
dLatch   = 4;                 //depth of the latch
gapLatch = 0.2;               //gap between latch parts
dEngrave = 0.4;               //engrave depth
dElastic = 3;                 //width of the elastic band
logoText = "AriCalculator";            //Logo
logoFont = "Jolana:style=Italic";
logoSize = 12;
segments = 48; //48;

// Functions
//===========
//Convert print hole distance to mm
// x: print hole count
function printHoles(x=1) = x * 2.54;

// Modules
//=========
//Calculator footprint
//calcFootprint();
module calcFootprint(s=1, h=1) {
    scale([s,s,1]) {
        hull() {
            translate([printHoles(-13),printHoles( 27),0]) cylinder(r=rCalc, h=h, $fn=segments);
            translate([printHoles( 13),printHoles( 27),0]) cylinder(r=rCalc, h=h, $fn=segments);
            translate([printHoles( 13),printHoles(-27),0]) cylinder(r=rCalc, h=h, $fn=segments);
            translate([printHoles(-13),printHoles(-27),0]) cylinder(r=rCalc, h=h, $fn=segments);
        }
    }
}

//Logo
//logo();
module logo(x=0,y=0,z=0) {
    translate([(x+printHoles(15)),y-printHoles(10),z-dEngrave]) {
         linear_extrude(height=2*dEngrave) rotate([0,0-20,180]) mirror([1,0,0]) text(logoText, font=logoFont, size=logoSize, halign="center", valign="center");
    }
}

//Engravings
//engravings();
module engravings(x=0,y=-20,z=0) {
//    translate([(x+printHoles(15)),y,z]) {    
//        difference() {  
//            calcFootprint(s=0.95, h=dEngrave);
//            calcFootprint(s=0.94, h=dEngrave);
//        }
//        difference() {  
//            calcFootprint(s=0.85, h=dEngrave);
//            calcFootprint(s=0.84, h=dEngrave);
//        }
//        difference() {  
//            calcFootprint(s=0.75, h=dEngrave);
//            calcFootprint(s=0.74, h=dEngrave);
//        }
//        difference() {  
//            calcFootprint(s=0.65, h=dEngrave);
//            calcFootprint(s=0.64, h=dEngrave);
//        }
//        difference() {  
//            calcFootprint(s=0.55, h=dEngrave);
//            calcFootprint(s=0.54, h=dEngrave);
//        }
//        difference() {  
//            calcFootprint(s=0.45, h=dEngrave);
//            calcFootprint(s=0.44, h=dEngrave);
//        }
//        difference() {  
//            calcFootprint(s=0.35, h=dEngrave);
//            calcFootprint(s=0.34, h=dEngrave);
//        }
//        difference() {  
//            calcFootprint(s=0.25, h=dEngrave);
//            calcFootprint(s=0.24, h=dEngrave);
//        }
//        difference() {  
//            calcFootprint(s=0.15, h=dEngrave);
//            calcFootprint(s=0.14, h=dEngrave);
//        }
//        difference() {  
//            calcFootprint(s=0.05, h=dEngrave);
//            calcFootprint(s=0.04, h=dEngrave);
//        }
//    }
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
            translate([printHoles( 5),printHoles(-2),0]) cylinder(r=rKey, h=dKey, $fn=segments);
            translate([printHoles(25),printHoles(-2),0]) cylinder(r=rKey, h=dKey, $fn=segments);
            translate([printHoles( 5),printHoles(22),0]) cylinder(r=rKey, h=dKey, $fn=segments);
            translate([printHoles(25),printHoles(22),0]) cylinder(r=rKey, h=dKey, $fn=segments);
        }

        hull() {
            translate([printHoles( 2),printHoles(  0),0]) cylinder(r=rScrew, h=dKey, $fn=segments);
            translate([printHoles(28),printHoles(  0),0]) cylinder(r=rScrew, h=dKey, $fn=segments);
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

////Elastic mount
//elasticMountPositive();
//module elasticMountPositive();= {
//    
//    
//    
//}
//
//Shell
//shell(backSide=false);
module shell(x=0,y=0,z=0, backSide=false) {
    translate([x,y,z]) {
        difference() {
            union() {
                minkowski() {
                    union() {
                      calcExcavation();
                      if(backSide) {
                        translate([0.9*wCalc,0,dElastic]) rotate([90,0,0]) cylinder(d=(2*dElastic), h=hCalc+(3.5*dRim), center= true, $fn=segments);
                      }
                    }                       
                    sphere(r=wRim, $fn=segments);
                }               
            }
            union() {
                translate([-(0.25*wCalc),-hCalc,((dCalc/2)+gapCalc)]) cube(size=[(2*wCalc),(2*hCalc),(2*wRim)]);
                calcExcavation();
                screwMolds(z=-dScrew+0.001);
                engravings(z=-wRim);
                if(!backSide) {
                    keyMolds(z=-dKey+0.001);
                    logo(z=-wRim);
                }
                if(backSide) {
                    translate([0.9*wCalc,0,dElastic]) rotate([90,0,0]) union() {
                        cylinder(d=dElastic, h=(2*hCalc), center= true, $fn=segments);
                        cylinder(d=(2*dElastic), h=hCalc+(5.5*dRim), center= true, $fn=segments);
                    }
                }
            }
        }
        //translate([0.9*wCalc,0,dRim]) rotate([90,0,0]) cylinder(d=(dElastic), h=hCalc+(2*dRim), center= true, $fn=segments);
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
                        shell(backSide=false);
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
                shell(backSide=true);
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