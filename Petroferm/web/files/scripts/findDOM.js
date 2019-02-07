/*
CREATED BY: Brian Gaines
FILE NAME: findDOM.js
PURPOSE: This javascripts determines a browser's ability to perform DHTML by feature sensing
a browser and setting appropriate variables representing the cababilities. Also, if the browser
does support DHMTL, a function called findDOM is created to locate the DOM to manipulate property
values of an object.
*/

var isDHTML = 0;
var isID = 0;
var isAll = 0;
var isLayers = 0;

if (document.getElementById) { 
	isID = 1; idDHTML = 1; //W3C ID DOM
} else {
	if (document.all) { 
		isAll = 1; isDHTML = 1; //IE DOM
	} else { 
		browserVersion = parseInt(navigator.appVersion);
		if ((navigator.appName.indexOf('Netscape') != -1) && (browserVersion == 4)) { 
			isLayers = 1; isDHMTL = 1; //Netscape DOM
		}
	}
}

/*
CREATED BY: Brian Gaines
PURPOSE: Function locates the DOM of an object. 
USAGE: Pass in the object ID of the container along with a 0 or 1 to represent whether to get a style of the container.
*/

function findDOM(objectID,withStyle) {

    //debug here to determine what javascript objects aren't referenced
    //alert(objectID + '::' + document.getElementById(objectID));

	if (withStyle == 1) {
		if (isID) { //W3C DOM
			return (document.getElementById(objectID).style);
		} else {
			if (isAll) { //IE DOM
				return (document.all[objectID].style);
			} else {
				if (isLayers) { //Netscape DOM
					return (document.layers[objectID]);
				}
			}
		}
	} else {
		if (isID) {
			return (document.getElementById(objectID));
		} else {
			if (isAll) {
				return (document.all[objectID]);
			} else {
				if (isLayers) {
					return (document.layers[objectID]);
				}
			}
		}
	}
}

/*

*/
function findVisibility(objectID) {
	var dom = findDOM(objectID,1);
	if ((dom.visibility == 'show') || (dom.visibility = 'visible')) {
		return 'visible';
	}
	return 'hidden';
}

/*
*/
function setVisibility(objectID,state) {
	var dom = findDOM(objectID,1);
	dom.visibility = state;
}

/*
Hides/Shows the side navigation window
*/
function toggleDIV(objectID) {
	if (isAll || isID) {
		domStyle = findDOM(objectID,1);
		if (domStyle.display =='block')  domStyle.display='none';
		else domStyle.display='block';
	}
	return;
}

/*

*/
function navImageToggle(img, src1, src2, container, nscontainer){
//alert(img + '\n' + src1 + '\n' + src2);
//alert(document.images[img]);
    var objStr,obj;
    // Check to make sure that images are supported in the DOM.
  	myImage = document.images[img];
    if(document.layers){
        myImage = document.layers[container].document.layers[nscontainer].document.images[img];
    }
    if(document.images){
        // Check to see whether you are using a name, number, or object
        if(myImage.src == src1){
   	  	    myImage.src = src2;
        } else {
    	    myImage.src = src1;
        }
    }
}

/*

*/
//alert(location.port);
function InitMenu(openmenu,imgName,nsContainer,currBlock){      
    toggleDIV(openmenu);
	if (document.domain == 'localhost') {
		var sdomain = document.domain + '/petroferm';
	} else {
	    if (location.port=='80') {
		    var sdomain = document.domain;
		}else{
		    var sdomain = document.domain + ':' + location.port;
		}
	}
    navImageToggle(imgName, 'http://' + sdomain + '/web/files/images/misc/arrow_blue_down.gif', 'http://' + sdomain + '/web/files/images/misc/arrow_white.gif', nsContainer, currBlock);
    return false;
}

function Radio(layer,imgNames,length,defaultValue) {
	this.layer = layer
	this.imgNames = imgNames
	this.length = length
	this.change = RadioChange
	this.value = (defaultValue)? defaultValue : "undefined"
}
function RadioChange(index,value) {
	this.value = value
	for (var i=0; i<this.length; i++) changeImage(this.layer,this.imgNames+i,'radio0')
	changeImage(this.layer,this.imgNames+index,'radio1')
}

function CheckBox(layer,imgName,trueValue,falseValue,defaultToTrue) {
	this.layer = layer
	this.imgName = imgName
	this.trueValue = trueValue
	this.falseValue = falseValue
	this.state = (defaultToTrue) ? 1 : 0
	this.value = (this.state) ? this.trueValue : this.falseValue
	this.change = CheckBoxChange
}
function CheckBoxChange() {
	this.state = (this.state) ? 0 : 1
	this.value = (this.state) ? this.trueValue : this.falseValue
	changeImage(this.layer,this.imgName,'checkbox'+this.state)
}

function preload(imgObj,imgSrc) {
	if (document.images) {
		eval(imgObj+' = new Image()')
		eval(imgObj+'.src = "'+imgSrc+'"')
	}
}
function changeImage(layer,imgName,imgObj) {
	if (document.images) {
		if (document.layers && layer!=null) eval('document.'+layer+'.document.images["'+imgName+'"].src = '+imgObj+'.src')
		else document.images[imgName].src = eval(imgObj+".src")
	}
}

/*
var message="";
function clickIE() {if (document.all) {(message);return false;}}
function clickNS(e) {if 
(document.layers||(document.getElementById&&!document.all)) {
if (e.which==2||e.which==3) {(message);return false;}}}
if (document.layers) 
{document.captureEvents(Event.MOUSEDOWN);document.onmousedown=clickNS;}
else{document.onmouseup=clickNS;document.oncontextmenu=clickIE;}
document.oncontextmenu=new Function("return false")
*/


/*
The following was initially in the default page, but it was moved here so it can
be used on subpages
10/18/05 - KV
*/
function toggleWelcomeSections(objectID) {
	if (findDOM('homepageDefaultWelcome')) {
		var dom = findDOM(objectID,1);
		var domDefault = findDOM('homepageDefaultWelcome',1);
		var stateDefault = domDefault.visibility;
		state = dom.visibility;
		if (state == 'hidden' || state == 'hide' ) {    
			if ( stateDefault = 'visible' ) {
				domDefault.visibility = 'hidden';
			}
			dom.visibility = 'visible';
		} else {
			if (state == 'visible' || state=='show') {		
				if ( stateDefault = 'hidden' ) {
					domDefault.visibility = 'visible';
				}	    
				dom.visibility = 'hidden'; 
			} else {
				if ( stateDefault = 'visible') {
					domDefault.visibility = 'hidden';
				}	    
				dom.visibility = 'visible';
			}
		}
	}
}  

// ********* Added from Petroferm Home Page ************
var welcomeInterval = 1250; 
// array list of sections
//var welcomeSections = new Array("homepagePetrofermCleaningWelcome", "homepagePetrofermFuelWelcome", "homepageConsumerWelcome", "homepageIndustrialWelcome");
var defaultWelcomeSection = 'homepageDefaultWelcome';
var timeOut; // used to identify the setTimeout call

// Sets the specified section to visible, and
// sets all others to hidden
function setWelcomeSection(objectID) {
	hover = true;
	setVisibility(defaultWelcomeSection,'hidden');
	for (var i = 0; i < welcomeSections.length; i++) {
		if (welcomeSections[i] == objectID) {
			setVisibility(welcomeSections[i],'visible');
		} else {
			setVisibility(welcomeSections[i],'hidden');
		}
	}
}
// Restores the default images and section, hides
// the other sections
function restoreDefaultWelcome(welcomeSection) {

    setVisibility(defaultWelcomeSection,'visible');
	MM_swapImgRestore();
	for (var j = 0; j < welcomeSections.length; j++) {
		setVisibility(welcomeSections[j],'hidden');
	}
	
}
// This function performs the steps to change the section that
// is displayed -- cancels the timeout, and changes the button
// image and displays the specified section
function welcomeSectionMouseOver(imgID, imgPath, welcomeSection) {
	window.clearTimeout(timeOut);
	MM_swapImgRestore();
	MM_swapImage(imgID,'',imgPath,1);
	setWelcomeSection(welcomeSection);
}
// sets the time out to restore the welcome back to the default
function welcomeSectionMouseOut(welcomeSection) {
    var func = "restoreDefaultWelcome('" + welcomeSection + "')";
	timeOut = window.setTimeout(func,welcomeInterval);
}
// ********* Added from Petroferm Home Page ************
