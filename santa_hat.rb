require 'csv';
# require 'pry';

$treeLightCoordinates = CSV.read("tree_coords_matt_parker.csv");

$treeHeight = 3.30
$brimHeight = 0.65
$brimWidth = 0.4
$dotHeight = 0.25
$animationOrder = [
  { name: :redFall, length: 100 },
  { name: :whiteRim, length: 100 },
  { name: :dotRise, length: 100 },
  { name: :rest, length: 100 },
  { name: :fadeOut, length: 50 },
];
header = ['﻿FRAME_ID'] + (0..499).map{|i| ["R_#{i}", "G_#{i}", "B_#{i}"] }.flatten

$lightMap = $treeLightCoordinates.map{|lightCoors| [0, 0, 0]} # Start all black

$saveState = nil

# convert the strings to numbers
$treeLightCoordinates.map! do |lightCoors|
  lightCoors.map {|coor| coor.to_f}
end

def lightMapToFrame(frameNumber)
  [frameNumber] + $lightMap.map{|color| color.map(&:round).map{|i| [i, 0].max}}.flatten
end

def updateLightMap(sectionName, frameNumber, animationLength)
  if sectionName == :dotRise
    if frameNumber == 0
      $saveState =  Marshal.dump($lightMap)
    else
      $lightMap = Marshal.load($saveState)
    end
  end

  animationProgress = (frameNumber.to_f / animationLength) # range 0-1
  $treeLightCoordinates.each_with_index do |lightCoors, index|
    if sectionName === :redFall
      # red falldown
      if (lightCoors[2] / $treeHeight) > (1 - animationProgress)
        # update light
        $lightMap[index] = [255, 0, 0] # red
      end
    elsif sectionName === :whiteRim
      # white rim
      if lightCoors[2] < $brimHeight
        distanceFromCenter = Math.sqrt(lightCoors[0] ** 2 + lightCoors[1] ** 2);
        if distanceFromCenter > $brimWidth

          angleInRadians = Math.atan(lightCoors[0] / lightCoors[1]) + Math::PI/2;
          if lightCoors[1] < 0
            angleInRadians += Math::PI
          end
          if (angleInRadians / (2 * Math::PI)) < animationProgress
            $lightMap[index] = [255, 255, 255] # white
          end
        end
      end
    elsif sectionName === :dotRise
      if lightCoors[2] > $brimHeight
        riseHeight = $treeHeight - $dotHeight
        currentHeight = riseHeight * animationProgress
        distance = (currentHeight - lightCoors[2]).abs

        if distance < $dotHeight / 2 || (distance < $dotHeight && frameNumber === 99)
          $lightMap[index] = [ 255, 255, 255 ] # white
        elsif distance < $dotHeight
          $lightMap[index] = [ 255, 130, 130 ] # white
        end
      end
    elsif sectionName === :fadeOut
      $lightMap[index].map!{ |colorComponent| colorComponent - 255.0 / 50 } # 50 is fadeLength
    end
  end
end

CSV.open("santa_hat_effect_frank.csv", "w") do |csv|
  csv << header
  totalFrameNumber = 0
  $animationOrder.each do |animationSection|
    (0..animationSection[:length]-1).each do |frameNumber|
      # if (frameNumber === 1)
        updateLightMap(animationSection[:name], frameNumber, animationSection[:length])
        csv << lightMapToFrame(totalFrameNumber)
        totalFrameNumber += 1
      # end
    end
  end
end

puts 'Done generating animation'
