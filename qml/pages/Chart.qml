/*
 * Copyright (C) 2015 Mathias Kraus, Germany
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0

Canvas {
    id: root

    property var dataSets: []
    property var dataRangeX: ({min: 0, max: 1})
    property bool showLabelY: true
    property bool showTopBottomFrame: true

    property bool showDots: true
    property string lineType: "bezier"
    property real bezierHandleFactor: 0.4
    property int lineWidth: 3
    property int frameLineWidth: lineWidth / 3
    property int chartHorizontalMargin: 4 * lineWidth
    property string lineColor: "grey"
    property string envelopeColor: lineColor
    property real envelopeAlpha: 0.4
    property bool showEnvelope: true
    property string dotColor: "white"
    property string frameColor: "lightgrey"
    property string labelColor: "grey"
    property string titleColor: "grey"
    property string fontFamily: "sans serif"
    property int titleFontSize: 12
    property int labelFontSize: 10
    property string chartTitle: ""

    property bool showCursor: true
    property real cursorPosition: 0.
    property int cursorWidth: lineWidth * 2 / 3
    property string cursorColor: "white"

    readonly property int graphDataWidth: root.width - 2*root.chartHorizontalMargin
    readonly property string dataIdX: "x"
    readonly property string dataIdMedian: "median"
    readonly property string dataIdMin: "min"
    readonly property string dataIdMax: "max"

    function updateChart() {
        canvas.clearChart();
        canvas.requestPaint();
    }

    onCursorPositionChanged: {
        updateChart();
    }

    Component.onCompleted: {
        updateChart();
    }

    Text {
        id: primaryTitle
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        font.family: root.fontFamily
        font.pixelSize: root.titleFontSize

        text: root.chartTitle
        color: root.titleColor
    }

    Text {
        id: primaryLabelMax
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: canvas.chartTopMargin - root.labelFontSize * 1.5
        anchors.leftMargin: root.labelFontSize / 5
        visible: root.showLabelY

        font.family: root.fontFamily
        font.pixelSize: root.labelFontSize

        text: ""
        color: root.labelColor
    }

    Text {
        id: primaryLabelMin
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.bottomMargin: canvas.chartBottomMargin - root.labelFontSize * 1.5
        anchors.leftMargin: root.labelFontSize / 5
        visible: root.showLabelY

        font.family: root.fontFamily
        font.pixelSize: root.labelFontSize

        text: ""
        color: root.labelColor
    }

    Canvas {
        id: canvas
        anchors.fill: parent

        property int chartTopMargin: titleFontSize * 1.5 + frameLineWidth / 2
        property int chartBottomMargin: labelFontSize * 1.5 + frameLineWidth / 2

        property real xStep: 1
        property real yStep: 1
        property real maxScale: 0

        function clearChart() {
            if (!canvas.available) return;

            var ctx = canvas.getContext('2d');
            if (ctx === null) return;

            ctx.save();
            ctx.clearRect(canvas.canvasWindow.x, canvas.canvasWindow.y, canvas.canvasWindow.width, canvas.canvasWindow.height);
            ctx.restore();
        }

        function findMinMaxY(dataSets) {
            // calculate range for median data to have a sanity check for bogus min/max data
            var minMedian = dataSets[0][root.dataIdMedian];
            var maxMedian = dataSets[0][root.dataIdMedian];
            for (var i = 1; i < dataSets.length; i++) {
                if(dataSets[i][root.dataIdMedian] < minMedian) minMedian = dataSets[i][root.dataIdMedian];
                if(dataSets[i][root.dataIdMedian] > maxMedian) maxMedian = dataSets[i][root.dataIdMedian];
            }
            var medianRange = maxMedian - minMedian;
            var maxOutlierMagnitude = medianRange * 1.5;

            var idMin = root.dataIdMin;
            var idMax = root.dataIdMax;
            var min = minMedian;
            var max = maxMedian;
            for (var i = 0; i < dataSets.length; i++) {
                var currentMinData = dataSets[i][idMin];
                var currentMaxData = dataSets[i][idMax];
                // prevent bogus data from going off the scale
                if (currentMinData != NaN &&
                    currentMinData != -Infinity &&
                    currentMinData < min &&
                    minMedian - currentMinData < maxOutlierMagnitude)
                { min = currentMinData; }

                if (currentMaxData != NaN &&
                    currentMaxData != Infinity &&
                    currentMaxData > max &&
                    currentMaxData - maxMedian < maxOutlierMagnitude)
                { max = currentMaxData; }
            }

            return {min: min, max: max};
        }

        function scaleMinMaxY(minMax) {
            var min = Math.floor(minMax.min * 10) / 10;
            var max = Math.ceil(minMax.max * 10) / 10;
            if(min === max) {
                min = Math.floor((minMax.min-0.1) * 10) / 10;
                max = Math.ceil((minMax.max+0.1) * 10) / 10;
            } else {
                var newMin = minMax.min - (minMax.max - minMax.min) * 0.02;
                var newMax = minMax.max + (minMax.max - minMax.min) * 0.02;
                minMax = {min: newMin, max: newMax};
                var gridFactor = 1;
                if(minMax.max - minMax.min < 1) {
                    gridFactor = 10;
                } else if(minMax.max - minMax.min < 2) {
                    gridFactor = 5;
                } else if(minMax.max - minMax.min < 5) {
                    gridFactor = 2;
                }
                min = Math.floor(minMax.min * gridFactor) / gridFactor;
                max = Math.ceil(minMax.max * gridFactor) / gridFactor;
            }

            return {min: min, max: max};
        }

        function drawTopAndBottomFrame(ctx) {
            ctx.save();

            ctx.globalAlpha = 0.5;
            ctx.strokeStyle = root.frameColor;
            ctx.lineWidth = root.frameLineWidth;

            ctx.beginPath();
            ctx.moveTo(0, canvas.chartTopMargin + root.frameLineWidth/2);
            ctx.lineTo(root.width, canvas.chartTopMargin + root.frameLineWidth/2);
            ctx.stroke();

            ctx.beginPath();
            ctx.moveTo(0, root.height - canvas.chartBottomMargin - root.frameLineWidth/2);
            ctx.lineTo(root.width, root.height - canvas.chartBottomMargin - root.frameLineWidth/2);
            ctx.stroke();

            ctx.restore();
        }

        function drawCursor(ctx) {
            ctx.save();

            ctx.globalAlpha = root.cursorPosition == 0. || root.cursorPosition == 1. ? 0.5 :  1.;
            ctx.strokeStyle = root.cursorColor;
            ctx.lineWidth = root.cursorWidth;

            var xPos = root.chartHorizontalMargin + root.graphDataWidth * root.cursorPosition;

            ctx.beginPath();
            ctx.moveTo(xPos, canvas.chartTopMargin + root.frameLineWidth);
            ctx.lineTo(xPos, root.height - canvas.chartBottomMargin - root.frameLineWidth);
            ctx.stroke();

            ctx.restore();
        }

        function drawDots(ctx, dataSets, maxScale, xStep, yStep) {
            var chartTopMargin = canvas.chartTopMargin
            var chartHorizontalMargin = root.chartHorizontalMargin
            var lineWidth = root.lineWidth;
            var dotRadius = lineWidth/4;

            var alpha = 1;

            // fade out points if they get too near to each other
            if(xStep < 3*lineWidth) {
                if(xStep < 1.5*lineWidth) {
                    alpha = 0;
                    return;
                } else {
                    alpha = alpha * (xStep - 1.5*lineWidth)/(1.5*lineWidth);
                }
            }

            ctx.save();
            ctx.globalAlpha = alpha;
            ctx.strokeStyle = root.dotColor;
            ctx.fillStyle = root.dotColor;
            ctx.lineWidth = lineWidth;

            if( root.dataRangeX.min === root.dataRangeX.max) {
                ctx.beginPath();
                ctx.arc(chartHorizontalMargin + xStep/2 + (dataSets[0][root.dataIdX] - root.dataRangeX.min) * xStep, chartTopMargin + (maxScale - dataSets[0][root.dataIdMedian]) * yStep, dotRadius, 0, 2*Math.PI);
                ctx.fill();
                ctx.stroke();
            } else {
                for (var i = 0; i < dataSets.length; i++) {
                    ctx.beginPath();
                    ctx.arc(chartHorizontalMargin + (dataSets[i][root.dataIdX] - root.dataRangeX.min) * xStep, chartTopMargin + (maxScale - dataSets[i][root.dataIdMedian]) * yStep, dotRadius, 0, 2*Math.PI);
                    ctx.fill();
                    ctx.stroke();
                }
            }
            ctx.restore();
        }

        function drawLineGraphEnvelope(ctx, dataSets, maxScale, xStep, yStep) {
            if (dataSets.length < 2) { return; }

            var chartTopMargin = canvas.chartTopMargin
            var chartHorizontalMargin = root.chartHorizontalMargin

            ctx.save();

            ctx.globalAlpha = root.envelopeAlpha;
            ctx.fillStyle = root.envelopeColor;
            ctx.lineWidth = 0;
            ctx.lineJoin = "bevel";

            ctx.beginPath();
            ctx.moveTo(chartHorizontalMargin + (dataSets[0][root.dataIdX] - dataRangeX.min) * xStep, chartTopMargin + (maxScale - dataSets[0][root.dataIdMax]) * yStep);
            for(var i = 0; i < dataSets.length; ++i) {
                ctx.lineTo(chartHorizontalMargin + (dataSets[i][root.dataIdX] - dataRangeX.min) * xStep, chartTopMargin + (maxScale - dataSets[i][root.dataIdMax]) * yStep);
            }
            for(var i = dataSets.length-1; i >= 0; --i) {
                ctx.lineTo(chartHorizontalMargin + (dataSets[i][root.dataIdX] - dataRangeX.min) * xStep, chartTopMargin + (maxScale - dataSets[i][root.dataIdMin]) * yStep);
            }
            ctx.closePath();
            ctx.fill();

            ctx.restore();
        }

        function drawLineGraph(ctx, dataSets, maxScale, xStep, yStep) {
            if (dataSets.length < 2) { return; }

            var chartTopMargin = canvas.chartTopMargin
            var chartHorizontalMargin = root.chartHorizontalMargin

            ctx.save();

            ctx.globalAlpha = 1.;
            ctx.strokeStyle = root.lineColor;
            ctx.lineWidth = root.lineWidth;
            ctx.lineJoin = "bevel";

            ctx.beginPath();
            ctx.moveTo(chartHorizontalMargin + (dataSets[0][root.dataIdX] - dataRangeX.min) * xStep, chartTopMargin + (maxScale - dataSets[0][root.dataIdMedian]) * yStep);
            for(var i = 1; i < dataSets.length; i++) {
                ctx.lineTo(chartHorizontalMargin + (dataSets[i][root.dataIdX] - dataRangeX.min) * xStep, chartTopMargin + (maxScale - dataSets[i][root.dataIdMedian]) * yStep);
            }
            ctx.stroke();

            ctx.restore();
        }

        function bezierControlPointsLeftRight(left, current, right) {
            var slope = 0;
            var toLeft = (left.y - current.y) / (left.x - current.x);
            var toRight = (right.y - current.y) / (right.x - current.x);
            if ((left.y <= current.y && right.y <= current.y) || (left.y >= current.y && right.y >= current.y)) {
                slope = 0;
            } else if (Math.abs(toLeft) > Math.abs(toRight)) {
                slope = toRight;
            } else {
                slope = toLeft;
            }

            var deltaLeft = (current.x - left.x) * root.bezierHandleFactor;
            var cpLeft = {x: current.x - deltaLeft, y: current.y - deltaLeft * slope};
            var deltaRight = (right.x - current.x) * root.bezierHandleFactor;
            var cpRight = {x: current.x + deltaRight, y: current.y + deltaRight * slope};

            return { left: cpLeft, right: cpRight };
        }

        function bezierControlPointRight(current, right) {
            var slope = (right.y - current.y) / (right.x - current.x);

            var deltaRight = (right.x - current.x) * root.bezierHandleFactor;
            return { x: current.x + deltaRight, y: current.y + deltaRight * slope };
        }

        function bezierControlPointLeft(left, current) {
            var slope = (left.y - current.y) / (left.x - current.x);

            var deltaLeft = (current.x - left.x) * bezierHandleFactor;
            return { x: current.x - deltaLeft, y: current.y - deltaLeft * slope };
        }

        function bezierEndPoint(dataSets, index, dataIdX, dataIdY, maxScale, xStep, yStep) {
            return { x: root.chartHorizontalMargin + (dataSets[index][dataIdX] - root.dataRangeX.min) * xStep,
                y: canvas.chartTopMargin + (maxScale - dataSets[index][dataIdY]) * yStep };
        }

        function drawBezierGraphEnvelope(ctx, dataSets, maxScale, xStep, yStep) {
            if (dataSets.length < 2) { return; }

            ctx.save();

            ctx.globalAlpha = root.envelopeAlpha;
            ctx.fillStyle = root.envelopeColor;
            ctx.lineWidth = 0;

            // max path
            var left    = { x: 0, y: 0 };
            var current = bezierEndPoint(dataSets, 0, root.dataIdX, root.dataIdMax, maxScale, xStep, yStep);
            var right   = bezierEndPoint(dataSets, 1, root.dataIdX, root.dataIdMax, maxScale, xStep, yStep);
            var cpRight = bezierControlPointRight(current, right);

            ctx.beginPath();
            ctx.moveTo(current.x, current.y);
            for (var i = 1; i < dataSets.length-1; ++i) {
                left    = { x: current.x, y: current.y };
                current = { x: right.x, y: right.y };
                right   = bezierEndPoint(dataSets, i+1, root.dataIdX, root.dataIdMax, maxScale, xStep, yStep);

                var cp = bezierControlPointsLeftRight(left, current, right);
                ctx.bezierCurveTo(cpRight.x, cpRight.y, cp.left.x, cp.left.y, current.x, current.y);
                cpRight = {x: cp.right.x, y: cp.right.y};
            }
            left = { x: current.x, y: current.y };
            current = { x: right.x, y: right.y };

            var cpLeft = bezierControlPointLeft(left, current);
            ctx.bezierCurveTo(cpRight.x, cpRight.y, cpLeft.x, cpLeft.y, current.x, current.y);

            // min path
            current = bezierEndPoint(dataSets, dataSets.length-1, root.dataIdX, root.dataIdMin, maxScale, xStep, yStep);
            left    = bezierEndPoint(dataSets, dataSets.length-2, root.dataIdX, root.dataIdMin, maxScale, xStep, yStep);
            cpLeft  = bezierControlPointLeft(left, current);

            ctx.lineTo(current.x, current.y);
            for (var i = dataSets.length-2; i > 0; --i) {
                right   = { x: current.x, y: current.y };
                current = { x: left.x, y: left.y };
                left    = bezierEndPoint(dataSets, i-1, root.dataIdX, root.dataIdMin, maxScale, xStep, yStep);

                var cp = bezierControlPointsLeftRight(left, current, right);
                ctx.bezierCurveTo(cpLeft.x, cpLeft.y, cp.right.x, cp.right.y, current.x, current.y);
                cpLeft = {x: cp.left.x, y: cp.left.y};
            }
            right = { x: current.x, y: current.y };
            current = { x: left.x, y: left.y };

            var cpRight = bezierControlPointRight(current, right);
            ctx.bezierCurveTo(cpLeft.x, cpLeft.y, cpRight.x, cpRight.y, current.x, current.y);

            ctx.closePath();
            ctx.fill();

            ctx.restore();
        }

        function drawBezierGraph(ctx, dataSets, maxScale, xStep, yStep) {
            if (dataSets.length < 2) { return; }

            ctx.save();

            ctx.globalAlpha = 1.;
            ctx.strokeStyle = root.lineColor;
            ctx.lineWidth = root.lineWidth;

            var left    = { x: 0, y: 0 };
            var current = bezierEndPoint(dataSets, 0, root.dataIdX, root.dataIdMedian, maxScale, xStep, yStep);
            var right   = bezierEndPoint(dataSets, 1, root.dataIdX, root.dataIdMedian, maxScale, xStep, yStep);
            var cpRight = bezierControlPointRight(current, right);

            ctx.beginPath();
            ctx.moveTo(current.x, current.y);
            for (var i = 1; i < dataSets.length-1; ++i) {
                left = { x: current.x, y: current.y };
                current = { x: right.x, y: right.y };
                right   = bezierEndPoint(dataSets, i+1, root.dataIdX, root.dataIdMedian, maxScale, xStep, yStep);

                var cp = bezierControlPointsLeftRight(left, current, right);
                ctx.bezierCurveTo(cpRight.x, cpRight.y, cp.left.x, cp.left.y, current.x, current.y);
                cpRight = {x: cp.right.x, y: cp.right.y};
            }
            left = { x: current.x, y: current.y };
            current = { x: right.x, y: right.y };

            var cpLeft = bezierControlPointLeft(left, current);
            ctx.bezierCurveTo(cpRight.x, cpRight.y, cpLeft.x, cpLeft.y, current.x, current.y);
            ctx.stroke();

            ctx.restore();
        }

        onPaint:{
            if (!canvas.available) return;

            var ctx = canvas.getContext('2d');
            if (ctx === null) return;

            var dataRangeWidth = dataRangeX.max - dataRangeX.min;
            var dataSets = root.dataSets;
            if(dataSets.length === 0 || dataRangeWidth < 0) return;

            canvas.xStep = graphDataWidth / (dataRangeWidth === 0 ? 1 : dataRangeWidth);

            var minMax = findMinMaxY(dataSets);
            var scale = scaleMinMaxY(minMax);

            canvas.maxScale = scale.max;

            canvas.yStep = (root.height - canvas.chartTopMargin - canvas.chartBottomMargin) / (scale.max - scale.min);

            if(root.showTopBottomFrame === true) {
                drawTopAndBottomFrame(ctx);
            }

            // only draw graph if there are at least two points
            if(dataSets.length > 1) {
                if (root.showEnvelope) {
                    switch(root.lineType) {
                        case "bezier":
                            drawBezierGraphEnvelope(ctx, dataSets, scale.max, canvas.xStep, canvas.yStep);
                            break;
                        case "line":
                        default:
                            drawLineGraphEnvelope(ctx, dataSets, scale.max, canvas.xStep, canvas.yStep);
                    }
                }

                switch(root.lineType) {
                    case "bezier":
                        drawBezierGraph(ctx, dataSets, scale.max, canvas.xStep, canvas.yStep);
                        break;
                    case "line":
                    default:
                        drawLineGraph(ctx, dataSets, scale.max, canvas.xStep, canvas.yStep);
                }
            }

            if(root.showDots === true || dataSets.length  < 2) {
                drawDots(ctx, dataSets, scale.max, canvas.xStep, canvas.yStep);
            }

            if(root.showCursor) {
                drawCursor(ctx);
            }

            primaryLabelMax.text = scale.max;
            primaryLabelMin.text = scale.min;
        }
    }
}

