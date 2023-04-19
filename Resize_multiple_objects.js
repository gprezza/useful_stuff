// fac is the scaling factor. Change this number.
var fac = 1.5;

let sel = host.ActiveSelectionRange;

// Function to resize objects
function resizeObjects(objects) {
    var doc = objects.Parent;
    for (var i = 0; i < objects.Count; i++) {
        var obj = objects.Item(i + 1);
        
        var oldSizeWidth = obj.SizeWidth;
        var oldSizeHeight = obj.SizeHeight;
        var newSizeWidth = obj.SizeWidth * fac;
        var newSizeHeight = obj.SizeHeight * fac;
        
        obj.SizeWidth = newSizeWidth;
        obj.SizeHeight = newSizeHeight;
        var posX = obj.PositionX;
        var posY = obj.PositionY;
        obj.PositionX = posX - (newSizeWidth - oldSizeWidth)/2;
        obj.PositionY = posY + (newSizeHeight - oldSizeHeight)/2;
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
