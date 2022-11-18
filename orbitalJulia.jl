function imageMap(img,center,scale)

  halfSize = Integer.(floor.(size(img)./2))
  diagonal = 2*sqrt(halfSize[1]^2 + halfSize[2]^2) * scale
  mapSize = Integer(ceil(diagonal))

  map = Array{RGBA{Normed{UInt8,8}},2}(undef,(mapSize,mapSize))
  fill!(map, RGBA{Normed{UInt8,8}}(0.0,0.0,0.0,0.0))

  transparent = RGBA{Normed{UInt8,8}}(0.0,0.0,0.0,0.0)
  black = RGBA{Normed{UInt8,8}}(0.0,0.0,0.0,1.0)

  for j in 1:mapSize
    for i in 1:mapSize
      map[i,j] = (abs2(pixelToComplex((i,j), -2, 2, -2, 2, (mapSize,mapSize))) > 4 ? black : transparent )
    end
  end

  topLeft = complexToPixel(center, -2, 2, -2, 2, (mapSize,mapSize)) .- halfSize

  map[topLeft[1]:topLeft[1] + size(img)[1]-1, topLeft[2]:topLeft[2] + size(img)[2]-1] = img

  map

end

function getPixelFromMap(map, c)
  transparent = RGBA{Normed{UInt8,8}}(0.0,0.0,0.0,0.0)
  p = complexToPixel(c, -2, 2, -2, 2, size(map))

  if p[1] == -1
    pixColor = transparent
  else
    pixColor = map[p[1],p[2]]
  end

  pixColor
end

function drawJuliaImage(
  center::Tuple{Real,Real}=(-0.75,0),
  imageSize = (250,250),
  juliaPoint = 0.0 + 0.0*im,
  sourceImage = "",
  sourceImageScale = 1,
  sourceImageLocation = 0.0 + 0.0*im,
  zoom=1,
  maxIters::Integer=100,
  bailout=2^8
)

  defaultScale = 1.75

  #Quicker to evaluate squared absolute value of complex number
  bailout2 = bailout*bailout

  imageSize = (imageSize[1],imageSize[2])
  if imageSize[1] > imageSize[2]
    aspectRatio = imageSize[1]/imageSize[2]
    xmin = center[1] - defaultScale*aspectRatio/zoom
    xmax = center[1] + defaultScale*aspectRatio/zoom
    ymin = center[2] + defaultScale/zoom
    ymax = center[2] - defaultScale/zoom
  else
    aspectRatio = imageSize[2]/imageSize[1]
    xmin = center[1] - defaultScale/zoom
    xmax = center[1] + defaultScale/zoom
    ymin = center[2] + defaultScale*aspectRatio/zoom
    ymax = center[2] - defaultScale*aspectRatio/zoom
  end
  print("Aspect Ratio: $aspectRatio\n")
  img = Array{RGBA{Float64},2}(undef,imageSize[2],imageSize[1])

  #print(img)

  sourceImage = RGBA.(sourceImage)
  map = imageMap(sourceImage, sourceImageLocation, sourceImageScale)

  transparent = RGBA{Normed{UInt8,8}}(0.0,0.0,0.0,0.0)
  black = RGBA{Normed{UInt,8}}(0.0, 0.0, 0.0, 1.0)

  print("[")
  for j in 1:imageSize[1]
    if j%(floor(imageSize[1]/50)) == 0
      print(".")
    end

    for i in 1:imageSize[2]
      c = pixelToComplex((j,i), xmin, xmax, ymin, ymax, imageSize)
      tmpColor = transparent
      pixelSet = false
      z0 = c
      z = z0
      iter = 0
      while abs2(z) < 4 && iter < maxIters
        z = z^2 + juliaPoint
        if abs2(z) > bailout
          iter = maxIters
          break
        elseif tmpColor == transparent && abs2(z) < 4
          tmpColor = getPixelFromMap(map, z)
        end
        iter += 1
      end

      if tmpColor == transparent && iter < maxIters
        img[i,j] = black
      #elseif iter == maxIters
      #  img[i,j] = black
      else
        img[i,j] = tmpColor
      end
      if img[i,j] == transparent
        img[i,j] = black
      end


    end
  end
  print("]\n")

  img,map
end
