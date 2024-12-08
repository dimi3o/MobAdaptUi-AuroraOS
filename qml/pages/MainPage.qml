import QtQuick 2.0
import Sailfish.Silica 1.0

import StringObject 1.0 //----second way CPPtoQML

Page {
    objectName: "mainPage"
    allowedOrientations: Orientation.All
    backgroundColor: "white"

    StringObject {
        id: stringObject //----second way CPPtoQML
    }

    property string colorRectStr: "red"

    Canvas {
            id: plotCanvas
            anchors.fill: parent
            onPaint: {
                var ctx = plotCanvas.getContext("2d");
                drawAxes(ctx);
                //plotFunction(ctx, Math.sin);
                var res = utilityServ.getErrors();
                var points = []
                console.log('paint 1');
                for (var i = 0; i < res.length; i++) {
                    points.push({x: i, y: res[i]})
                }

                console.log('paint 2');

                console.log(JSON.stringify(points));

                plotPoints(ctx, points);
            }

            // Graph properties
            property real minX: -100
            property real maxX: 2100
            property real minY: -0.1
            property real maxY: 1
            property real step: 0.1

            // Function to map x-coordinate to pixel
            function xToPixel(x) {
                return ((x - minX) / (maxX - minX)) * plotCanvas.width;
            }

            // Function to map y-coordinate to pixel
            function yToPixel(y) {
                return plotCanvas.height - ((y - minY) / (maxY - minY)) * plotCanvas.height;
            }

            // Draw the X and Y axes
            function drawAxes(ctx) {
                ctx.save();
                ctx.clearRect(0, 0, plotCanvas.width, plotCanvas.height);
                ctx.strokeStyle = "black";
                ctx.lineWidth = 2;

                // X-axis
                var yZero = yToPixel(0);
                ctx.beginPath();
                ctx.moveTo(0, yZero);
                ctx.lineTo(plotCanvas.width, yZero);
                ctx.stroke();

                // Y-axis
                var xZero = xToPixel(0);
                ctx.beginPath();
                ctx.moveTo(xZero, 0);
                ctx.lineTo(xZero, plotCanvas.height);
                ctx.stroke();

                ctx.font = "20px serif";
                ctx.fillStyle = "#000000";

                for (var i = 100; i < 2000; i += 100) {
                    var x = xToPixel(i);
                    ctx.beginPath();
                    ctx.moveTo(x, yToPixel(0.01));
                    ctx.lineTo(x, yToPixel(-0.01));
                    ctx.fillText(i.toString(), x, yToPixel(-0.02));
                    ctx.stroke();
                }

                for (var i = -0.05; i < 1; i += 0.05) {
                    var y = yToPixel(i);
                    ctx.beginPath();
                    ctx.moveTo(xToPixel(-10), y);
                    ctx.lineTo(xToPixel(10), y);
                    ctx.fillText((Math.round(i * 100) / 100).toString(), xToPixel(10), y);
                    ctx.stroke();
                }

                ctx.restore();
            }

            // Plot the function
            function plotFunction(ctx, func) {
                ctx.save();
                ctx.strokeStyle = "blue";
                ctx.lineWidth = 2;
                ctx.beginPath();

                var firstPoint = true;
                for (var x = minX; x <= maxX; x += step) {
                    var y = func(x);
                    var px = xToPixel(x);
                    var py = yToPixel(y);

                    if (firstPoint) {
                        ctx.moveTo(px, py);
                        firstPoint = false;
                    } else {
                        ctx.lineTo(px, py);
                    }
                }
                ctx.stroke();
                ctx.restore();
            }

            // Plot specific points on the graph
            function plotPoints(ctx, points) {
                ctx.save();
                ctx.fillStyle = "red";
                ctx.strokeStyle = "black";
                points.forEach(function(point) {
                    var px = xToPixel(point.x);
                    var py = yToPixel(point.y);
                    ctx.beginPath();
                    ctx.arc(px, py, 5, 0, 2 * Math.PI);
                    ctx.fill();
                    ctx.stroke();
                });
                ctx.restore();
            }

            // Redraw when the window is resized
            onWidthChanged: plotCanvas.requestPaint()
            onHeightChanged: plotCanvas.requestPaint()
        }
}
