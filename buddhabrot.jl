#Mandelbrot drawing
using Images, Colors, FixedPointNumbers, FileIO

cmap = [
  RGB(9/255, 1/255, 47/255),
  RGB(4/255, 4/255, 73/255),
  RGB(0/255, 7/255, 100/255),
  RGB(12/255, 44/255, 138/255),
  RGB(24/255, 82/255, 177/255),
  RGB(57/255, 125/255, 209/255),
  RGB(134/255, 181/255, 229/255),
  RGB(211/255, 236/255, 248/255),
  RGB(241/255, 233/255, 191/255),
  RGB(248/255, 201/255, 95/255),
  RGB(255/255, 170/255, 0/255),
  RGB(204/255, 128/255, 0/255),
  RGB(153/255, 87/255, 0/255),
  RGB(106/255, 52/255, 3/255),
  RGB(66/255, 30/255, 15/255),
  RGB(25/255, 7/255, 26/255)
]


function juliaIterations(c, juliaPoint, maxIters=1000, bailout = 2^8)
  z0 = c
  z = z0

  iter = 0

  #Cardioid Test
  #p = (real(c) - 0.25)^2 + imag(c)^2
  #Period-2 Bulb Test
  #q = (real(c)+1)^2 + imag(c)^2

  #if p <= 0.25*imag(c)^2 || q <= 1/16
  #    return maxIters,c
  #end

  bailout2 = bailout*bailout

  while ( abs2(z) < bailout2 && iter < maxIters)
    zstar = z^2 + juliaPoint
    if zstar == z
      iter = maxIters
    else
      z = zstar
      iter += 1
    end
  end

  return iter,z

end

function  mandelbrot(c, maxIters=1000, bailout = 2^8)
  z0 = 0 + 0im
  z = z0

  iter = 0

  #Cardioid Test
  p = (real(c) - 0.25)^2 + imag(c)^2
  #Period-2 Bulb Test
  q = (real(c)+1)^2 + imag(c)^2

  if p <= 0.25*imag(c)^2 || q <= 1/16
    return maxIters,c
  end

  bailout2 = bailout*bailout

  while ( abs2(z) < bailout2 && iter < maxIters)
    zstar = z^2 + c
    if zstar == z
      iter = maxIters
    else
      z = zstar
      iter += 1
    end
  end

  return iter,z

end

function mandelbrot_gpu(c, iters, z, maxIters, bailout2)
  i = threadIdx().x
  c1 = c[i]
  z0 = 0 + 0*im
  z1 = z0

  iter = 0

  #Cardioid Test
  p = (real(c1) - 0.25)^2 + imag(c1)^2
  #Period-2 Bulb Test
  q = (real(c1)+1)^2 + imag(c1)^2

  if p <= 0.25*imag(c1)^2 || q <= 1/16
    iters[i] = maxIters
    z[i] = c1
    return
  end

  while ( abs2(z1) < bailout2 && iter < maxIters)
    zstar = z1*z1 + c1
    if zstar == z1
      iter = maxIters
      break
    else
      z1 = zstar
      iter +=1
    end
  end

  iters[i] = iter
  z[i] = z1

  return
end



function  burningShip(c, maxIters=1000, bailout = 2^8)
  z0 = 0 + 0im
  z = z0

  iter = 0

  while ( abs2(z) < 4 && iter < maxIters)
    zstar = (abs(real(z)) + im*abs(imag(z)))^2 + c
    if zstar == z
      iter = maxIters
    else
      z = zstar
      iter += 1
    end
  end

  return iter

end

function complexToPixel(c, xmin, xmax, ymin, ymax, imageSize)
  j = floor(imageSize[1] * (real(c) - xmin)/(xmax-xmin))
  i = floor(imageSize[2] * (-imag(c) - ymin)/(ymax-ymin))

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
      c = relx - rely*im
end

function drawBuddhabrot(;
  center::Tuple{Real,Real}=(-0.75,0),
  imageSize = (250,250),
  zoom=1,
  maxIters::Integer=100,
  bailout=3,
  N = 100
)

  #default = (-2.5,1,-1.75,1.75)
  defaultScale = 1.75

  #Quicker to evaluate squared absolute value of complex number
  bailout2 = bailout*bailout

  #xmin,xmax,ymin,ymax = area
  #center = (center[,center[1])

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
  #print("Aspect Ratio: $aspectRatio\n")
  img = Array{RGB{Float64},2}(undef,imageSize[2],imageSize[1])
  itersReached = Array{Float64,2}(undef,imageSize[2],imageSize[1])


  histogram = [0 for i in 1:maxIters]

  dens = zeros(Int64, imageSize[2], imageSize[1])

  #guidict = ImageView.imshow(dens)
  #canvas = guidict["gui"]["canvas"]

  print("[")
  for i = 1:N
    if i%floor(N/20) == 0
      print(".")
    end
    c = xmin + rand()*(xmax-xmin) - (ymin + rand()*(ymax-ymin))*im
    #curIter,z = mandelbrot(c, maxIters, bailout)
    curIter = burningShip(c, maxIters, bailout)
    #Does this point escape?
    if curIter < maxIters
      #Add points of orbit to image
      z = 0 + 0im
      for iter = 1:curIter
        #z = (abs(real(z)) + im*abs(imag(z)))^2 + c
        z = z*z + c
        p = complexToPixel(z, xmin, xmax, ymin,ymax, imageSize)
        if p[1] > 0
          dens[p[2],p[1]] += 1
          p = complexToPixel(real(z) - imag(z)*im, xmin,xmax,ymin,ymax,imageSize)
          if p[1] > 0
            dens[p[2],p[1]] += 1
          end
        end
      end
    else
      #Carry on (my wayward son)
    end
  end
  print("]")

  dens/maximum(dens)

end
