
function complexToPixel(c, xmin, xmax, ymin, ymax, imageSize)
  j = floor(imageSize[1] * (real(c) - xmin)/(xmax-xmin))
  i = floor(imageSize[2] * (imag(c) - ymin)/(ymax-ymin))

  if i < 0 || i > imageSize[1] - 1 || j < 0 || j > imageSize[2] - 1 || isnan(i) || isnan(j)
    p = (-1,-1)
  else
    p = (Integer(i+1),Integer(j+1))
  end

  return p

end
  
function pixelToComplex(p, xmin, xmax, ymin, ymax, imageSize)
  relx = xmin + (p[1]-0.5)*(xmax-xmin)/(imageSize[1])
  rely = ymin + (p[2]-0.5)*(ymax-ymin)/(imageSize[2])
  c = relx + rely*im
end

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