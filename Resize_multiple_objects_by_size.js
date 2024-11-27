// these two variables are the new width and heigth. Change these numbers.
var newSizeWidth = 0.04;
var newSizeHeigth = 0.04;

let sel = host.ActiveSelectionRange;

// Function to resize objects
function resizeObjects(objects) {
    var doc = objects.Parent;
    for (var i = 0; i < objects.Count; i++) {
        var obj = objects.Item(i + 1);
        
        var oldSizeWidth = obj.SizeWidth;
        var oldSizeHeight = obj.SizeHeight;
        
        obj.SizeWidth = newSizeWidth;
        obj.SizeHeight = newSizeHeigth  ;
        var posX = obj.PositionX;
        var posY = obj.PositionY;
        obj.PositionX = posX - (newSizeWidth - oldSizeWidth)/2;
        obj.PositionY = posY + (newSizeHeigth - oldSizeHeight)/2;
    }
}

// Main function
function main() {

    // Call the resizeObjects function with the selected objects
    resizeObjects(sel);
}

// Run the macro.
// BeginCommandGroup and EndCommandGroup are needed to be able to
// undo the macro as a single step.

host.ActiveDocument.BeginCommandGroup("Resize multiple objects");
main();
host.ActiveDocument.EndCommandGroup;
