require 'ruby2d'
require 'csv';

treeLightCoordinates = CSV.read("tree_coords_matt_parker.csv");
animationDataPoints = CSV.read("santahat.csv");

$numberOfTreeRenders = 2

$borderSize = 60;
$treeWidthInWindow = 400
$treeHeightInWindow = 800

$windowWidth = $numberOfTreeRenders * $treeWidthInWindow + $numberOfTreeRenders * 2 * $borderSize;
$windowHeight = $treeHeightInWindow + 2 * $borderSize;

set title: "Hello Tree", width: $windowWidth, height: $windowHeight

def translateGIFTtoFrame(coors, treeRenderIndex)
  scaleUp = $treeWidthInWindow  / 2;
  horizontalOffset = $treeWidthInWindow + 2 * $borderSize;
  [
    (coors[0] * scaleUp) + scaleUp + $borderSize + treeRenderIndex * horizontalOffset,
    (coors[1] * scaleUp) + scaleUp + $borderSize + treeRenderIndex * horizontalOffset,
    $windowHeight - (coors[2] * scaleUp) - $borderSize, # Flip y axis
  ]
end

def applyAnimationFrame(lights, newRGBValues)
  lights.each_with_index do |light, index|
    if light
      light.color = [
        newRGBValues[index * 3 + 0].to_f / 255, # r
        newRGBValues[index * 3 + 1].to_f / 255, # g
        newRGBValues[index * 3 + 2].to_f / 255, # b
        light.color.a, # a
      ]
    end
  end
end

# convert the string to numbers
treeLightCoordinates.map! do |lightCoors|
  lightCoors.map {|coor| coor.to_f}
end

frontLights = treeLightCoordinates.map do |lightCoors|
  if (lightCoors[1] > 0)
    adjustedCoors = translateGIFTtoFrame(lightCoors, 0)
    Square.new(
      x: adjustedCoors[0],
      y: adjustedCoors[2],
      size: 8,
      color: [ 1, 0.5, 0.5, 1], # rgba
    )
  else
    nil
  end
end

backLights = treeLightCoordinates.map do |lightCoors|
  if (lightCoors[1] <= 0)
    adjustedCoors = translateGIFTtoFrame(lightCoors, 1)
    Square.new(
      x: adjustedCoors[0],
      y: adjustedCoors[2],
      size: 8,
      color: [ 1, 0.5, 0.5, 1], # rgba
    )
  else
    nil
  end
end

tick = 0
animationFrame = 0;
animationLength = animationDataPoints.length - 1;
update do
  if tick % 2 == 0
    applyAnimationFrame(frontLights, animationDataPoints[animationFrame + 1][1...]); # + 1 offset due to headers
    applyAnimationFrame(backLights, animationDataPoints[animationFrame + 1][1...]); # + 1 offset due to headers
    animationFrame += 1;
    if animationFrame == animationLength
      animationFrame = 0
    end
  end
  tick += 1
end
show
